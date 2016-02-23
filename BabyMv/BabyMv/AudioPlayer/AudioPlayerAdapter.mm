//
//  AudioPlayerAdapter.m
//  RingtoneDuoduo
//
//  Created by misty on 13-11-14.
//  Copyright (c) 2013年 www.ShoujiDuoduo.com. All rights reserved.
//

//#import <MP>
#import "KuwoMusicPlayer.h"
#import "MPMediaPlayerAdapter.h"
#import "AudioPlayerAdapter.h"
#import "BSPlayList.h"
#import "Notification.h"
#import "AppDelegate.h"
//#import "MobClick.h"
//#import "BSUmengStatisticElement.h"
#import "RTLocalConfigElements.h"
#import "RTLocalConfig.h"

#import "bsbase64.h"
#import "BMDataBaseManager.h"

@interface AudioPlayerAdapter () <PlayerEventHandlerDelegate>
{
    BMDataModel* _nowPlayingItem;
    UIBackgroundTaskIdentifier _bgTaskId;
}

@property (nonatomic, retain) id<MediaPlayerProtocol> player;

@end

@implementation AudioPlayerAdapter

@synthesize nowPlayingItem = _nowPlayingItem;

//- (BOOL)isNowPlayingIPodItem
//{
//    return [self.nowPlayingItem isKindOfClass:[IPodMediaItem class]];
//}

+ (AudioPlayerAdapter*)sharedPlayerAdapter
{
    static AudioPlayerAdapter* s_player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_player = [[AudioPlayerAdapter alloc] init];
    });
    return s_player;
}

- (void)newPlayer
{
    @synchronized(self) {
        if (!self.player) {
            self.player = [[[KuwoMusicPlayer alloc] init] autorelease];
            self.player.playerEventHandler = self;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
    }
}

- (void)releasePlayer
{
    @synchronized(self) {
        if (self.player)
        {
            id<MediaPlayerProtocol> player = [self.player retain];
            self.player = nil;
            player.playerEventHandler = nil;
//            dispatch_async(dispatch_get_main_queue(), ^{
                [player stop];
                [player release];
//            });
//            [self handlerPlayState:PlayStateStopped];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
        }
    }
}

- (void)resetDelegate:(id<AudioPlayerAdapterDelegate>)srcDelegate
{
    if (_delegate == srcDelegate)
        _delegate = nil;
}

- (void)dealloc
{
    [_nowPlayingItem release];
    [_player release];
    [super dealloc];
}

- (BOOL)playing
{
    return self.playState == PlayStatePlaying;
}

- (BOOL)buffering
{
    return self.playState == PlayStateBuffering;
}

- (BOOL)paused
{
    return self.playState == PlayStatePaused;
}

- (void)setNowPlayingItem:(BMDataModel*)item listID:(int)listID delegate:(id<AudioPlayerAdapterDelegate>)delegate
{
    if (![self isNowPlayingItem:item inList:listID])
    {
        [self stop];
    }

    _nowPlayingListID = listID;
    if (_nowPlayingItem != item)
    {
        [_nowPlayingItem release];
        _nowPlayingItem = [item copy];
    }

    id<AudioPlayerAdapterDelegate> oldDelegate = _delegate;
    _delegate = delegate;
    if (self.delegate != oldDelegate)
    {
        if ([oldDelegate respondsToSelector:@selector(audioPlayerNowPlayingItemChanged:)])
            [oldDelegate audioPlayerNowPlayingItemChanged:self];
    }
    if ([self.delegate respondsToSelector:@selector(audioPlayerNowPlayingItemChanged:)])
        [self.delegate audioPlayerNowPlayingItemChanged:self];
}

- (void)playRingtoneItem:(BMDataModel*)item inList:(int)listID delegate:(id<AudioPlayerAdapterDelegate>)delegate
{
//    [MobClick event:BS_PLAY label:@"audio"];
    
    [self setNowPlayingItem:item listID:listID delegate:delegate];
    
    [self play];
}

- (void)play
{
    [self releasePlayer];
    
    [self newPlayer];

    self.player.mediaItemInfo = (BMListDataModel*)self.nowPlayingItem;
    BMListDataModel* cur_video = (BMListDataModel*)self.nowPlayingItem;
    cur_video.LastListeningTime = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    [[BMDataBaseManager sharedInstance] listenMusicList:cur_video];

    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
    GetAppDelegate().interruptionHandlerObject = self;
    AudioSessionSetActive(true);

    [self.player play];
}

- (void)playNext{
    if ([[BSPlayList sharedInstance] nextItem]) {
        [self stop];
        double delayInSeconds = 0.5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self setNowPlayingItem:[[BSPlayList sharedInstance] nextItem] listID:_nowPlayingListID delegate:_delegate];
            [self play];
            [[BSPlayList sharedInstance] setCurIndex:([[BSPlayList sharedInstance] getCurIndex] + 1)];
        });
    }
}
- (void)playPrev{
    if ([[BSPlayList sharedInstance] prevItem]) {
        [self stop];
        double delayInSeconds = 0.5;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self setNowPlayingItem:[[BSPlayList sharedInstance] prevItem] listID:_nowPlayingListID delegate:_delegate];
            [self play];
            [[BSPlayList sharedInstance] setCurIndex:([[BSPlayList sharedInstance] getCurIndex] - 1)];
        });
        
    }
}

- (void)pause
{
    [self.player pause];
}

- (void)stop
{
    if (GetAppDelegate().interruptionHandlerObject == self)
        GetAppDelegate().interruptionHandlerObject = nil;
    [self releasePlayer];
}

- (void)seek:(float)f_seek_time{
    [self.player seek:f_seek_time];
}

- (float)currentTime{
    return [self.player schedule];
}

- (float)duration{
    return [self.player duration];
}

- (BOOL)isNowPlayingItem:(BMDataModel*)item inList:(int)listID
{
    return self.nowPlayingListID == listID && [self.nowPlayingItem isEqual:item];
}

#pragma mark - PlayerEventHandlerDelegate

//- (void) onPlayerNowPlayingItemChanged:(id)player
//{
//}

- (void) onPlayerPlayStateChanged:(id)player
{
    if (player != self.player)
        return;
    [self handlerPlayState:[(KuwoMusicPlayer*)player playState]];
}

- (void)handlerPlayState:(PlayState)ps
{
    _playState = ps;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(audioPlayerPlayStateChanged:)]) {
            [self.delegate audioPlayerPlayStateChanged:self];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kCNotificationPlayStateChanged object:self userInfo:nil];
    });

    if (ps == PlayStateStopped)
    {
        [self stop];

        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(audioPlayerPlayItemFinished:)]) {
                [self.delegate audioPlayerPlayItemFinished:self];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kCNotificationPlayItemFinished object:self userInfo:nil];
        });
    }else if(ps == PlayStateBufferingFailed || ps == PlayStateFailed){
        [self stop];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(audioPlayerPlayItemFinished:)]) {
                [self.delegate audioPlayerPlayItemFinished:self];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kCNotificationPlayItemFinished object:self userInfo:nil];
        });
    }
}

- (void) onPlayerScheduleChanged:(id)player
{
    if (player != self.player)
        return;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(audioPlayerScheduleChanged:)]) {
            [self.delegate audioPlayerScheduleChanged:self];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCNotificationScheduleChanged object:self userInfo:nil];
    });
}

//- (void) onPlayerVolumeChanged:(id)player
//{
//}

- (void) onPlayer:(id)player bufferProgressChanged:(float)progress
{
    if (player != self.player)
        return;

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(audioPlayerBufferProgressChanged:)]) {
            [self.delegate audioPlayerBufferProgressChanged:self];
        }
    });
}

//- (void) onPlayer:(id)player
// audioRouteChange:(AudioSessionPropertyID)inPropertyID
//propertyValueSize:(UInt32)inPropertyValueSize
//    propertyValue:(const void*)inPropertyValue
//{
//}

- (void) onPlayer:(id)player audioInterruption:(UInt32)interruptionState
{
    if (player != self.player)
        return;

    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

- (void)handleAudioSessionInterruption:(UInt32)interruptionState
{
    if (/*[self.player isKindOfClass:[KuwoMusicPlayer class]]
        &&*/ [self.player respondsToSelector:@selector(handleAudioSessionInterruption:)])
    {
        [self.player handleAudioSessionInterruption:interruptionState];
    }
}

- (void) beginBackgroundTask{
    UIApplication* app = [UIApplication sharedApplication];
    _bgTaskId = [app beginBackgroundTaskWithExpirationHandler:^(void) {
        [app endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    }];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (1) {
            if (_bgTaskId == UIBackgroundTaskInvalid) {
                break;
            }
            NSLog(@"again");
            sleep(5);
        }
    });
}

- (void)endBackgroundTask {
    if (_bgTaskId && _bgTaskId != UIBackgroundTaskInvalid) {
        fprintf(stderr, "end background task: %d\n", _bgTaskId);
        [[UIApplication sharedApplication] endBackgroundTask:_bgTaskId];
        _bgTaskId = 0;
    }
}

- (void)handleApplicationWillEnterForegroundNotification{
    [self endBackgroundTask];
}

- (void)handleApplicationDidEnterBackgroundNotification{
    [self beginBackgroundTask];
}

@end
