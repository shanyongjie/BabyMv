//
//  NetworkConfigure.m
//  RingtoneDuoduo
//
//  Created by misty on 13-10-13.
//  Copyright (c) 2013年 www.ShoujiDuoduo.com. All rights reserved.
//

#import "Reachability.h"
#import "NetworkConfigure.h"

@interface NetworkConfigure ()
@property (nonatomic, retain) Reachability* reachability;
@end

@implementation NetworkConfigure
@synthesize networkType = _networkType;

+ (NetworkConfigure*)sharedInstance
{
    static NetworkConfigure* s_network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_network = [[self alloc] init];
        [s_network startScheduleReachability];
    });

    return s_network;
}

- (void) startScheduleReachability
{
    self.reachability = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetworkConfigureChanged:) name:kReachabilityChangedNotification object:self.reachability];
    [self.reachability startNotifier];
}

- (void) stopScheduleReachability
{
    [self.reachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:self.reachability];
}

- (void) handleNetworkConfigureChanged:(NSNotification*)notification
{
    assert(self.reachability == notification.object);
//    if ([self.reachability isReachableViaWiFi])
//        _networkType = NetworkTypeWiFi;
//    else if ([self.reachability isReachableViaWWAN])
//        _networkType = NetworkTypeWWAN;
//    else
//        _networkType = NetworkTypeNone;

    [[NSNotificationCenter defaultCenter] postNotificationName:kCNotificationNetworkStatusChanged
                                                        object:self
                                                      userInfo:@{@"status":@(_networkType)}];
}

- (NetworkType) networkTypeForFlags:(SCNetworkReachabilityFlags)flags
{
	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
        return NetworkTypeNone;
	}

	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		return NetworkTypeWiFi;
	}

	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        //网络繁忙有可能执行到此。
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            return NetworkTypeWiFi;
        }
    }

	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
        // 3G/GPRS
		return NetworkTypeWWAN;
	}
	return NetworkTypeNone;
}

- (NSString*) networkName
{
    NSString* network = @"";
    switch (_networkType)
    {
        case NetworkTypeNone:
            //network = ""
            break;
        case NetworkTypeWiFi:
            network = @"WiFi";
            break;
        case NetworkTypeWWAN:
            network = @"WWAN";
            break;
        default:
            assert(!"Unexpected network type!");
            break;
    }
    return network;
}

- (BOOL) isNetworkValid
{
    return [self isWiFiNetwork] || [self isWWANNetwork];
}

- (BOOL) isWiFiNetwork
{
    return NetworkTypeWiFi == self.networkType;
}

- (BOOL) isWWANNetwork
{
    return NetworkTypeWWAN == self.networkType;
}

@end
