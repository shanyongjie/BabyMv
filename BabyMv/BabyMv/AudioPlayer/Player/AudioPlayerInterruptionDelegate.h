//
//  AudioPlayerInterruptionDelegate.h
//  RingtoneDuoduo
//
//  Created by misty on 14-1-23.
//  Copyright (c) 2014年 www.ShoujiDuoduo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioPlayerInterruptionDelegate <NSObject>

@optional
- (void)handleAudioSessionInterruption:(UInt32)interruptionState;

@end
