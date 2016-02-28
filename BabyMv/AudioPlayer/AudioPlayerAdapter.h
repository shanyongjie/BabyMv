//
//  AudioPlayerAdapter.h
//  RingtoneDuoduo
//
//  Created by misty on 13-11-14.
//  Copyright (c) 2013年 www.ShoujiDuoduo.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayState.h"
#import "AudioPlayerInterruptionDelegate.h"
#import "BMDataModel.h"

@protocol AudioPlayerAdapterDelegate;

@interface AudioPlayerAdapter : NSObject <AudioPlayerInterruptionDelegate>

@property (nonatomic, readonly) PlayState playState;
@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, readonly) BOOL buffering;
@property (nonatomic, readonly) BOOL paused;

@property (nonatomic, readonly) int nowPlayingListID;
@property (nonatomic, readonly) BMListDataModel* nowPlayingItem;

@property (nonatomic, readonly) id<AudioPlayerAdapterDelegate> delegate;

+ (AudioPlayerAdapter*)sharedPlayerAdapter;

// if current delegate is srcDelegate, the delegate will be reseted to nil.
// any delegate object should call this method before dealloc.
- (void)resetDelegate:(id<AudioPlayerAdapterDelegate>)srcDelegate;

- (void)playRingtoneItem:(BMDataModel*)item inList:(int)listID delegate:(id<AudioPlayerAdapterDelegate>)delegate;
- (void)play;
- (void)playNext;
- (void)playPrev;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)seek:(float)f_seek_time;
- (float)currentTime;
- (float)duration;

- (BOOL)isNowPlayingItem:(BMListDataModel*)item inList:(int)listID;

@end


@protocol AudioPlayerAdapterDelegate <NSObject>

@optional
- (void)audioPlayerNowPlayingItemChanged:(AudioPlayerAdapter*)player;
- (void)audioPlayerScheduleChanged:(AudioPlayerAdapter*)player;
- (void)audioPlayerBufferProgressChanged:(AudioPlayerAdapter*)player;
- (void)audioPlayerPlayStateChanged:(AudioPlayerAdapter*)player;
- (void)audioPlayerPlayItemFinished:(AudioPlayerAdapter*)player;

@end
