//
//  HttpConnection.h
//  KWPlayer
//
//  Created by vieri122 on 11-11-2.
//  Copyright (c) 2011年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#ifndef KWPlayer_HttpConnection_h
#define KWPlayer_HttpConnection_h

#include <CFNetwork/CFNetwork.h>
#include "HttpParam.h"
#include "coreCommDefine.h"
#include <string>
#import "AutoLock.h"
using namespace std;

typedef enum { 
    HttpStateNotStart = 0,//未开始
    HttpStateIsDoing,//正在进行
//    HttpUserCancel,//用户主动取消
//    HttpTimeOut,//超时
//    HttpError,//error
    HttpStateComplete,//完成
}HttpConnectionState;



class HttpConnection{
private:
    HttpConnection(HttpParam* httpParam);
    virtual ~HttpConnection();
    
private:
    static CFRunLoopRef _runloop;
    static pthread_t _IOEngine;
    static CLock _ioEnginelock;
    
    HttpConnectionOpenCompleted _openCB;
    HttpConnectionHasBytesAvailable _hasBytesavailableCB; 
    HttpConnectionErrorOccurred _errorCB;
    HttpConnectionEndEncountered _endCB;
    void* _userData;
    
    NSMutableData* _data;
    int _timeOut;
    CFHTTPMessageRef _request;
    CFHTTPMessageRef _httpResponse;
    CFReadStreamRef _readStream;//
    unsigned long long _postLength;
    unsigned long long _totalBytesSent;
    unsigned long long _lastBytesSent;
    volatile int _refCount;
    time_t _activeTime;
    CLock _cancelLock;
    CFRunLoopTimerRef _timer;
    HttpConnectionState _httpConState;
    HttpConnectionRetCode _httpConRetCode;
    bool _isFirstFrame;
    int _responseStatus;
    long _contentLength;
    bool _isSyn;
    CFRunLoopSourceRef _source;
    string _upLoadFileName;
    
    NSURL* url;
    BOOL _isPacFileRequest;
private:
    static void HttpConnectionCallBack(CFReadStreamRef stream,CFStreamEventType eventType,void *clientCallBackInfo);
    static void TimerCallBack(CFRunLoopTimerRef timer,void *info);
    static void* NetIOEngineThread(void* param);
    static void Perform(void *info);
    static CFRunLoopRef GetNetIOEngineRunloop();
    
    void HandleHttpConnectionCallBack(CFReadStreamRef stream,CFStreamEventType eventType);
    void HandleOpenCompletedEvent(CFReadStreamRef stream);
    void HandleHasBytesAvailableEvent(CFReadStreamRef stream);
    void HandleErrorOccurredEvent(CFReadStreamRef stream);
    void HandleEndEncounteredEvent(CFReadStreamRef stream);
    void HandleRemoteServerErrorEvent(CFReadStreamRef stream,HttpConnectionRetCode retCode);
    void HandleTimeOut();
    void HandleCompletePerform();
    //notify
    void NotifyHttpConnectionOpenCompleted();
    void NotifyHttpConnectionHasBytesAvailable(char* buf, int len);
    void NotifyHttpConnectionErrorOccurred(HttpConnectionRetCode errorNO);
    void NotifyHttpConnectionEndEncountered();
    
    int BaseAsynSendRequest();
    
    void DestroyRequest();
    
    void ConfigureProxy(CFHTTPMessageRef request,CFReadStreamRef readStream);
    void fetchPACFile(NSURL* pacURL);
    void runPACScript(NSString* pacStr);
private:
    //property
    void SetHttpConnectionState(HttpConnectionState state);
    void SetHttpConnectionRetCode(HttpConnectionRetCode retCode);
public:
    //property
    HttpConnectionState GetHttpConnectionState();
    HttpConnectionRetCode GetHttpConnectionRetCode();
    int GetResponseStatusCode();
    void SetTimeOut(int timeOut);
    void SetUpLoadFile(string upLoadFileName);
public:
    static HttpConnection* CreateHttpConnection(HttpParam* httpParam);
    int AddRef();
    int Release();
    int GetRef();
    int SynSendRequest();
    NSData* GetResponseData();
    int AsynSendRequest();
    int AsynUpLoadFile();
    void CanCelRequest();
    void SetHttpConnectionCallBack(HttpConnectionOpenCompleted openCompletedCB, HttpConnectionHasBytesAvailable availableDataCB, HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, void* userData);
};

#endif
