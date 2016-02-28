//
//  AppInfo.h
//  RingtoneDuoduo
//
//  Created by mistyzyq on 11-8-28.
//  Copyright 2013年 CRI. All rights reserved.
//

#import <Foundation/Foundation.h>        

// 1: Android, 2: iOS
#define DEVICE_OS_TYPE 2
//#define DEVICE_OS_TYPE (@"2")

#define APP_CODE @"e3a2d9e9090eb49bc9596cdc94bbc747a4469bbd39548e98c718ac4a0a1f9b4b"

@interface AppInfo : NSObject

@property (nonatomic, readonly) NSDictionary* mainBundleDictionary;
@property (nonatomic, readonly) NSInteger   appVersion;
@property (nonatomic, readonly) NSString    *appShortVersionString;
@property (nonatomic, readonly) NSString    *appVersionString;
@property (nonatomic, readonly) NSString    *appName;
@property (nonatomic, readonly) NSString    *productName;
@property (nonatomic, readonly) NSString    *appStoreDownloadUrl;
@property (nonatomic, readonly) NSString    *appStoreDownloadUrlHttp;
@property (nonatomic, readonly) NSString    *appStoreAppraiseUrl;
@property (nonatomic, readonly) NSString    *bundleID;
@property (nonatomic, readonly) NSString    *appSechemer;
@property (nonatomic, readonly) NSString    *appID;

@property (nonatomic, readonly) NSString    *openUDID;

@property (nonatomic, readonly) NSString    *installVersion;    // include product_version
@property (nonatomic, readonly) NSString    *installSource;     // include product_version_bd.ipa
@property (nonatomic, readonly) NSString    *bdName;    // 渠道名称

@property (nonatomic, readonly) NSString    *umAppKey;      // 友盟 App Key
@property (nonatomic, readonly) NSString    *wxAppKey;      // 微信
@property (nonatomic, readonly) NSString    *qqAppKey;   // QZone

@property (nonatomic, readonly) NSString    *sinaShareCallbaclSchemer;      // 微博
@property (nonatomic, readonly) NSString    *wxShareCallbaclSchemer;      // 微信
@property (nonatomic, readonly) NSString    *qzoneShareCallbaclSchemer;   // QZone
@property (nonatomic, readonly) NSString    *qqShareCallbaclSchemer;   // QQ

+ (AppInfo*) sharedAppInfo;

@end

__BEGIN_DECLS

AppInfo* GetAppInfo();

__END_DECLS
