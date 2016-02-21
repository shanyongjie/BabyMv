//
//  HttpParam.h
//  KWPlayer
//
//  Created by vieri122 on 11-11-2.
//  Copyright (c) 2011年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#ifndef KWPlayer_HttpParam_h
#define KWPlayer_HttpParam_h

#import <Foundation/Foundation.h>

class HttpParam{
private:
    CFHTTPMessageRef _request;
    HttpParam(const HttpParam &obj);
public:
    HttpParam();
    ~HttpParam();
    bool InitParam(const char* url, const char* requestMethod, bool is1_1Version = true);
    void SetHeaderFieldValue(const char* filed, const char* value);
    void SetBody(const char* buf, int len);
public://property
    CFHTTPMessageRef GetRequestParam();
};

#endif
