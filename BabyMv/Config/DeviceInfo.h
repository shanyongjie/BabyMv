//
//  DeviceInfo.h
//  RingtoneDuoduo
//
//  Created by 2013年 CRI. on 11-8-28.
//  Copyright mistyzyq All rights reserved.
//
//
#import <Foundation/Foundation.h>
#import "global.h"
#import <UIKit/UIKit.h>
//#import "UIDevice-IOKitExtensions.h"
//#import "UIDevice-Reachability.h"

@interface DeviceInfo : UIDevice

DECLARE_SINGLETON_FOR_CLASS(DeviceInfo)

@property (nonatomic, readonly) NSString *platform;
@property (nonatomic, readonly) NSString *systemVersion;

@property (nonatomic, readonly) NSString *uniqueId;
@property (nonatomic, readonly) NSString *macAddr;
@property (nonatomic, readonly) NSString *macAddrHash32;
@property (nonatomic, readonly) NSString *macAddrHash16;
@property (nonatomic, readonly) NSString *uuid;

@property (nonatomic, readonly) NSString *carrierName;
@property (nonatomic, readonly) NSString* radioAccessTechnology;    // iOS7
@property (nonatomic, readonly) NSString* networkType;              // Use Private API

// http://en.wikipedia.org/wiki/ISO_3166-1
@property (nonatomic, readonly) NSString * isoCountryCode;

// MCC
// 中国为460
@property (nonatomic, readonly) NSString *mobileCountryCode;

// MNC, http://en.wikipedia.org/wiki/Mobile_country_code
// 00   China Mobile
// 01   China Unicom
// 02   China Mobile
// 03   China Telecom
// 05   China Telecom
// 06   China Unicom
// 07   China Mobile
// 20   China Tietong
@property (nonatomic, readonly) NSString *mobileNetworkCode;

@property (nonatomic, readonly) BOOL isSupportCamera;

@property (nonatomic, readonly) BOOL isFastConnection;  // iOS7

- (BOOL)isCMCCNetwork;  // 移动
//- (BOOL)isCUCCNetwork;  // 联通
//- (BOOL)isCTCCNetwork;  // 电信

@end

__BEGIN_DECLS

DeviceInfo* GetDeviceInfo();

__END_DECLS

// e.g. SYSTEM_VERSION_HIGHER_THAN_OR_QEUAL_TO(@"4.1.3")
#define SYSTEM_VERSION_EQUAL_TO(version)                    ([[[UIDevice currentDevice] systemVersion] compare:(version) options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_HIGHER_THAN(versoin)                 ([[[UIDevice currentDevice] systemVersion] compare:(version) options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_HIGHER_THAN_OR_EQUAL_TO(version)     ([[[UIDevice currentDevice] systemVersion] compare:(version) options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LOWER_THAN(version)                  ([[[UIDevice currentDevice] systemVersion] compare:(version) options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LOWER_THAN_OR_EQUAL_TO(version)      ([[[UIDevice currentDevice] systemVersion] compare:(version) options:NSNumericSearch] != NSOrderedDescending)

// e.g. FOUNDATION_VERSION_HIGHER_THAN(NSFoundationVersionNumber_iOS_6_1)
// NOTE: systems with different version could have same foundation version.
#define FOUNDATION_VERSION_EQUAL_TO(version)                (NSFoundationVersionNumber == (version))
#define FOUNDATION_VERSION_HIGHER_THAN(version)             (NSFoundationVersionNumber > (version))
#define FOUNDATION_VERSION_HIGHER_THAN_OR_EQUAL_TO(version) (NSFoundationVersionNumber >= (version))
#define FOUNDATION_VERSION_LOWER_THAN(version)              (NSFoundationVersionNumber < (version))
#define FOUNDATION_VERSION_LOWER_THAN_OR_EQUAL_TO(version)  (NSFoundationVersionNumber <= (version))
