//
//  PlayerEventHandlerDelegate.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-27.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "BMDataModel.h"
#import "PlayState.h"


@protocol PlayerEventHandlerDelegate
@optional

- (void) onPlayerNowPlayingItemChanged:(id)player;

- (void) onPlayerPlayStateChanged:(id)player;

- (void) onPlayerScheduleChanged:(id)player;

- (void) onPlayerVolumeChanged:(id)player;

- (void) onPlayer:(id)player bufferProgressChanged:(float)progress;

- (void) onPlayer:(id)player
 audioRouteChange:(AudioSessionPropertyID)inPropertyID
propertyValueSize:(UInt32)inPropertyValueSize
    propertyValue:(const void*)inPropertyValue;

- (void) onPlayer:(id)player audioInterruption:(UInt32)interruptionState;

@end
