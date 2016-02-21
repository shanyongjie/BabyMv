//
//  RequestManager.mm
//  dowlandKW
//
//  Created by 刘 强 on 11-4-21.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include "RequestManager.h"
#include "HttpConnection.h"
#import "NetworkConfigure.h" 

RequestManager::RequestManager(){
    _netReqNotifyCB = 0;
    _notifyUserData = 0;
}

RequestManager::~RequestManager(){

}

RequestManager* RequestManager::instance(){
    static RequestManager reqMgr;
    return &reqMgr;
}

void RequestManager::onThreadStart(){
    [[NetworkConfigure sharedInstance] isNetworkValid];
    return;
}

void RequestManager::CancelAllRequest(){
    list<HttpConnection*>::iterator itor;
    for (itor = _httpConnections.begin(); itor != _httpConnections.end(); itor++){
        this->DispatchQueue(*itor, CANCEL);
    }
}

void RequestManager::onRequest(void* reqParam){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    if(!reqParam){
        [pool release];
        return;
    }
    EnqueueParam* ep = (EnqueueParam*)reqParam;
    HttpConnection* HttpConnection = findHttpConnections(ep->httpCon);
    if(!HttpConnection){
         [pool release];
        return;
    }
    switch (ep->reqType) {
        case REQUEST://请求
            onRequestHandleSendRequest(HttpConnection);
            break;
        case CANCEL://取消
            onRequestHandleCancelRequest(HttpConnection);
            break;
        case DESTROY://清除相关资源
            onRequestHandleDestroy(HttpConnection);
            break;
        case POSTDATA://post Data
            onRequestHandlePostData(HttpConnection);
            break;
        case POSTFILE://post file
            onRequestHandlePostFile(HttpConnection);
            break;
        default:
            assert(false);
            break;
    }
    [pool release];
    delete ep;
    ep = NULL;
}

void RequestManager::onThreadEnd(){
}

//interface
int RequestManager::sendRequest(const char* reqURL, const char* method,long timeOut,
                                HttpConnectionOpenCompleted openCB, HttpConnectionHasBytesAvailable progressCB, HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, id obj, void* userData){
    HttpParam httpParam;
    if(!httpParam.InitParam(reqURL, method)){
        return -1;
    }
    //httpParam.SetHeaderFieldValue("Content-Length", "0");
  
    NSEnumerator *enumerator = [obj keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        [obj valueForKey:key];
        httpParam.SetHeaderFieldValue([((NSString*)key) UTF8String], [((NSString*)[obj valueForKey:key]) UTF8String]);
    }
    
    HttpConnection* httpCon = HttpConnection::CreateHttpConnection(&httpParam);
    httpCon->SetTimeOut(timeOut);
    httpCon->SetHttpConnectionCallBack(openCB, progressCB, errorCB, endCB, userData);
    addHttpConnection(httpCon);
    DispatchQueue(httpCon, REQUEST);
    return (long)httpCon;
}

int RequestManager::postRequest(const char* reqURL,  const char* method, long timeOut, const char* buf, int len,
                                HttpConnectionOpenCompleted openCB, HttpConnectionHasBytesAvailable progressCB, HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, id obj, void* userData){
    HttpParam httpParam;
    if(!httpParam.InitParam(reqURL, method)){
        return -1;
    }
    httpParam.SetBody(buf, len);
    char temp[512]={0}; 
    sprintf(temp, "%d",len);
    httpParam.SetHeaderFieldValue("Content-Length", temp);
    NSEnumerator *enumerator = [obj keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        [obj valueForKey:key];
        httpParam.SetHeaderFieldValue([((NSString*)key) UTF8String], [((NSString*)[obj valueForKey:key]) UTF8String]);
    }
    HttpConnection* httpCon = HttpConnection::CreateHttpConnection(&httpParam);;
    httpCon->SetTimeOut(timeOut);
    httpCon->SetHttpConnectionCallBack(openCB, progressCB, errorCB, endCB, userData);
    addHttpConnection(httpCon);
    DispatchQueue(httpCon, POSTDATA);
    return (long)httpCon;
}

int RequestManager::postRequest(const char* reqURL,  const char* method, long timeOut, const char* fileFullName,
                                HttpConnectionOpenCompleted openCB, HttpConnectionHasBytesAvailable progressCB, HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, id obj, void* userData){
    HttpParam httpParam;
    if(!httpParam.InitParam(reqURL, method)){
        return -1;
    }

    FILE* fp = NULL;
    if( (fp = fopen(fileFullName, "r+b")) || 
       (fp = fopen(fileFullName, "r+")) ){
        fseek(fp, 0L, SEEK_END);
        long size = ftell(fp);
        fclose(fp);
        char temp[512]={0};
        sprintf(temp, "%ld",size);
        httpParam.SetHeaderFieldValue("Content-Length", temp);
    }else{
        return -3;
    }
    NSEnumerator *enumerator = [obj keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) {
        [obj valueForKey:key];
        httpParam.SetHeaderFieldValue([((NSString*)key) UTF8String], [((NSString*)[obj valueForKey:key]) UTF8String]);
    }
    HttpConnection* httpCon = HttpConnection::CreateHttpConnection(&httpParam);;
    httpCon->SetTimeOut(timeOut);
    httpCon->SetUpLoadFile(fileFullName);
    httpCon->SetHttpConnectionCallBack(openCB, progressCB, errorCB, endCB, userData);
    addHttpConnection(httpCon);
    DispatchQueue(httpCon, POSTFILE);
    return (long)httpCon;
}

int RequestManager::cancelRequest(int requestID){
    HttpConnection* httpReq = (HttpConnection*)requestID;
    DispatchQueue(httpReq, CANCEL);
    return 0;
}

void RequestManager::DispatchQueue(HttpConnection* httpCon,REQTYPE reqType){
    EnqueueParam* ep = new EnqueueParam;
    ep->reqType = reqType;
    ep->httpCon = httpCon;
    this->dispatch(ep); 
}
//end

//handle onRequest
void RequestManager::onRequestHandleSendRequest(HttpConnection* httpConnection){
    httpConnection->AsynSendRequest();
}

void RequestManager::onRequestHandlePostData(HttpConnection* httpConnection){
    httpConnection->AsynSendRequest();
}

void RequestManager::onRequestHandlePostFile(HttpConnection* httpConnection){
    httpConnection->AsynUpLoadFile();
}

void RequestManager::onRequestHandleDestroy(HttpConnection* httpConnection){
    removeHttpConnection(httpConnection);
}

void RequestManager::onRequestHandleCancelRequest(HttpConnection* httpConnection){
    httpConnection->CanCelRequest();
    removeHttpConnection(httpConnection);
}
//end onReqeust

//list action
HttpConnection* RequestManager::findHttpConnections(HttpConnection* httpConnection){
    CAutoLock autoLock(_lockRequests);
    HttpConnection* ret = 0;//返回值
    list<HttpConnection*>::iterator itor;
    for (itor = _httpConnections.begin(); itor != _httpConnections.end(); ++itor) {
        if (httpConnection == *itor) {
            ret = *itor;
            break;
        }
    }
    return ret;
}

void RequestManager::addHttpConnection(HttpConnection* httpConnection){
    CAutoLock autoLock(_lockRequests);
    _httpConnections.push_back(httpConnection);
}

void RequestManager::removeHttpConnection(HttpConnection* httpConnection){
    CAutoLock autoLock(_lockRequests);
    list<HttpConnection*>::iterator itor;
    for (itor = _httpConnections.begin(); itor != _httpConnections.end(); ++itor) {
        if (httpConnection == *itor) {
             (*itor)->Release();
			_httpConnections.erase(itor);
            break;
        }
    }
}
//end action


void RequestManager::AddObserverForNetRequestNotify(NetRequestNotify notify,void* userData){
    _netReqNotifyCB = notify;
    _notifyUserData = userData;
}

void RequestManager::NotifyForNetRequest(int status){
    if(_netReqNotifyCB)
        _netReqNotifyCB(status,_notifyUserData);
}
