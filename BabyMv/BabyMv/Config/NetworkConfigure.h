//
//  NetworkConfigure.h
//  RingtoneDuoduo
//
//  Created by misty on 13-10-13.
//  Copyright (c) 2013年 www.ShoujiDuoduo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Notification.h"

typedef enum _NetworkType{
	NetworkTypeNone = 0,    // None
	NetworkTypeWiFi,        // WiFi
	NetworkTypeWWAN,        // 3G/GPRS
} NetworkType;

@interface NetworkConfigure : NSObject

@property (nonatomic, readonly) NetworkType networkType;

+ (NetworkConfigure*)sharedInstance;

- (NSString*) networkName;

- (BOOL) isNetworkValid;
- (BOOL) isWiFiNetwork;
- (BOOL) isWWANNetwork;

@end

