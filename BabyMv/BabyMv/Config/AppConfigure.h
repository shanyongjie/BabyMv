//
//  AppConfigure.h
//  Guanying
//
//  Created by mistyzyq on 12-11-8.
//  Copyright (c) 2012年 HuaYing co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkConfigure.h"
#import "global.h"

typedef enum : NSUInteger {
    E_PLAY_MODE_SEQUENCE,
    E_PLAY_MODE_SINGLE_RING,
    E_PLAY_MODE_TWO,
    E_PLAY_MODE_FIVE,
    E_PLAY_MODE_TEN
} PLAY_MODE_TYPE;

@interface AppConfigure : NSObject

DECLARE_SINGLETON_FOR_CLASS(AppConfigure)

#pragma mark - Directories
@property (nonatomic, copy) NSString* appDirectory;
@property (nonatomic, copy) NSString* bundleDirectory;
@property (nonatomic, copy) NSString* documentDirectory;
@property (nonatomic, copy) NSString* sharedDirectory;  // same as documentDirectory
@property (nonatomic, copy) NSString* cacheDirectory;
@property (nonatomic, copy) NSString* tempDirectory;

@property (nonatomic, copy) NSString* logDirectory;
@property (nonatomic, copy) NSString* databaseDirectory;
@property (nonatomic, copy) NSString* ringtoneListCacheDirectory;
@property (nonatomic, copy) NSString* ringtoneDownloadDirectory;
@property (nonatomic, copy) NSString* sharedRingtoneDownloadDirectory;
@property (nonatomic, copy) NSString* ringtoneCacheDirectory;

@property (nonatomic, copy) NSString* customRingtoneDirectory;

@property (nonatomic, readonly) NSString* installVersion;   // include product_version
@property (nonatomic, readonly) NSString* installSource;    // include product_version_bd.ipa
@property (nonatomic, readonly) NSString* lastInstallSource;    // include product_version_bd.ipa

@property (nonatomic, readonly) NSString* currentVersion;

@property (nonatomic, readonly) NSString* upgradeVersion;
@property (nonatomic, readonly) NSString* upgradeURL;
@property (nonatomic, readonly) BOOL forceUpgrade;

//@property (nonatomic, readonly) NSString* deviceIdentifier;

@property (nonatomic, readonly, getter=isFirstLaunch) BOOL firstLaunch;
@property (nonatomic, getter=isLaunchFinished) BOOL launchFinished;

#pragma mark - App configures

@property (nonatomic) PLAY_MODE_TYPE playModeType;
@property (nonatomic) int nLeftSongNum;
@property (nonatomic) BOOL lyricShow;
@property (nonatomic) BOOL enableRemoteNotification;

@property (nonatomic) PLAY_MODE_TYPE videoPlayModeType;
@property (nonatomic) int nVideoLeftSongNum;

- (BOOL) shouldShowUserGuid;

- (void) setUpgradeVersion:(NSString*)version url:(NSString*)url forced:(BOOL)forced;
- (BOOL) hasUpgradeVersion;

@end


__BEGIN_DECLS

AppConfigure* SharedConfigure();

const char* GetNetworkName();
#define NETWORK_NAME GetNetworkName()

const char* GetDeviceType();
#define DEVICE_TYPE GetDeviceType()

const char* GetDeviceId();
#define DEVICE_ID GetDeviceId()

const char* GetDeviceMacAddress();
#define DEVICE_MAC_ADDR GetDeviceMacAddress()

const char* GetOpenUDID();
#define OPEN_UDID GetOpenUDID()

//const char* GetUserId();
//#define USER_ID GetUserId()
#define USER_ID GetOpenUDID()

const char* GetDeviceOSVersion();
#define DEVICE_OS_VERSION   GetDeviceOSVersion()

const char* GetAppVersionString();
#define APP_VERSION_STRING     GetAppVersionString()

NSInteger GetAppVersionCode();
#define APP_VERSION_CODE     GetAppVersionCode()

const char* GetAppInstallVersion();
#define APP_INSTALL_VERSION	GetAppInstallVersion()

const char* GetAppInstallSource();
#define APP_INSTALL_SOURCE	GetAppInstallSource()

bool isIOS7();
bool isIOS6();

__END_DECLS
