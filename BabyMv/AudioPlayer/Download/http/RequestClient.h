//
//  RequestClient.h
//  dowlandKW
//
//  Created by 刘 强 on 11-4-21.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "HttpConnection.h"
#import "coreCommDefine.h"

@interface OnCompleteParam : NSObject {
NSMutableData* _data;
@public
    int errorNO;
    const char* msg;
    int len;
}
@property (retain,nonatomic)NSMutableData* data;
@end


@interface OnStatusParam : NSObject {
@public
    STATUS status;
}
@end


@interface OnProgressParam : NSObject {
@public
    NSData* _data;
    int len;
    int contentLen;
}
@property(retain,nonatomic)NSData* data;
@end

@protocol MsgCallBack <NSObject>
@required
- (void)onComplete:(OnCompleteParam*)param;

@optional
- (void)onStatus:(OnStatusParam*)param;
- (void)onProgress:(OnProgressParam*)param;
@end


@interface RequestClient : NSObject <MsgCallBack>{
@private
    NSRecursiveLock* _nsLock;
    int _sessionID;
    //char* _buf;
    NSMutableData* _data;
    //uint _sumBytes;
    uint _contentLength;
    BOOL _isFirstFrame;
    volatile BOOL _isCanceled;
@public
    NSMutableDictionary* _headers;
    uint _timeOut;
}
@property(nonatomic,retain)NSMutableDictionary* headers;
@property(nonatomic,assign)uint timeOut;

+ (NSString*)encodeURL:(NSString *)string encoding:(CFStringEncoding)encoding;

- (int)sendRequest:(const char*)reqURL;
+ (int)synSendRequest:(const char*)reqURL method:(const char*)method timeOut:(int)timeOut buf:(const char*)buf len:(int)len response:(NSData**)response;
- (int)postRequest:(const char*)reqURL buf:(const char*)buf len:(int)len;
- (int)postRequest:(const char*)reqURL fileName:(const char*)fileName;
//- (int)postRequestWithMultipartFormData:(NSString*)reqURL//模拟表单上传文件
- (int)postRequestWitFormURLEncoded:(NSString*)reqURL body:(NSMutableDictionary*)body;//模拟表单请求
- (int)cancelRequest;
@end