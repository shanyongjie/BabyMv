//
//  RequestManager.h
//  dowlandKW
//
//  Created by 刘 强 on 11-4-21.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//
#ifndef core_requestManager_h
#define core_requestManager_h

#include "ActiveObj.h"
#include "coreCommDefine.h"
#include "HttpConnection.h"
#import "AutoLock.h"
#include <list>
using namespace std;

class RequestParam;

class EnqueueParam{
public:
    EnqueueParam(){
        httpCon = 0;
        reqType = REQUNkNOW;
    }
    REQTYPE reqType;
    HttpConnection* httpCon;
};

class RequestManager : public ActiveObj
{
public:
    virtual ~RequestManager();
private:
    RequestManager();
    RequestManager(const RequestManager& requestManager);
    list<HttpConnection*> _httpConnections;
private:
    NetRequestNotify _netReqNotifyCB;
    void* _notifyUserData;
    CLock _lockRequests;
    
    void onRequestHandleSendRequest(HttpConnection* httpConnection);
    void onRequestHandleCancelRequest(HttpConnection* httpConnection);
    void onRequestHandleDestroy(HttpConnection* httpConnection);
    void onRequestHandlePostData(HttpConnection* httpConnection);
    void onRequestHandlePostFile(HttpConnection* httpConnection);
    
    HttpConnection* findHttpConnections(HttpConnection* httpConnection);
    void addHttpConnection(HttpConnection* httpConnection);
    void removeHttpConnection(HttpConnection* httpConnection);
    
public:
    static RequestManager* instance();
    virtual void onThreadStart();//主动对象线程启动回调
    virtual void onRequest(void* reqParam);//主动对象线程
    virtual void onThreadEnd();////主动对象线程结束回调
    
    //interface
    int sendRequest(const char* reqURL, const char* method,long timeOut,
                    HttpConnectionOpenCompleted openCB, HttpConnectionHasBytesAvailable progressCB, HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, id obj,void* userData);
    
    int postRequest(const char* reqURL,  const char* method, long timeOut, const char* buf, int len,
                    HttpConnectionOpenCompleted openCB, HttpConnectionHasBytesAvailable progressCB, HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, id obj, void* userData);
    
    int postRequest(const char* reqURL,  const char* method, long timeOut, const char* fileFullName,
                    HttpConnectionOpenCompleted openCB, HttpConnectionHasBytesAvailable progressCB, HttpConnectionErrorOccurred errorCB, HttpConnectionEndEncountered endCB, id obj, void* userData);
    
    void DispatchQueue(HttpConnection* httpCon,REQTYPE reqType);
    int cancelRequest(int requestID);
    void CancelAllRequest();
    //end interface
    
    void AddObserverForNetRequestNotify(NetRequestNotify notify,void* userData);
    void NotifyForNetRequest(int status);//1:开始 2:成功 3:失败
};
#endif