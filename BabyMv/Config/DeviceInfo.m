//
//  DeviceInfo.m
//  RingtoneDuoduo
//
//  Created by 2013年 CRI. on 11-8-28.
//  Copyright mistyzyq All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "device.h"
#import "DeviceInfo.h"
#import "NSStringAdditions.h"
#import "global.h"
#import "common.h"

DeviceInfo* GetDeviceInfo()
{
    return [DeviceInfo sharedDeviceInfo];
}

static BOOL CreateUserUUID(char uuid[64])
{
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFUUIDBytes uuidBytes = CFUUIDGetUUIDBytes(uuidRef);
    GetHexString(uuid, &uuidBytes, sizeof(uuidBytes));
    CFRelease(uuidRef);
    return TRUE;
}

@implementation DeviceInfo

SYNTHESIZE_SINGLETON_FOR_CLASS(DeviceInfo)

@synthesize isSupportCamera = _isSupportCamera;
@synthesize radioAccessTechnology = _radioAccessTechnology;

- (id) init
{
    self = [super init];
    if (self)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _isSupportCamera = YES;
        } else {
            _isSupportCamera = NO;
        }

        if ([CTTelephonyNetworkInfo instancesRespondToSelector:@selector(currentRadioAccessTechnology)])
        {
            CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
            [NSNotificationCenter.defaultCenter addObserverForName:CTRadioAccessTechnologyDidChangeNotification
                                                            object:nil
                                                             queue:nil
                                                        usingBlock:^(NSNotification *notification)
             {
                 NSLog(@"New Radio Access Technology: %@", telephonyInfo.currentRadioAccessTechnology);
                 _radioAccessTechnology = telephonyInfo.currentRadioAccessTechnology;
             }];
        }
        else
        {
            _radioAccessTechnology = nil;
        }
    }
    
    return self;
}

- (NSString*) systemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

- (NSString *) uniqueId
{
//    NSString* uniqueId = [UIDevice currentDevice].uniqueIdentifier;
//    return uniqueId;
    return @"";
}

- (NSString*) macAddr
{
    char szMA[16] = {0};
    GetMacAddressHexString(szMA);
    return [NSString stringWithUTF8String:szMA];
}

- (NSString*) macAddrHash32
{
    return [self.macAddr md5Hash];
}

- (NSString*) macAddrHash16
{
    return [self.macAddrHash32 substringWithRange:NSMakeRange(8, 16)];
}

- (NSString*) uuid
{
    static NSString* uuid_key = @"device_uuid";
    NSString* uuid = [[NSUserDefaults standardUserDefaults] objectForKey:uuid_key];
    if ([uuid length] == 0) {
//        uuid = [NSString stringWithUUID];
        char szUUID[64] = {0};
        CreateUserUUID(szUUID);
        uuid = [NSString stringWithUTF8String:szUUID];
        [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:uuid_key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return uuid;
}

- (NSString*) carrierName
{
    CTTelephonyNetworkInfo* netInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier* carrier = [netInfo subscriberCellularProvider];
    NSString* cellularName = [[[carrier carrierName] retain] autorelease];
    return cellularName ? cellularName : @"";
}

- (NSString*)networkType
{
    NSString* network = @"";
//    if (self.radioAccessTechnology) {
//        network = [self networkTypeFromRadioAccessTechnology];
//    } else {
//        network = [self newtworkTypeFromStatusBar];
//        if ([network length] == 0) {
//            network = [self networkTypeFromNetworkMonitor];
//        }
//    }
    return network;
}

- (NSString*)networkTypeFromRadioAccessTechnology
{
    NSString* network = @"";

    if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        network = @"GPRS";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        network = @"EDGE";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        network = @"WCDMA";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        network = @"HSDPA";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        network = @"HSUPA";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        network = @"CDMA1x";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        network = @"CDMAEVDORev0";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        network = @"HSUPA";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        network = @"CDMAEVDORevA";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        network = @"HRPD";
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        network = @"LTE";
    }
    return network;
}

- (NSString*) networkTypeFromNetworkMonitor
{
    NSString* network = @"";
    // @"/System/Library/PrivateFrameworks/SoftwareUpdateServices.framework"
    NSString* path = [NSString stringWithFormat:@"/Sys%@ary/%@%@/%@Update%@s%@ork", @"tem/Libr", @"Private", @"Frameworks", @"Software", @"Service", @".framew"];
    NSBundle* bundle = [NSBundle bundleWithPath:path];
//    if ([bundle load])
//    {
//        id monitor = [[[fuzzClass(@"%@Network%@", @"SU", @"Monitor") alloc] init] autorelease];
//        unsigned int type = (int)objc_msgSend(monitor, fuzz(@"current%@Type", @"Network"));
//        NSString* networkTypes[] = {
//            @"NO DATA", @"WIFI", @"GPRS/EDGE", @"3G", @"4G",
//        };
//        if (type < ARRAYSIZE(networkTypes)) {
//            network = networkTypes[type];
//        }
//    }
    return network;
}

- (NSString*)newtworkTypeFromStatusBar
{
    NSString* network = @"";
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;

    for (id subview in subviews) {
        if([subview isKindOfClass:[fuzzClass(@"UI%@DataNet%@View", @"StatusBar", @"workItem") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }

    int type = [[dataNetworkItemView valueForKey:[NSString stringWithFormat:@"data%@ype", @"NetworkT"]] integerValue];
    NSString* networkTypes[] = {
        @"NO DATA", @"2G", @"3G", @"4G", @"LTE", @"WiFi",
    };
    if (type < ARRAYSIZE(networkTypes)) {
        network = networkTypes[type];
    }
    return network;
}

- (NSString*) isoCountryCode
{
    CTTelephonyNetworkInfo* netInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier* carrier = [netInfo subscriberCellularProvider];
    NSString *isocc = [carrier isoCountryCode];
    return isocc ? isocc : @"";
}

- (NSString*) mobileCountryCode
{
    CTTelephonyNetworkInfo* netInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier* carrier = [netInfo subscriberCellularProvider];
    NSString *mcc = [carrier mobileCountryCode];
    return mcc ? mcc : @"";
}

- (NSString*) mobileNetworkCode
{
    CTTelephonyNetworkInfo* netInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier* carrier = [netInfo subscriberCellularProvider];
    NSString *mnc = [carrier mobileNetworkCode];
    return mnc ? mnc : @"";
}

- (BOOL)isCMCCNetwork
{
    NSString* mnc = [self mobileNetworkCode];
    return [@"00" isEqualToString:mnc]
        || [@"02" isEqualToString:mnc]
        || [@"07" isEqualToString:mnc];
}

- (BOOL)isFastConnection
{
    if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
        return NO;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
        return NO;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return YES;
    } else if ([self.radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        return YES;
    }

    return YES;
}

- (BOOL) loadDeviceInfo
{
    return TRUE;
}

@end
