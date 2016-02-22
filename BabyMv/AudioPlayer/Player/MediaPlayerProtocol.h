//
//  KuwoMusicPlayer.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-24.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMDataModel.h"
#import "PlayState.h"
#import "PlayerEventHandlerDelegate.h"

@protocol MediaPlayerProtocol <NSObject>

@property (nonatomic, copy) BMListDataModel* mediaItemInfo;
@property (nonatomic, assign) id<PlayerEventHandlerDelegate> playerEventHandler;

@property (nonatomic, readonly) NSTimeInterval schedule;
@property (nonatomic, readonly) NSTimeInterval duration;

@property (nonatomic, readonly) PlayState playState;

@property (nonatomic, readonly) float progress;
@property (nonatomic, readonly) float cacheRate;

@property (nonatomic, assign) float volume;

- (BOOL) isPlaying;
- (BOOL) isBuffering;

- (void) setMediaItemInfo:(BMListDataModel*)itemInfo;

- (void) play;
- (void) pause;
- (void) stop;

- (BOOL) seek:(NSTimeInterval)schedule;

@optional
- (void)handleAudioSessionInterruption:(UInt32)interruptionState;

@end
