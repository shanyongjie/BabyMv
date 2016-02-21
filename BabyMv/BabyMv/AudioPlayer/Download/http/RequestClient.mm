//
//  RequestClient.mm
//  dowlandKW
//
//  Created by 刘 强 on 11-4-21.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//
#import "RequestClient.h"
#import "RequestManager.h"
#import <zlib.h>
#import <regex.h>
#import "RegexKitLite.h"

static NSString* httpRegEx = @"\\bhttps?://[a-zA-Z0-9\\-.]+(?:(?:/[a-zA-Z0-9\\-._?,'+\\&%$=~*!():@\\\\]*)+)?";

@implementation OnCompleteParam
@synthesize data = _data;
- (void)dealloc{
    [_data release];
    [super dealloc];
}
@end

@implementation OnProgressParam
@synthesize data = _data;
- (void)dealloc{
    [_data release];
    [super dealloc];
}
@end

@implementation OnStatusParam
- (void)dealloc{
    [super dealloc];
}
@end

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
static void HttpOpenCompletedFun(void* userData);

static void HttpHasBytesAvailableFun(char* buf, int len, uint contentLength,void* userData);

static void HttpErrorOccurredFun(HttpConnectionRetCode errorNO,void* userData);

static void HttpEndEncounteredFun(void* userData);
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@interface RequestClient(PrivateMethod)

- (void)handleHttpOpenCompletedFun;
- (void)handleHttpHasBytesAvailableFun:(const char *)buf len:(int)len contentLen:(int)contentLen;
- (void)handleHttpErrorOccurredFun:(HttpConnectionRetCode)errorNO;
- (void)handleHttpEndEncounteredFun;

- (void)completeOnMainThread:(OnCompleteParam*)param;
- (void)statusOnMainThread:(OnStatusParam*)param;
- (void)progressOnMainThread:(OnProgressParam*)param;

- (void)notifyStatus:(STATUS)status;
- (void)notifyProgress:(const char*)buf len:(int)len contentLen:(int)contentLen;
- (void)notifyResult:(int)errorNO;

@end


@implementation RequestClient
@synthesize headers = _headers;
@synthesize timeOut = _timeOut;
- (id)init{
    self = [super init];
	if (self) {
        _data = nil;
        _isFirstFrame = YES;
        _sessionID = 0;
        _timeOut = 35;
        _nsLock = [[NSRecursiveLock alloc] init];
        _headers = [[NSMutableDictionary alloc] initWithCapacity:64];
    }
    return self;
}

- (void)dealloc{
    [_nsLock release];
    [_headers release];
    [super dealloc];
}

- (int)postRequest:(const char*)reqURL buf:(const char*)buf len:(int)len{
    if (![[NSString stringWithCString:reqURL 
                            encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)] isMatchedByRegex:httpRegEx]) {
        return -2;
    }
    
    if (buf == 0 || len <=0) {
        return -2;
    }
    
    [self cancelRequest]; 
    [_nsLock lock];
    _isCanceled = NO;
    _isFirstFrame = YES;
    _sessionID = RequestManager::instance()->postRequest(reqURL, "POST", self.timeOut, buf, len, HttpOpenCompletedFun,HttpHasBytesAvailableFun,HttpErrorOccurredFun,HttpEndEncounteredFun,self.headers,self);
    [_nsLock unlock];
    return 0;
}

- (int)postRequest:(const char*)reqURL fileName:(const char*)fileName{
    if (![[NSString stringWithCString:reqURL 
                             encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)] isMatchedByRegex:httpRegEx]) {
        return -2;
    }
    
    FILE* fp = NULL;
    if ((fp = fopen(fileName, "r"))) {
        fclose(fp);
    }
    else{
        return -2;
    }
    
    [self cancelRequest];
    [_nsLock lock];
    _isCanceled = NO;
    _isFirstFrame = YES;
    _sessionID = RequestManager::instance()->postRequest(reqURL, "POST", self.timeOut, fileName,HttpOpenCompletedFun,HttpHasBytesAvailableFun,HttpErrorOccurredFun,HttpEndEncounteredFun,self.headers,self);
    [_nsLock unlock];
    return 0;
}

- (int)postRequestWitFormURLEncoded:(NSString*)reqURL body:(NSMutableDictionary*)body{
    if (![reqURL isMatchedByRegex:httpRegEx]) {
        return -2;
    }
    
    [self cancelRequest];
    [_nsLock lock];
    _isCanceled = NO;
    _isFirstFrame = YES;

    NSMutableData* data = [NSMutableData dataWithCapacity:1024];
    NSEnumerator* enumer = [body keyEnumerator];
    
    int index = 0;
    NSUInteger count = [body count]-1;
    id key = nil;
    
    while ((key = [enumer nextObject])) {
        NSString* value = [RequestClient encodeURL:[body objectForKey:key] encoding:NSUTF8StringEncoding];
        NSString* dataStr = [NSString stringWithFormat:@"%@=%@%@",key,value,(index<count ?  @"&" : @"")];
        [data appendData:[dataStr dataUsingEncoding:NSUTF8StringEncoding]];
        index++;
    }
    //NSString* tmp  = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    //NSLog(@"tmp:%@",tmp);
    NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [self.headers setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@",charset] forKey:@"Content-Type"];
    //NSString* reqURLTmp = [RequestClient encodeURL:reqURL encoding:NSUTF8StringEncoding];
    int ret = [self postRequest:[reqURL UTF8String] buf:(const char*)[data bytes] len:[data length]];
    [_nsLock unlock];
    return ret;
}

- (int)sendRequest:(const char*)reqURL{
    if (![[NSString stringWithCString:reqURL 
                             encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)] isMatchedByRegex:httpRegEx]) {
        return -2;
    }
    
    [self cancelRequest];
    [_nsLock lock];
    _isCanceled = NO;
    _isFirstFrame = YES;
    _sessionID = RequestManager::instance()->sendRequest(reqURL, "GET", self.timeOut, 
                                                         HttpOpenCompletedFun, HttpHasBytesAvailableFun,HttpErrorOccurredFun,HttpEndEncounteredFun,self.headers,self);
    [_nsLock unlock];
    return 0;
}

- (int)cancelRequest{
    [_nsLock lock];
    if(_sessionID)
    {
        RequestManager::instance()->cancelRequest(_sessionID);
        _isCanceled = YES;
        [_data release];
        _data = nil;
        _sessionID = 0;
    }
    [_nsLock unlock];
    return 0;
}

+ (NSString*)encodeURL:(NSString *)string encoding:(CFStringEncoding)encoding{
    NSString *newString = [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(encoding))) autorelease];
	if (newString) {
		return newString;
	}
	return nil;
}

//synchronize Request maybe used
+ (int)synSendRequest:(const char*)reqURL method:(const char*)method timeOut:(int)timeOut buf:(const char*)buf len:(int)len response:(NSData**)response{
    int ret = -1;
    HttpParam httpParam;
    if(!httpParam.InitParam(reqURL, method)){
        return ret;
    }
    if (buf) {
        httpParam.SetBody(buf, len);
        char temp[512]={0}; 
        sprintf(temp, "%d",len);
        httpParam.SetHeaderFieldValue("Content-Length", temp);
    }else{
         httpParam.SetHeaderFieldValue("Content-Length", "0");
    }
    HttpConnection* httpConnection = HttpConnection::CreateHttpConnection(&httpParam);
    httpConnection->SetTimeOut(timeOut);
    ret = httpConnection->SynSendRequest();
    NSData* data = nil;
    if (ret == 0) {
        data = httpConnection->GetResponseData();
        [[data retain] autorelease];
    }
    *response = data;
    httpConnection->Release();
    return ret;
}

- (void)onComplete:(OnCompleteParam*)param{
    //子类必须实现此方法 此处显示实现此方法是为了减少一个编译器警告
    NSAssert(NO, @"onComplete not impletement in subClass");
}

#pragma mark - http handle
- (void)handleHttpOpenCompletedFun{
    [_nsLock lock];
    if (_isCanceled){
        [_nsLock unlock];
        return;
    }
    [_nsLock unlock];
    [self notifyStatus:REQUESTCOMPLETE];
}

- (void)handleHttpHasBytesAvailableFun:(const char *)buf len:(int)len contentLen:(int)contentLen{
    [_nsLock lock];
    if (_isCanceled){
        [_nsLock unlock];
        return;
    }
    if (_isFirstFrame) {
        _isFirstFrame = NO;
        [self notifyStatus:READINGDATA];
        _contentLength = contentLen;
//#warning memory leaks, not resolved.
        _data = [[NSMutableData alloc] initWithCapacity:1024];
    }
//#warning memory leaks, not resolved.
    [_data appendBytes:buf length:len];
    [_nsLock unlock];
    [self notifyProgress:buf len:len contentLen:contentLen];
    
}

- (void)handleHttpErrorOccurredFun:(HttpConnectionRetCode)errorNO{
    [_nsLock lock];
    RequestManager::instance()->DispatchQueue((HttpConnection*)_sessionID, DESTROY);
    [self notifyStatus:REQUESTFAILED];
    _sessionID = 0;
    if (_isCanceled) {
        [_nsLock unlock];
        return;
    }
    [_nsLock unlock];
    [self notifyResult:errorNO];
}

- (void)handleHttpEndEncounteredFun{
    [_nsLock lock];
    int ret = 0;
    if (_sessionID) {
        ret = ((HttpConnection*)_sessionID)->GetHttpConnectionRetCode();
    }
    
    NSAssert1(ret == HttpRetOK || ret == HttpRetNotFound, @"ret:%d",ret);
    RequestManager::instance()->DispatchQueue((HttpConnection*)_sessionID, DESTROY);
    [self notifyStatus:READCOMPLETE];
    _sessionID = 0;
    if (_isCanceled) {
        [_nsLock unlock];
        return;
    }
    [_nsLock unlock];
    [self notifyResult:ret];
}

#pragma mark - mianThread
- (void)completeOnMainThread:(OnCompleteParam*)param{
    [_nsLock lock];
    if (!_isCanceled && [self respondsToSelector:@selector(onComplete:)]) {
        NSAssert(!_isCanceled, @"cancel 失效");
        [self onComplete:param];
    };
    [_nsLock unlock];
}

- (void)statusOnMainThread:(OnStatusParam*)param{
    [_nsLock lock];
    if (!_isCanceled && [self respondsToSelector:@selector(onStatus:)]) {
        [self onStatus:param];
    };
    [_nsLock unlock];
}

- (void)progressOnMainThread:(OnProgressParam*)param{;
    [_nsLock lock];
    if (!_isCanceled && [self respondsToSelector:@selector(onProgress:)]) {
        [self onProgress:param];
    };
    [_nsLock unlock];
}

#pragma mark - notify
- (void)notifyStatus:(STATUS)status{
    //    NSLog(@"status %lu",status);
    OnStatusParam* statusParam = [[[OnStatusParam alloc] init] autorelease];
    statusParam->status = status;
    [self performSelectorOnMainThread:@selector(statusOnMainThread:) withObject:statusParam waitUntilDone:NO];
    return;
}

- (void)notifyProgress:(const char*)buf len:(int)len contentLen:(int)contentLen{
    
    OnProgressParam* progress = [[[OnProgressParam alloc] init] autorelease];
    progress.data = [NSData dataWithBytes:buf length:len];
    //这种奇怪的实现方式是为了向前兼容 保证数据类型一致
    progress->len = [progress.data length];
    progress->contentLen = contentLen;
    [self performSelectorOnMainThread:@selector(progressOnMainThread:) withObject:progress waitUntilDone:NO];
    return;
}

- (void)notifyResult:(int)errorNO{
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//#warning memory leaks, not resolved.
    OnCompleteParam* completeParam = [[[OnCompleteParam alloc] init] autorelease];
//    if (errorNO == 3) {
//        completeParam->errorNO = 8;
//    }else{
//        completeParam->errorNO = errorNO;
//    }
    completeParam->errorNO = errorNO;
    if (errorNO && errorNO != 404) {
        completeParam->len = 0;
        completeParam->msg = 0;
    }else{
        completeParam->len = [_data length];
        completeParam.data = _data;
        //这种奇怪的实现方式是为了向前兼容 保证数据类型一致
        completeParam->msg = (const char*)[completeParam.data bytes];
    }
    [_data release];
    _data = nil;
    [self performSelectorOnMainThread:@selector(completeOnMainThread:) withObject:completeParam waitUntilDone:NO];
    return;
    //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
}
//

#pragma mark - HttpFun
static void HttpOpenCompletedFun(void* userData){
    [((RequestClient*)userData) handleHttpOpenCompletedFun];
}

static void HttpHasBytesAvailableFun(char* buf, int len, uint contentLength,void* userData){
    [((RequestClient*)userData) handleHttpHasBytesAvailableFun:buf len:len contentLen:contentLength];
}

static void HttpErrorOccurredFun(HttpConnectionRetCode errorNO,void* userData){
    [((RequestClient*)userData) handleHttpErrorOccurredFun:errorNO];
}

static void HttpEndEncounteredFun(void* userData){
    RequestClient* tmp = (RequestClient*)userData;
    [tmp handleHttpEndEncounteredFun];
}
@end


