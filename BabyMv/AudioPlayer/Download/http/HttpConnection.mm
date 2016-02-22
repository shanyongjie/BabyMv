//
//  HttpConnection.cpp
//  KWPlayer
//
//  Created by vieri122 on 11-11-2.
//  Copyright (c) 2011年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include "HttpConnection.h"
#include "RequestManager.h"
#import "NetworkConfigure.h"
#include <libkern/OSAtomic.h>

static CFOptionFlags HttpNetworkEvents =  kCFStreamEventOpenCompleted   | kCFStreamEventHasBytesAvailable 
                                                | kCFStreamEventEndEncountered | kCFStreamEventErrorOccurred;

static CFStringRef HttpRunLoopMode = kCFRunLoopDefaultMode;


CFRunLoopRef HttpConnection::_runloop = 0;
CLock HttpConnection::_ioEnginelock;
pthread_t HttpConnection::_IOEngine;

HttpConnection* HttpConnection::CreateHttpConnection(HttpParam *httpParam){
    return new HttpConnection(httpParam);
}

HttpConnection::HttpConnection(HttpParam* httpParam){
    _request = CFHTTPMessageCreateCopy(kCFAllocatorDefault, httpParam->GetRequestParam());
    assert(_request != 0);
    _timeOut = 35;
    _data = [[NSMutableData alloc] initWithCapacity:2048];
    _refCount = 1;
    _readStream = 0;
    _httpConState = HttpStateNotStart;
    _httpConRetCode = HttpRetOK;
    _timer = NULL;
    _httpResponse = NULL;
    _isFirstFrame = true;
    _responseStatus = 200;
    _contentLength = 0;
    _isSyn = false;
    _source = 0;
    
    _openCB = 0;
    _hasBytesavailableCB = 0; 
    _errorCB = 0;
    _endCB = 0;
    
    url = 0;
    
    _isPacFileRequest = FALSE;
    _postLength = 0;
    _lastBytesSent = 0;
    _totalBytesSent = 0;
}

HttpConnection::~HttpConnection(){
    //NSLog(@"delete httpConnection %0x",(int)this);
    if (url) {
        [url release];
    }
    [_data release];
}

int HttpConnection::AddRef(){
    return OSAtomicAdd32(1, &_refCount);
}

int HttpConnection::Release(){
    int refTemp = OSAtomicAdd32(-1,&_refCount);
    assert(refTemp>=0);
    if (0 == refTemp) {
        delete this;
    }
    return refTemp;
}

int HttpConnection::GetRef(){
    return _refCount;
}

int HttpConnection::SynSendRequest(){
    _isSyn = true;
    _readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault,_request);
    int ret = BaseAsynSendRequest();
    //CFTimeInterval interval = CFDateGetTimeIntervalSinceDate((CFDateRef)[NSDate distantFuture],
                                                             //(CFDateRef)[NSDate date]);
    if (0 == ret) {
        while (GetHttpConnectionState() == HttpStateIsDoing) {
            if ([NSThread isMainThread]) {
                CFRunLoopRunInMode(kCFRunLoopDefaultMode,0.5,true);
            }else{
                CFRunLoopRunInMode(HttpRunLoopMode,0.5,true);
            }
        }
    }
    return GetHttpConnectionRetCode();
}

NSData* HttpConnection::GetResponseData(){
    return _data;
}

int HttpConnection::AsynSendRequest(){
    CAutoLock autoLock(_cancelLock);
    int ret = 0;
    if (GetHttpConnectionState() == HttpStateNotStart) {
        _isSyn = false;
        _readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault,_request);
        ret = BaseAsynSendRequest();
    }else{
        ret = -5;
    }
    return ret;
}

int HttpConnection::AsynUpLoadFile(){
    CAutoLock autoLock(_cancelLock);
    CFStringRef urlRef = CFStringCreateWithCString(kCFAllocatorDefault,_upLoadFileName.c_str(),CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000));
    if (!urlRef) {
        return -2;
    }
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,urlRef,kCFURLPOSIXPathStyle,NO);
    if (!fileURL) {
        CFRelease(urlRef);
        return -2;
    }
    
    NSString* path = [((NSURL*)fileURL) absoluteString];
    _postLength =  [[[[[NSFileManager alloc] init] autorelease] attributesOfItemAtPath:path  error:nil] fileSize];
    
    CFReadStreamRef myPostBodyReadStream =CFReadStreamCreateWithFile(kCFAllocatorDefault, fileURL);
    if (!myPostBodyReadStream) {
        CFRelease(fileURL);
        CFRelease(urlRef);
        return -2;
    }
    
    assert(0 == _readStream);
    _readStream = CFReadStreamCreateForStreamedHTTPRequest(kCFAllocatorDefault, _request, myPostBodyReadStream);
    assert(_readStream);
    
    CFReadStreamClose(myPostBodyReadStream);
    CFRelease(myPostBodyReadStream);
    CFRelease(urlRef);
    CFRelease(fileURL);
    
    _isSyn = false;
    return BaseAsynSendRequest();
}

void HttpConnection::CanCelRequest(){
    CAutoLock autoLock(_cancelLock);
    //NSLog(@"cancelRequest:%0x",(int)this);
    //SetHttpConnectionCallBack(0, 0, 0, 0, 0);
    if (GetHttpConnectionState() != HttpStateIsDoing) {
        return;
    }
//    NSLog(@"obj:%x, http cancel",(int)this);
    SetHttpConnectionRetCode(HttpRetCancel);
    DestroyRequest();
}

void HttpConnection::DestroyRequest(){
    //SetHttpConnectionCallBack(0, 0, 0, 0, 0);
    SetHttpConnectionState(HttpStateComplete);
    //HandleCompletePerform();
    //return;
    
    CFRunLoopSourceContext context = {0, this, NULL, NULL, NULL, NULL, NULL, NULL, NULL,HttpConnection::Perform};
     _source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(HttpConnection::GetNetIOEngineRunloop(), _source, HttpRunLoopMode);
    CFRunLoopSourceSignal(_source);
    CFRunLoopWakeUp(HttpConnection::GetNetIOEngineRunloop());
}

void HttpConnection::HandleCompletePerform(){
    if (_source) {
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _source, HttpRunLoopMode);
        CFRelease(_source);
        _source = 0;
    }
    if (_timer) {
        CFRunLoopTimerInvalidate(_timer);
        CFRunLoopRemoveTimer(HttpConnection::GetNetIOEngineRunloop(), _timer, HttpRunLoopMode);
        CFRelease(_timer);
        _timer = 0;
    }
    
    if(_request){
        CFRelease(_request);
        _request = 0;
    }
    
    if (_httpResponse) {
        CFRelease(_httpResponse);
        _httpResponse = 0;
    }
    
    if (_readStream) {
        CFReadStreamSetClient(_readStream, 0, 0, 0);
        //CFReadStreamUnscheduleFromRunLoop(_readStream,HttpConnection::GetNetIOEngineRunloop(),HttpRunLoopMode);//review 代码发现此语句多余 CFReadStreamClose会完成此操作
        CFReadStreamClose(_readStream);
        CFRelease(_readStream);
        _readStream = 0; 
    }
    
    Release();
    //ReleaseRequest();
    //ReleaseRef();
}

/*
void HttpConnection::OperationComplete(HttpSessionState state){
    _isFirstFrame = true;
    SetHttpState(state);
    CFRunLoopSourceContext context = {0, this, NULL, NULL, NULL, NULL, NULL, NULL, NULL,HttpSession::Perform};
    _source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
    CFRunLoopAddSource(HttpSession::GetIOEngineRunloop(), _source, HttpSession::_runLoopMode);
    CFRunLoopSourceSignal(_source);
    CFRunLoopWakeUp(HttpSession::GetIOEngineRunloop());   
}
*/

int HttpConnection::BaseAsynSendRequest(){
    int ret = 0;
    CFStreamClientContext myContext={0,this,0,0,0};
    Boolean bRet = CFReadStreamSetProperty(_readStream, kCFStreamPropertyHTTPShouldAutoredirect, kCFBooleanTrue);
    if([NetworkConfigure sharedInstance].isWWANNetwork){//wifi可以不用这个，系统自动识别，提高效率
        ConfigureProxy(_request,_readStream);
    }
    
    assert(bRet);
    CFReadStreamScheduleWithRunLoop(_readStream, HttpConnection::GetNetIOEngineRunloop(), HttpRunLoopMode);
    if (CFReadStreamSetClient(_readStream, HttpNetworkEvents,HttpConnection::HttpConnectionCallBack, &myContext)){
        CFReadStreamScheduleWithRunLoop(_readStream, HttpConnection::GetNetIOEngineRunloop(), HttpRunLoopMode);
        SetHttpConnectionState(HttpStateIsDoing);
        AddRef();
        // add timer for time out
        _activeTime = time(0);
        CFRunLoopTimerContext myTimerContext={0,this,0,0,0};
        _timer = CFRunLoopTimerCreate(kCFAllocatorDefault, 0, 0.5, 0, 0,HttpConnection::TimerCallBack,&myTimerContext);
        CFRunLoopAddTimer(HttpConnection::GetNetIOEngineRunloop(),_timer,HttpRunLoopMode);
        if(!CFReadStreamOpen(_readStream)){
            assert(false);
            ret = -3;
        }
    }else{
        assert(false);
        ret = -4;
    }
    return ret;
}

void HttpConnection::SetHttpConnectionCallBack(HttpConnectionOpenCompleted openCompletedCB, HttpConnectionHasBytesAvailable availableDataCB, 
                               HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, void* userData){
    _openCB = openCompletedCB;
    _hasBytesavailableCB = availableDataCB;
    _errorCB = errorCB;
    _endCB = endCB;
    _userData = userData;
}

#pragma mark - handler event
void HttpConnection::HandleOpenCompletedEvent(CFReadStreamRef stream){
//    NSLog(@"obj:%x, http Open",(int)this);
    
    RequestManager::instance()->NotifyForNetRequest(NetRequestNotifyTypeStart);
    NotifyHttpConnectionOpenCompleted();
}

void  HttpConnection::HandleHasBytesAvailableEvent(CFReadStreamRef stream){
    _activeTime = time(0);
    if (_isFirstFrame) {
        _isFirstFrame = false;
        _httpResponse = (CFHTTPMessageRef)CFReadStreamCopyProperty(_readStream, kCFStreamPropertyHTTPResponseHeader);
        _responseStatus = CFHTTPMessageGetResponseStatusCode(_httpResponse);
//        NSLog(@"obj:%x, http recive first frame resopnseStatus:%d",(int)this,_responseStatus);
//        if (_responseStatus < 200 || _responseStatus > 299) {//may be 404 or others
//            return HandleRemoteServerErrorEvent(stream,HttpRetNotFound);
//        }
        CFStringRef responseLength = CFHTTPMessageCopyHeaderFieldValue(_httpResponse,CFSTR("Content-Length"));
        if (responseLength) {
            _contentLength = CFStringGetIntValue(responseLength);
            CFRelease(responseLength);
        }
    }
    CFIndex bytesRead = 0;
 	
    long long bufSize = 16*1024;
	if (_contentLength > 1024*1024) {
		bufSize = 100*1024;
	} else if (_contentLength > 64*1024) {
		bufSize = 32*1024;
	}
    
    UInt8* tempBuf = (UInt8*)alloca(bufSize);
    bytesRead = CFReadStreamRead(_readStream, tempBuf, (CFIndex)bufSize);
    if (bytesRead>0) {
        if (_isSyn) {
            [_data appendBytes:(const void *)tempBuf length:bytesRead];
        }
        NotifyHttpConnectionHasBytesAvailable((char*)tempBuf, bytesRead);
    }
    else if(bytesRead < 0){
        NSLog(@"bytesRead < 0");//error
    }else if(bytesRead == 0){
        NSLog(@"bytesRead == 0");//end
    }
}

void HttpConnection::HandleEndEncounteredEvent(CFReadStreamRef stream){
//    NSLog(@"obj:%x, http end and resopnseStatus:%d",(int)this,_responseStatus);
    if (_responseStatus < 200 || _responseStatus > 299) {//may be 404 or others
        SetHttpConnectionRetCode(HttpRetNotFound);
        //return HandleRemoteServerErrorEvent(stream,HttpRetNotFound);
    }else{
        SetHttpConnectionRetCode(HttpRetOK);
    }
    
    RequestManager::instance()->NotifyForNetRequest(NetRequestNotifyTypeOK);
    //SetHttpConnectionRetCode(HttpRetOK);
    DestroyRequest();
    NotifyHttpConnectionEndEncountered();
}

void HttpConnection::HandleErrorOccurredEvent(CFReadStreamRef stream){
#if defined(_DEBUG) || defined(__DEBUG)
    CFErrorRef error = CFReadStreamCopyError(stream);
    if(error){
        CFStringRef d = CFErrorGetDomain(error);
        CFIndex errorCode = CFErrorGetCode(error);//54 = 连接被重置
        CFStringRef description = CFErrorCopyDescription(error);
        NSLog(@"obj:%x, http error Domain:%@  description:%@ ErrorCode:%ld url:%@",(int)this,d,description,errorCode,[url absoluteString]);
        
        if(description){
            CFRelease(description);  
        }
        if (error) {
            CFRelease(error);
        }
    }
#endif
    if(![NetworkConfigure sharedInstance].isNetworkValid){
        SetHttpConnectionRetCode(HttpRetNotNet);
    }else{
        SetHttpConnectionRetCode(HttpRetNetError);
    }
    RequestManager::instance()->NotifyForNetRequest(NetRequestNotifyTypeError);
    DestroyRequest();
    NotifyHttpConnectionErrorOccurred(GetHttpConnectionRetCode());
}

void HttpConnection::HandleRemoteServerErrorEvent(CFReadStreamRef stream,HttpConnectionRetCode retCode){
//    NSLog(@"obj:%x, http remoteServerError resopnseStatus:%d url:%@",(int)this,_responseStatus,[url absoluteString]);
    SetHttpConnectionRetCode(retCode);
    DestroyRequest();
    NotifyHttpConnectionErrorOccurred(GetHttpConnectionRetCode());
}

void HttpConnection::HandleTimeOut(){
    time_t tmp = time(0) - _activeTime;
    if (tmp > _timeOut) {
        CAutoLock autoLock(_cancelLock);
        if (GetHttpConnectionState() != HttpStateIsDoing) {
            return;
        }
//        NSLog(@"obj:%x, http timeout error resopnseStatus:%d url:%@",(int)this,_responseStatus,[url absoluteString]);
       
        if (_postLength > 0) {
            _lastBytesSent = _totalBytesSent;
            
            _totalBytesSent = [[NSMakeCollectable(CFReadStreamCopyProperty(_readStream, kCFStreamPropertyHTTPRequestBytesWrittenCount)) autorelease] unsignedLongLongValue];
            
            if (_totalBytesSent > _lastBytesSent) {
                _activeTime = time(0);
            }
        }
        
        SetHttpConnectionRetCode(HttpRetTimeOut);
        DestroyRequest();
        NotifyHttpConnectionErrorOccurred(GetHttpConnectionRetCode());
    }
}

void HttpConnection::HandleHttpConnectionCallBack(CFReadStreamRef stream,CFStreamEventType eventType){
    CAutoLock autoLock(_cancelLock);
    if (GetHttpConnectionState() != HttpStateIsDoing) {
        NSLog(@"请求已经被结束");
        return;
    }
    assert(stream == _readStream);
    switch(eventType) {
        case kCFStreamEventOpenCompleted:
            HandleOpenCompletedEvent(stream);
            break;
        case kCFStreamEventHasBytesAvailable:
            HandleHasBytesAvailableEvent(stream);
            break;
        case kCFStreamEventErrorOccurred:
            HandleErrorOccurredEvent(stream);
            break;
        case kCFStreamEventEndEncountered:
            HandleEndEncounteredEvent(stream);
            break;
    }
}

#pragma mark - callback
void HttpConnection::Perform(void *info){
    ((HttpConnection*)info)->HandleCompletePerform();
}

void HttpConnection::HttpConnectionCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo){
    ((HttpConnection*)clientCallBackInfo)->HandleHttpConnectionCallBack(stream, eventType);
}

void HttpConnection::TimerCallBack(CFRunLoopTimerRef timer,void *info){
    ((HttpConnection*)info)->HandleTimeOut();
}

#pragma mark - NetIOEngine
CFRunLoopRef HttpConnection::GetNetIOEngineRunloop(){
    if (!HttpConnection::_runloop) {
        HttpConnection::_ioEnginelock.Lock();
        if (!HttpConnection::_runloop) {
            pthread_create(&HttpConnection::_IOEngine, 0, HttpConnection::NetIOEngineThread, 0);
            while (!HttpConnection::_runloop)//wait for start
                usleep(1);
        }
        HttpConnection::_ioEnginelock.Unlock();
    }
    return HttpConnection::_runloop;
}

void* HttpConnection::NetIOEngineThread(void* param){
    NSAutoreleasePool* pool0 = [[NSAutoreleasePool alloc]init];
    // keep the runloop from exiting
	CFRunLoopSourceContext context = {0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL};
	CFRunLoopSourceRef source = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), source, HttpRunLoopMode);
    HttpConnection::_runloop = CFRunLoopGetCurrent();
    
    //CFTimeInterval interval = CFDateGetTimeIntervalSinceDate((CFDateRef)[NSDate distantFuture],
                                   //(CFDateRef)[NSDate date]);
    while (1) {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        CFRunLoopRun();
//        unsigned long ret = CFRunLoopRunInMode(HttpRunLoopMode,interval,NO);
//        if(ret == kCFRunLoopRunStopped){
//            [pool release];
//            break;
//        }
        [pool release];
    }
    
	CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, HttpRunLoopMode);
	CFRelease(source);
    [pool0 release];
    return 0;
}

#pragma mark - property
void HttpConnection::ConfigureProxy(CFHTTPMessageRef request, CFReadStreamRef readStream){
    if (_isPacFileRequest) {
        return;
    }
    
    NSArray *proxies = nil;
    NSString* proxyHost = nil;
    int proxyPort = 0;
    NSString* proxyType = nil;
    
#if TARGET_OS_IPHONE
    NSDictionary *proxySettings = [NSMakeCollectable(CFNetworkCopySystemProxySettings()) autorelease];
#else
    NSDictionary *proxySettings = [NSMakeCollectable(SCDynamicStoreCopyProxies(NULL)) autorelease];
#endif
    //proxies = [NSMakeCollectable(CFNetworkCopyProxiesForURL((CFURLRef)[self url], (CFDictionaryRef)proxySettings)) autorelease];
    url = (NSURL*)CFHTTPMessageCopyRequestURL(request);
    proxies = [NSMakeCollectable(CFNetworkCopyProxiesForURL((CFURLRef)url, (CFDictionaryRef)proxySettings)) autorelease];
    
    NSDictionary *settings = [proxies objectAtIndex:0];
    if ([settings objectForKey:(NSString *)kCFProxyAutoConfigurationURLKey]) {
        NSURL* pacFile = [settings objectForKey:(NSString *)kCFProxyAutoConfigurationURLKey];
        try {
            fetchPACFile(pacFile);
        } catch (NSException* ex) {
            NSLog(@"fetchpacFile exception:%@",ex);
        }
        return;
    }
    
    if ([proxies count] > 0) {
        NSDictionary *settings = [proxies objectAtIndex:0];
        proxyHost = [settings objectForKey:(NSString *)kCFProxyHostNameKey];
        proxyPort = [[settings objectForKey:(NSString *)kCFProxyPortNumberKey] intValue];
        proxyType = [settings objectForKey:(NSString *)kCFProxyTypeKey];
//        NSLog(@"obj:%x, http proxy host:%@ port:%d type:%@",(int)this,proxyHost,proxyPort,proxyType);
    }
    
    if (proxyHost && proxyPort) {
		NSString* hostKey;
        NSString* portKey;
        if (!proxyType) {
            proxyType = (NSString*)kCFProxyTypeHTTP;//default
        }
        if ([proxyType isEqualToString:(NSString*)kCFProxyTypeSOCKS]) {
            hostKey = (NSString *)kCFStreamPropertySOCKSProxyHost;
			portKey = (NSString *)kCFStreamPropertySOCKSProxyPort;
        }else{
            hostKey = (NSString *)kCFStreamPropertyHTTPProxyHost;
			portKey = (NSString *)kCFStreamPropertyHTTPProxyPort;
            if ([[[url scheme] lowercaseString] isEqualToString:@"https"]) {
//                NSLog(@"obj:%x, it is https request!",(int)this);
                hostKey = (NSString *)kCFStreamPropertyHTTPSProxyHost;
				portKey = (NSString *)kCFStreamPropertyHTTPSProxyPort;
            }
        }
        NSMutableDictionary *proxyToUse = [NSMutableDictionary dictionaryWithObjectsAndKeys:proxyHost,hostKey,[NSNumber numberWithInt:proxyPort],portKey,nil];
        if ([proxyType isEqualToString:(NSString*)kCFProxyTypeSOCKS]) {
            CFReadStreamSetProperty(readStream, kCFStreamPropertySOCKSProxy, proxyToUse);
        }else{
            CFReadStreamSetProperty(readStream, kCFStreamPropertyHTTPProxy, proxyToUse);
        }
	}
}

void HttpConnection::fetchPACFile(NSURL* pacURL){
    if ([pacURL isFileURL]) {
        NSMutableData* data = [[[NSMutableData alloc] initWithContentsOfURL:pacURL] autorelease];
        NSString* strTmp = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        this->runPACScript(strTmp);
        return;
    }
    NSString *scheme = [[pacURL scheme] lowercaseString];
  	if (![scheme isEqualToString:@"http"] && ![scheme isEqualToString:@"https"]) {
        return;
    }
    HttpParam httpParam;
    if(!httpParam.InitParam([[pacURL absoluteString] UTF8String], "GET")){
        return;
    }
    HttpConnection* pacCon = HttpConnection::CreateHttpConnection(&httpParam);
    pacCon->SetTimeOut(8);
    pacCon->_isPacFileRequest = TRUE;
    int ret = pacCon->SynSendRequest();
    NSData* data = nil;
    if (ret == 0) {
        data = pacCon->GetResponseData();
        NSString* strTmp = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        this->runPACScript(strTmp);
    }
    pacCon->Release();
    pacCon = NULL;
}

void HttpConnection::runPACScript(NSString *pacStr){
    if (!pacStr) {
        return;
    }
    CFRelease(CFNetworkCopyProxiesForURL((CFURLRef)url, NULL));
    
    CFErrorRef err = NULL;
    NSArray *proxies = [NSMakeCollectable(CFNetworkCopyProxiesForAutoConfigurationScript((CFStringRef)pacStr,(CFURLRef)url, &err)) autorelease];
    if (!err && [proxies count] > 0){
        NSDictionary *settings = [proxies objectAtIndex:0];
        
        NSString* proxyHost = [settings objectForKey:(NSString *)kCFProxyHostNameKey];
        int proxyPort = [[settings objectForKey:(NSString *)kCFProxyPortNumberKey] intValue];
        NSString* proxyType = [settings objectForKey:(NSString *)kCFProxyTypeKey];
        
        if (proxyHost && proxyPort) {
            NSString* hostKey;
            NSString* portKey;
            if (!proxyType) {
                proxyType = (NSString*)kCFProxyTypeHTTP;//default
            }
            if ([proxyType isEqualToString:(NSString*)kCFProxyTypeSOCKS]) {
                hostKey = (NSString *)kCFStreamPropertySOCKSProxyHost;
                portKey = (NSString *)kCFStreamPropertySOCKSProxyPort;
            }else{
                hostKey = (NSString *)kCFStreamPropertyHTTPProxyHost;
                portKey = (NSString *)kCFStreamPropertyHTTPProxyPort;
                if ([[[url scheme] lowercaseString] isEqualToString:@"https"]) {
                    hostKey = (NSString *)kCFStreamPropertyHTTPSProxyHost;
                    portKey = (NSString *)kCFStreamPropertyHTTPSProxyPort;
                }
            }
            NSMutableDictionary *proxyToUse = [NSMutableDictionary dictionaryWithObjectsAndKeys:proxyHost,hostKey,[NSNumber numberWithInt:proxyPort],portKey,nil];
            if ([proxyType isEqualToString:(NSString*)kCFProxyTypeSOCKS]) {
                CFReadStreamSetProperty(_readStream, kCFStreamPropertySOCKSProxy, proxyToUse);
            }else{
                CFReadStreamSetProperty(_readStream, kCFStreamPropertyHTTPProxy, proxyToUse);
            }
        }
    }
}

void HttpConnection::SetHttpConnectionState(HttpConnectionState state){
    _httpConState = state;
}

HttpConnectionState HttpConnection::GetHttpConnectionState(){
    return _httpConState;
}

void HttpConnection::SetHttpConnectionRetCode(HttpConnectionRetCode retCode){
    _httpConRetCode = retCode;
}

HttpConnectionRetCode HttpConnection::GetHttpConnectionRetCode(){
    return _httpConRetCode;
}

int HttpConnection::GetResponseStatusCode(){
    return _responseStatus;
}

void HttpConnection::SetTimeOut(int timeOut){
    _timeOut = timeOut;
}

void HttpConnection::SetUpLoadFile(string upLoadFileName){
    _upLoadFileName = upLoadFileName;
}

#pragma mark - notify
void HttpConnection::NotifyHttpConnectionOpenCompleted(){
    if (!_isSyn && _openCB) {
        _openCB(_userData);
    }
}

void HttpConnection::NotifyHttpConnectionHasBytesAvailable(char* buf, int len){
    if (!_isSyn && _hasBytesavailableCB) {
        _hasBytesavailableCB(buf,len,_contentLength,_userData);
    }
}

void HttpConnection::NotifyHttpConnectionErrorOccurred(HttpConnectionRetCode errorNO){
    if (!_isSyn && _errorCB) {
        _errorCB(errorNO, _userData);
    } 
}

void HttpConnection::NotifyHttpConnectionEndEncountered(){
    if (!_isSyn && _endCB) {
        _endCB(_userData);
    } 

}


