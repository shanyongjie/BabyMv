//
//  BSPlayInfo.h
//  BabyMv
//
//  Created by 单永杰 on 16/2/24.
//  Copyright © 2016年 chenjingying. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    E_TIMING_NO,
    E_TIMING_10,
    E_TIMING_20,
    E_TIMING_30,
    E_TIMING_60
} TIMING_TYPE;

typedef enum : NSUInteger {
    E_MODE_RING,
    E_MODE_SEQUENCE,
    E_MODE_SINGLE
} PLAY_MODE_TYPE;

@interface BSPlayInfo : NSObject

+(BSPlayInfo*)sharedInstance;
-(TIMING_TYPE)getTimingType;
-(PLAY_MODE_TYPE)getPlayMode;

@end
