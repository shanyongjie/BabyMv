//
//  ActiveObj.cpp
//  dowlandKW
//
//  Created by 刘 强 on 11-4-19.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include "ActiveObj.h"
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <stdlib.h>
static const int RQUESTQEUESIZE = 255;//请求队列大小

ActiveObj::ActiveObj(){

}

ActiveObj::~ActiveObj(){

}

int ActiveObj::init(){
    int ret = pthread_mutexattr_init(&_mutexattr);
    ret = pthread_mutexattr_settype(&_mutexattr, PTHREAD_MUTEX_RECURSIVE);
    ret = pthread_mutex_init(&_lock, NULL);
    //ret = pthread_mutex_init(&_lock, &_mutexattr);//设置递归锁
    ret = pthread_mutexattr_destroy(&_mutexattr);
    ret = pthread_cond_init(&_notempty, NULL);
    ret = pthread_cond_init(&_notfull, NULL);
    _isRunning = false;
    return ret;
}

int ActiveObj::start(){
    int ret = this->init();
    ret = pthread_create(&_thread, NULL, ActiveObj::activeThread, this);
    while (!_isRunning)//wait for start
        usleep(0);
    return ret;
}

int ActiveObj::stop(){
    _isRunning = false;
    enqueue(0);
    int ret = pthread_join(_thread, 0);
    ret = pthread_cond_destroy(&_notempty);
    ret = pthread_cond_destroy(&_notfull);
    ret = pthread_mutex_destroy(&_lock);
    return ret;
}

void ActiveObj::dispatch(void *reqParam){
    enqueue(reqParam);
}

void* ActiveObj::activeThread(void* param){
    ActiveObj* pThis = (ActiveObj*)param;
    pThis->onThreadStart();
    pThis->_isRunning = true;
    while (pThis->_isRunning) {
        void* ret = pThis->dequeue();
        pThis->onRequest(ret);
    }
    pThis->onThreadEnd();
    return 0;
}

void ActiveObj::enqueue(void* reqParam){
    pthread_mutex_lock(&_lock);
    while (_queue.size() >= RQUESTQEUESIZE) {
        pthread_cond_wait(&_notfull, &_lock);//在此处一直等待直到队列没满的时候返回
        usleep(1000*100);//请求太多,稍等一会。
    }
    _queue.push(reqParam);
    pthread_cond_signal(&_notempty);
    pthread_mutex_unlock(&_lock);
}

void* ActiveObj::dequeue(){
    pthread_mutex_lock(&_lock);
    while (_queue.empty()) {
        pthread_cond_wait(&_notempty, &_lock);//在此处一直等待直到队列不为空的时候返回
    }
    void* ret = _queue.front();
    _queue.pop();
    pthread_cond_signal(&_notfull);
    pthread_mutex_unlock(&_lock);
    return ret;
}