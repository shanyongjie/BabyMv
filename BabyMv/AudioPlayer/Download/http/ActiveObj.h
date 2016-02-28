//
//  ActiveObj.h
//  dowlandKW
//
//  Created by 刘 强 on 11-4-19.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//
#ifndef core_activeObj_h
#define core_activeObj_h

#import <Foundation/Foundation.h>
#include "coreCommDefine.h"
#include <queue>

using namespace std;

class ActiveObj {
private:
    queue<void*> _queue;
    pthread_mutex_t _lock;
    pthread_mutexattr_t _mutexattr;
    pthread_cond_t _notempty; 
    pthread_cond_t _notfull;
    pthread_t _thread;
    volatile bool _isRunning;
private:
    ActiveObj(const ActiveObj& obj);//禁止拷贝
    static void* activeThread(void* param);
    int init();
    void* dequeue();
    void enqueue(void* reqParam);
public:
    ActiveObj();
    virtual ~ActiveObj();
    virtual int start();
    int stop();
    void dispatch(void* reqParam);
    virtual void onThreadStart() = 0;//主动对象线程启动回调
    virtual void onRequest(void* reqParam) = 0;
    virtual void onThreadEnd() = 0;////主动对象线程结束回调
};
#endif