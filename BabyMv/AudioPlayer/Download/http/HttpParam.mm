//
//  HttpParam.cpp
//  KWPlayer
//
//  Created by vieri122 on 11-11-2.
//  Copyright (c) 2011年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include "HttpParam.h"

HttpParam::HttpParam(){
    _request = 0; 
}

//HttpParam::HttpParam(const HttpParam &obj){
//    ASSERT(obj._request);
//    _request = CFHTTPMessageCreateCopy(kCFAllocatorDefault, obj._request);
//}

HttpParam::~HttpParam(){
    if (_request) {
        CFRelease(_request);
    }
}

bool HttpParam::InitParam(const char* url, const char* requestMethod, bool is1_1Version/* = true*/){
    assert(_request == 0);
    if (url == nil) {
        return false;
    }
    CFStringRef urlRef = CFStringCreateWithCString(kCFAllocatorDefault,url,
                                                   CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000));
    if (!urlRef) {
        return false;
    }
    
    CFURLRef  myURL = CFURLCreateWithString(kCFAllocatorDefault, urlRef, NULL);
    if (!myURL) {
        CFRelease(urlRef);
        return false;
    }
    
    CFStringRef method = CFStringCreateWithCString(NULL, requestMethod,
                                                   CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000));
    _request = CFHTTPMessageCreateRequest(kCFAllocatorDefault, method, myURL, is1_1Version?kCFHTTPVersion1_1:kCFHTTPVersion1_0);
    if (!_request) {
        CFRelease(urlRef);
        CFRelease(myURL);
        CFRelease(method);
        return false;
    }
    
    CFRelease(urlRef);
    CFRelease(myURL);
    CFRelease(method);
    return true;
}

void HttpParam::SetBody(const char *buf, int len){
    assert(_request != 0);
    CFDataRef data = CFDataCreate(NULL, (const UInt8*)buf, len);
    CFHTTPMessageSetBody(_request, data);
    
    CFRelease(data);
}

void HttpParam::SetHeaderFieldValue(const char *filed, const char *value){
    assert(_request != 0);
    CFStringRef filedStr = CFStringCreateWithCString(kCFAllocatorDefault, filed, 
                                                     CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000));
    CFStringRef valueStr = CFStringCreateWithCString(kCFAllocatorDefault, value, 
                                                     CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000));
    CFHTTPMessageSetHeaderFieldValue(_request, filedStr, valueStr);
    
    CFRelease(filedStr);
    CFRelease(valueStr);
}

CFHTTPMessageRef HttpParam::GetRequestParam(){
    return _request;
}

