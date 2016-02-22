//
//  MPMediaPlayerAdapter.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-27.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMusicPlayerController.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayState.h"
#import "MediaPlayerProtocol.h"
#import "PlayerEventHandlerDelegate.h"
#import "AudioPlayerInterruptionDelegate.h"
#import "BMDataModel.h"


@interface MPMediaPlayerAdapter : NSObject <MediaPlayerProtocol, AudioPlayerInterruptionDelegate>

@property (nonatomic, retain) MPMusicPlayerController* mpPlayer;
@property (nonatomic, retain) AVPlayer* avPlayer;

//@property (nonatomic, copy) IPodMediaItem* mediaItemInfo;
@property (nonatomic, retain) MPMediaItem* mediaItem;
@property (nonatomic, readonly) PlayState playState;
@property (nonatomic, assign) id<PlayerEventHandlerDelegate> playerEventHandler;

+ (MPMediaItem*) mediaItemOfPersistentId:(UInt64)pid;

- (NSTimeInterval) schedule;
- (NSTimeInterval) duration;

- (float) volume;
- (void) setVolume:(float)volume;

- (BOOL) isPlaying;
- (BOOL) isBuffering;

- (void) play;
- (void) pause;
- (void) stop;

- (BOOL) seek:(NSTimeInterval)schedule;

@end
