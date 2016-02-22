//
//  AppConfigure.m
//  Guanying
//
//  Created by mistyzyq on 12-11-8.
//  Copyright (c) 2012年 HuaYing co., Ltd. All rights reserved.
//

#if __has_feature(objc_arc)
#warning This file must be compiled without ARC. Use -fno-objc-arc flag (or convert project to ARC).
#endif

#import "AppConfigure.h"
#import "global.h"
#import "FileHelper.h"
#import "AppInfo.h"
#import "NSStringAdditions.h"
#import "NSString+Util.h"
#import "DeviceInfo.h"

static NSString* KEY_LAST_INSTALL_SOURCE = @"last_install_source";
static NSString* KEY_LAUNCH_FINISHED = @"launch_finished";
static NSString* KEY_ENABLE_REMOTE_NOTIFICATION = @"enable_remote_notification";
static NSString* KEY_AUTO_PLAY_NEXT = @"enable_auto_plly_next";

AppConfigure* SharedConfigure()
{
    return [AppConfigure sharedAppConfigure];
}

@implementation AppConfigure

SYNTHESIZE_SINGLETON_FOR_CLASS(AppConfigure)

- (id) init
{
    self = [super init];
    if (self)
    {
        [self configFileDirectory];
        [self loadConfigure];
        [self configParams];
    }
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

- (void) configFileDirectory
{
	NSString *path = [[NSBundle mainBundle] resourcePath];
	self.appDirectory = path;

    self.bundleDirectory = [[NSBundle mainBundle] bundlePath];

    NSArray* array = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dir = [array objectAtIndex:0];
    self.documentDirectory = dir;
    
    self.sharedDirectory = self.documentDirectory;

    array = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    dir = [array objectAtIndex:0];
    self.cacheDirectory = dir;

	self.tempDirectory = [[NSTemporaryDirectory() copy] autorelease];

    self.logDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"log"];
	CreateDirectory(self.logDirectory);

    self.ringtoneCacheDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"ringtone"];
    CreateDirectory(self.ringtoneCacheDirectory);

    self.databaseDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"db"];
    CreateDirectory(self.databaseDirectory);
    
    self.ringtoneListCacheDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"ringlist"];
    CreateDirectory(self.ringtoneListCacheDirectory);
    
    self.ringtoneDownloadDirectory = [self.cacheDirectory stringByAppendingPathComponent:@"download"];
    CreateDirectory(self.ringtoneDownloadDirectory);
    
    self.sharedRingtoneDownloadDirectory = [self.documentDirectory stringByAppendingPathComponent:@"铃声下载"];
    CreateDirectory(self.sharedRingtoneDownloadDirectory);

    self.customRingtoneDirectory = self.documentDirectory;  //[self.cacheDirectory stringByAppendingPathComponent:@"custom"];
    CreateDirectory(self.customRingtoneDirectory);
}

- (void) configParams
{
}

- (void) setPlayModeType:(PLAY_MODE_TYPE)playModeType
{
    _playModeType = playModeType;
}

- (void) setVideoPlayModeType:(PLAY_MODE_TYPE)videoPlayModeType{
    _videoPlayModeType = videoPlayModeType;
}

- (void) setLyricShow:(BOOL)lyricShow
{
    _lyricShow = lyricShow;
}

- (void) setNLeftSongNum:(int)nLeftSongNum{
    _nLeftSongNum = nLeftSongNum;
}

- (void) setNVideoLeftSongNum:(int)nVideoLeftSongNum{
    _nVideoLeftSongNum = nVideoLeftSongNum;
}

- (void) setEnableRemoteNotification:(BOOL)enable
{
    if (self.enableRemoteNotification != enable)
    {
        _enableRemoteNotification = enable;
        [self saveConfigure];
    }

    UIRemoteNotificationType type = UIRemoteNotificationTypeNone;
    if (enable)
    {
        type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound);
    }
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:type];
}

- (NSString*) installVersion
{
    return GetAppInfo().installVersion;
}

- (NSString*) installSource
{
    return GetAppInfo().installSource;
}

- (NSString*) currentVersion
{
    return GetAppInfo().appVersionString;
}

- (void) setUpgradeVersion:(NSString*)version url:(NSString*)url forced:(BOOL)forced
{
    if (_upgradeVersion != version) [_upgradeVersion release];
    _upgradeVersion = [version copy];

    if (_upgradeURL != url) [_upgradeURL release];
    _upgradeURL = [url copy];

    _forceUpgrade = forced;

    [[NSNotificationCenter defaultCenter] postNotificationName:kCNotificationUpgrade object:self];
}

- (BOOL) hasUpgradeVersion
{
    if (IsEmptyString(self.upgradeVersion))
        return FALSE;

    NSComparisonResult ret = [self.currentVersion versionStringCompare:self.upgradeVersion];
    return NSOrderedAscending == ret;
}

- (BOOL) isFirstLaunch
{
    return ![self.lastInstallSource isEqualToString:self.currentVersion];
}

- (BOOL) shouldShowUserGuid
{
    return self.firstLaunch || !self.launchFinished;
}

- (void) setLaunchFinished:(BOOL)launchFinished
{
    if (!_launchFinished == !launchFinished
        && !self.isFirstLaunch)
        return;

    _launchFinished = launchFinished;

    [_lastInstallSource release];
    _lastInstallSource = [self.currentVersion copy];

    [self saveConfigure];
}

- (void) registerDefaultConfigure
{
    NSMutableDictionary* dictDefault = [NSMutableDictionary dictionaryWithCapacity:8];
    [dictDefault setObject:@"" forKey:KEY_LAST_INSTALL_SOURCE];
    [dictDefault setObject:[NSNumber numberWithBool:NO] forKey:KEY_LAUNCH_FINISHED];
    [dictDefault setObject:[NSNumber numberWithBool:YES] forKey:KEY_ENABLE_REMOTE_NOTIFICATION];
    [dictDefault setObject:[NSNumber numberWithBool:YES] forKey:KEY_AUTO_PLAY_NEXT];
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    [user registerDefaults:dictDefault];
}

- (void) loadConfigure
{
    [self registerDefaultConfigure];

    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    _lastInstallSource = [[user stringForKey:KEY_LAST_INSTALL_SOURCE] copy];
    _launchFinished = [user boolForKey:KEY_LAUNCH_FINISHED];
    _enableRemoteNotification = [user boolForKey:KEY_ENABLE_REMOTE_NOTIFICATION];
    _playModeType = E_PLAY_MODE_SEQUENCE;
    _lyricShow = false;
    _nLeftSongNum = -1;
    
    _playModeType = E_PLAY_MODE_SEQUENCE;
    _nLeftSongNum = -1;
    
    _videoPlayModeType = E_PLAY_MODE_SEQUENCE;
    _nLeftSongNum = -1;
}

- (void) saveConfigure
{
    NSUserDefaults* user = [NSUserDefaults standardUserDefaults];
    [user setObject:self.lastInstallSource forKey:KEY_LAST_INSTALL_SOURCE];
    [user setBool:self.launchFinished forKey:KEY_LAUNCH_FINISHED];
    [user setBool:self.enableRemoteNotification forKey:KEY_ENABLE_REMOTE_NOTIFICATION];
    [user synchronize];
}

@end

const char* GetNetworkName()
{
    return [[NetworkConfigure sharedInstance].networkName UTF8String];
}

const char* GetDeviceType()
{
    return [[DeviceInfo sharedDeviceInfo].platform UTF8String];
}

const char* GetDeviceId()
{
    return [[DeviceInfo sharedDeviceInfo].uuid UTF8String];
}

const char* GetDeviceMacAddress()
{
    return [[DeviceInfo sharedDeviceInfo].macAddr UTF8String];
}

const char* GetOpenUDID()
{
    return [[AppInfo sharedAppInfo].openUDID UTF8String];
}

//const char* GetUserId()
//{
//    if (!g_config)
//        return "";
//    return [g_config->GetUserId() UTF8String];
//}

const char* GetDeviceOSVersion()
{
    return [[DeviceInfo sharedDeviceInfo].systemVersion UTF8String];
}

const char* GetAppVersionString()
{
    return [[AppConfigure sharedAppConfigure].currentVersion UTF8String];
}

NSInteger GetAppVersionCode()
{
    return [AppInfo sharedAppInfo].appVersion;
}

const char* GetAppInstallVersion()
{
    return [[AppConfigure sharedAppConfigure].installVersion UTF8String];
}

const char* GetAppInstallSource()
{
    return [[AppConfigure sharedAppConfigure].installSource UTF8String];
}

bool isIOS7(){
    NSLog(@"%@", [[[UIDevice currentDevice] systemVersion] substringToIndex:2]);
    if (NSOrderedSame == [[[[UIDevice currentDevice] systemVersion] substringToIndex:2]compare:@"7."]) {
        return YES;
    }
    return NO;
}

bool isIOS6(){
    NSLog(@"%@", [[[UIDevice currentDevice] systemVersion] substringToIndex:2]);
    if (NSOrderedSame == [[[[UIDevice currentDevice] systemVersion] substringToIndex:2]compare:@"6."]) {
        return YES;
    }
    return NO;
}
