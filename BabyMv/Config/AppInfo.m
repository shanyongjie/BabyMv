//
//  AppInfo.m
//  RingtoneDuoduo
//
//  Created by 2013年 CRI. on 11-8-28.
//  Copyright mistyzyq All rights reserved.
//

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "OpenUDID.h"
#import "DeviceInfo.h"
#import "AppInfo.h"
#import "NSString+Util.h"

#define PRODUCT_TYPE    @"ErGeDD_ip"
#define APP_ID          @"894495836"

AppInfo* GetAppInfo()
{
    return [AppInfo sharedAppInfo];
}

@implementation AppInfo
{
    __strong NSDictionary* _mainBundleDictionary;
    __strong NSString* _installVersion;
    __strong NSString* _installSource;
}

+ (AppInfo*) sharedAppInfo
{
    static AppInfo* s_appInfo = nil;
    if (!s_appInfo)
    {
        s_appInfo = [[AppInfo alloc] init];
        [s_appInfo loadAppInfo];
    }
    return s_appInfo;
}

- (id)init
{
    self = [super init];
    if (self) {
    }

    return self;
}

- (NSDictionary*)mainBundleDictionary
{
    if (!_mainBundleDictionary)
    {
        _mainBundleDictionary = [[NSBundle mainBundle] infoDictionary];
    }
    return _mainBundleDictionary;
}

- (NSInteger) appVersion
{
    return [[self.mainBundleDictionary objectForKey:@"AppVersionCode"] integerValue];
}

- (NSString*) appShortVersionString
{
    return [self.mainBundleDictionary objectForKey:@"CFBundleShortVersionString"];
}

- (NSString*) appVersionString
{
    return [self.mainBundleDictionary objectForKey:@"CFBundleVersion"];
}

- (NSString*) appName
{
    return (NSString*)[self.mainBundleDictionary objectForKey:@"CFBundleExecutable"];
}

- (NSString*) productName
{
    return (NSString*)[self.mainBundleDictionary objectForKey:@"CFBundleDisplayName"];
}

- (NSString*) appStoreDownloadUrl
{
    if (SYSTEM_VERSION_LOWER_THAN(@"7.0")/*NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1*/) {
        return [NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app//id%@?l=zh&ls=1&mt=8", [self appID]];
    } else {
        return [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", [self appID]];
    }
//    return [NSString stringWithFormat:@"items://itunes.apple.com/cn/app//id%@?l=zh&ls=1&mt=8", [self appID]];
}

- (NSString*) appStoreDownloadUrlHttp
{
    if (SYSTEM_VERSION_LOWER_THAN(@"7.0")) {
        return [NSString stringWithFormat:@"http://itunes.apple.com/cn/app//id%@?l=zh&ls=1&mt=8", [self appID]];
    } else {
        return [NSString stringWithFormat:@"http://itunes.apple.com/app/id%@", [self appID]];
    }
//    return [NSString stringWithFormat:@"http://itunes.apple.com/cn/app//id%@?l=zh&ls=1&mt=8", [self appID]];
}

- (NSString*) appStoreAppraiseUrl
{
    if (SYSTEM_VERSION_LOWER_THAN(@"7.0")) {
        return [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", [self appID]];
    } else {
        return [self appStoreDownloadUrl];
    }
}

- (NSString*) appBundleID
{
    return (NSString*)[self.mainBundleDictionary objectForKey:@"CFBundleIdentifier"];
}

- (NSString*) appSechemer
{
    NSArray* urlType = [self.mainBundleDictionary objectForKey:@"CFBundleURLTypes"];
    if (urlType == nil) 
        return @"";
    
    NSDictionary* dict = [urlType objectAtIndex:0];
    if (dict == nil) 
        return @"";
    
    NSArray* arrSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
    
    return [arrSchemes objectAtIndex:0];
}

- (NSString*) appID
{
    return APP_ID;
}

- (NSString*)openUDID
{
    return [OpenUDID value];
}

- (NSString*) installVersion
{
    if (!_installVersion)
    {
//        NSString* majorVersion = (NSString*)[self.mainBundleDictionary objectForKey:@"CFBundleShortVersionString"];
        NSString* versionString = (NSString*)[self.mainBundleDictionary objectForKey:@"CFBundleVersion"];
        _installVersion = [NSString stringWithFormat:@"%@_%@", PRODUCT_TYPE, versionString];
    }
    // RingDD_1.0.0.1
    return _installVersion;
}

- (NSString*) installSource
{
    if (!_installSource)
    {
        NSMutableString* source = [self.installVersion mutableCopy];
        NSString* bdName = self.bdName;
        if ([bdName length] > 0) {
            [source appendFormat:@"_%@", bdName];
        }
        NSString* packageType = (NSString*)[self.mainBundleDictionary objectForKey:@"CustomPackageType"];
        if ([packageType length] == 0) {
            packageType = @"ipa";
        }
        [source appendFormat:@".%@", packageType];
        _installSource = source;
    }
    // RingDD_1.0.0.1_bdname.ipa
    return _installSource;
}

- (NSString*)bdName
{
    NSString* bdName = (NSString*)[self.mainBundleDictionary objectForKey:@"CustomBDName"];
    if (IsEmptyString(bdName))
    {
#if DEBUG
        bdName = @"";
#else
        bdName = @"";
#endif
    }
    return bdName;
}

- (NSString*)umAppKey
{
    return @"53c6343d56240bd0d90fefa4";
}

- (NSString*)wxAppKey
{
    return @"wxb4cd572ca73fd239";
}

- (NSString*)qqAppKey
{
    return @"100382066";
}

/*
 * 平台	url scheme设置格式
 *
 * 新浪微博	“sina.”+友盟appkey，例如“sina.507fcab25270157b37000010”
 * QQ空间	“tencent“+腾讯QQ互联应用Id，例如“tencent100308348”
 * 微信		“wx”+微信应用appId，例如“wxd9a39c7122aa6516”,微信详细集成步骤参考微信集成方法
 * 手机QQ	“QQ”+腾讯QQ互联应用appId转换成十六进制（不足8位前面补0），例如“QQ05FA957C”。生成十六进制方法：在命令行输入
 * 			echo 'ibase=10;obase=16;您的腾讯QQ互联应用Id'|bc
 * 			，并在QQ互联后台的URL schema中填入此字符串保持一致，手机QQ详细集成步骤参考手机QQ集成方法
 * 来往		Identifier填“Laiwang”，URL Schemes填来往AppId.注意使用来往SDK后，Xcode工程other linker flags需要添加-ObjC参数
 * 易信		易信Appkey，例如“yx35664bdff4db42c2b7be1e29390c1a06”
 * Facebook	默认使用iOS自带的Facebook分享framework，在iOS 6以上有效，若要使用我们提供的facebook分享需要设置“fb”+facebook AppID，例如“fb1440390216179601”，详细集成方法见[集成facebook](#social_facebook)
 */
- (NSString*)sinaShareCallbaclSchemer
{
    return [@"sina." stringByAppendingString:self.umAppKey]; //@"sina.52bfcab756240b305a12bc0c";
}
- (NSString*)wxShareCallbaclSchemer
{
    return self.wxAppKey;//@"wxb4cd572ca73fd239";
}
- (NSString*)qzoneShareCallbaclSchemer
{
    return [@"tencent" stringByAppendingString:self.qqAppKey];//@"tencent100382066";
}
- (NSString*)qqShareCallbaclSchemer
{
    return [NSString stringWithFormat:@"QQ%08X", [self.qqAppKey integerValue]]; //@"QQ05FBB572";
}

- (BOOL) loadAppInfo
{
    return TRUE;
}

@end
