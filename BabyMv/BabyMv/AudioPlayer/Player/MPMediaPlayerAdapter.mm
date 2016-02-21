//
//  MPMediaPlayerAdapter.mm
//  KWPlayer
//
//  Created by YeeLion on 11-1-27.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MPMediaLibrary.h>
#import <MediaPlayer/MPMediaPlayback.h>
#import "MPMediaPlayerAdapter.h"

@interface MPMediaPlayerAdapter ()
{
    BOOL _avPlayerAvailable;
    PlayState _playState;
}
@end

@implementation MPMediaPlayerAdapter

@synthesize playState = _playState;

+ (MPMediaItem*) mediaItemOfPersistentId:(UInt64)pid {
    MPMediaPropertyPredicate* predicate = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithUnsignedLongLong:pid]
                                                                           forProperty:MPMediaItemPropertyPersistentID];
    MPMediaQuery* query = [[[MPMediaQuery alloc] initWithFilterPredicates:[NSSet setWithObject:predicate]] autorelease];
    NSAssert(query.items.count <= 1, @"Logic error!");
    
    if (query.items.count == 0) {
        return nil;
    }
    return (MPMediaItem*)[query.items objectAtIndex:0];
}

- (PlayState) translateMPPlaystate:(MPMusicPlaybackState)mps {
    PlayState ps = _playState;
    switch (mps) {
        case MPMusicPlaybackStatePlaying:
            ps = PlayStatePlaying;
            break;
        case MPMusicPlaybackStatePaused:
        case MPMusicPlaybackStateInterrupted:
            ps = PlayStatePaused;
            break;
        case MPMusicPlaybackStateStopped:
            ps = PlayStateStopped;
            break;
        case MPMusicPlaybackStateSeekingForward:
        case MPMusicPlaybackStateSeekingBackward:
            // do not change play status
            //ps = PlayStatePlaying;
            break;
        default:
            NSAssert (FALSE, @"Unexpected Media Player status!");
            break;
    }
    return ps;
}

- (void) setPlayState:(PlayState)ps {
    //NSLog(@"player status changed: %d -> %d", _playState, ps);

    if (_playState == ps)
        return;
    _playState = ps;
    
//    if ([_playerEventHandler respondsToSelector:@selector(onPlayStateChanged)]) {
//        [_playerEventHandler performSelectorOnMainThread:@selector(onPlayStateChanged) withObject:nil waitUntilDone:FALSE];
//    } else {
//        NSLog(@"Media player playstate notification is ignored.");
//    }
	if (_playerEventHandler) {
		[_playerEventHandler onPlayerPlayStateChanged:self];
	}
}

- (BOOL) isPlaying {
    //return _mpPlayer.playbackState == MPMusicPlaybackStatePlaying;
    return _playState == PlayStatePlaying;
}

- (BOOL)isBuffering {
    return FALSE;
}

/*- (void) handlerNowPlayingItemChanged:(id)notification {
    //NSLog(@"Media player Notification: %@", notification);
    //NSLog(@"Media player item changed: %@", [self currentMusicInfo].title);
    if ([_playerEventHandler respondsToSelector:@selector(onPlayingItemChanged)]) {
        [_playerEventHandler onPlayingItemChanged];
    }
}*/

- (void) handlerPlaybackStateChanged:(id)notification {
    //NSLog(@"Media player Notification: %@", notification);
    if (_avPlayerAvailable)
        return;
    
    MPMusicPlaybackState mps = _mpPlayer.playbackState;
    //NSLog(@"Media player state changed: %d", mps);
    PlayState ps = [self translateMPPlaystate:mps];
    
    [self setPlayState:ps];
}

/*- (void) handleriPodLibraryChanged:(id)notification {
    NSLog(@"Media player Notification: %@", notification);
    NSLog(@"Media player iPod Library Changed.");
}*/

- (void) handlerVolumeChanged:(id)notification {
//    if ([_playerEventHandler respondsToSelector:@selector(onVolumeChanged)]) {
//        [_playerEventHandler onVolumeChanged];
//    } else {
        NSLog(@"Media player volume notification is ignored.");
//    }
}

- (void) handlerItemDidPlayToEnd:(id)notification {
    assert(_avPlayerAvailable);
	[self stop];
}

// Registering for and activating music player notifications
- (void) registerPlaybackNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    /*[notificationCenter addObserver: self
                           selector: @selector (handlerNowPlayingItemChanged:)
                               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                             object: _mpPlayer];*/
    
    [notificationCenter addObserver: self
                           selector: @selector (handlerPlaybackStateChanged:)
                               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                             object: _mpPlayer];
    
    /*[notificationCenter addObserver: self
						   selector: @selector (handleriPodLibraryChanged:)
							   name: MPMediaLibraryDidChangeNotification
							 object: _mpPlayer];*/
    
    [notificationCenter addObserver: self
                           selector: @selector (handlerVolumeChanged:)
                               name: MPMusicPlayerControllerVolumeDidChangeNotification
                             object: _mpPlayer];

    [_mpPlayer beginGeneratingPlaybackNotifications];
}

// Unregistering and deactivating music player notifications
- (void) unregisterPlaybackNotifications {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];

    /*[notificationCenter removeObserver: self
                                  name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                                object: _mpPlayer];*/
    
    [notificationCenter removeObserver: self
                                  name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                object: _mpPlayer];
    
    /*[notificationCenter removeObserver: self
                                  name: MPMediaLibraryDidChangeNotification
                                object: _mpPlayer];*/
    
    [notificationCenter removeObserver: self
                                  name: MPMusicPlayerControllerVolumeDidChangeNotification
                                object: _mpPlayer];

    [_mpPlayer endGeneratingPlaybackNotifications];
}

- (id) init {
    self = (MPMediaPlayerAdapter*)[super init];
    
    NSString* sys = [[UIDevice currentDevice] systemVersion];
    NSComparisonResult order = [sys compare:@"4.0" options:NSNumericSearch];
    _avPlayerAvailable = (order == NSOrderedSame || order == NSOrderedDescending);
    _mpPlayer = [[MPMusicPlayerController applicationMusicPlayer] retain];
    //_mpPlayer = [[MPMusicPlayerController iPodMusicPlayer] retain];
    
    _playState =[self translateMPPlaystate:_mpPlayer.playbackState];
    
    [_mpPlayer setRepeatMode:MPMusicRepeatModeNone];
    [_mpPlayer setShuffleMode:MPMusicShuffleModeOff];

    [self registerPlaybackNotifications];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    return self;
}

- (void) dealloc
{
    [self unregisterPlaybackNotifications];

    [self stop];

    [_mpPlayer release];
    [_avPlayer release];
    
    [_mediaItem release];

    [super dealloc];
}

#pragma mark MediaPlayerDelegate

- (NSTimeInterval) schedule {
    if (!_avPlayerAvailable)
    {
        NSAssert (_mpPlayer != nil, @"Invalid media player instance!");
        return _mpPlayer.currentPlaybackTime;
    }
    else
    {
        if (!_avPlayer)
            return 0.0;
        CMTime time = [_avPlayer currentTime];
        if (!time.timescale) {
            return 0.0;
        }
        return (float)time.value / time.timescale;
    }
}

- (NSTimeInterval) duration {
    NSAssert (_mpPlayer != nil, @"Invalid media player instance!");
    NSNumber* duration = [_mediaItem valueForProperty:MPMediaItemPropertyPlaybackDuration];
    return (NSTimeInterval)[duration intValue];
}

- (float) volume {
    NSAssert (_mpPlayer != nil, @"Invalid media player instance!");
    return _mpPlayer.volume;
}

- (void) setVolume:(float)volume {
    NSAssert(self.mpPlayer != nil, @"MPMediaPlayer is unavailabel!");
    [self.mpPlayer setVolume:volume];
}

- (float)progress
{
    return 1.0f;
}

- (float) cacheRate
{
    return 1.0f;
}

- (void) setMediaItemInfo:(BMListDataModel *)mediaItemInfo
{
/*    if (_mediaItemInfo != mediaItemInfo)
    {
        [self stop];
		[_mediaItemInfo release];
		_mediaItemInfo = [mediaItemInfo copy];
	}

    self.mediaItem = _mediaItemInfo.iPodMediaItem;
	
    if (!_avPlayerAvailable)
    {
        MPMediaItemCollection* collection = [MPMediaItemCollection collectionWithItems:[NSArray arrayWithObject:self.mediaItem]];
        [self.mpPlayer setQueueWithItemCollection:collection];
        [self.mpPlayer setNowPlayingItem:self.mediaItem];
    }*/
}

- (void) play {
    if (!_avPlayerAvailable)
    {
        NSAssert(self.mpPlayer != nil, @"MPMediaPlayer is unavailabel!");
		if (nil == _mpPlayer.nowPlayingItem)
		{
			[self setPlayState:PlayStateFailed];
			return;
		}
        [self.mpPlayer play];
    }
    else
    {
		if (!self.mediaItem)
		{
			[self setPlayState:PlayStateFailed];
			return;
		}

		if (!_avPlayer) {
			NSURL* url = [_mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
			if (!url) {
				[self setPlayState:PlayStateFailed];
				return;
			}
			_avPlayer = [[NSClassFromString(@"AVPlayer") alloc] initWithURL:url];
			_avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
			[[NSNotificationCenter defaultCenter] addObserver: self
													 selector: @selector (handlerItemDidPlayToEnd:)
														 name: AVPlayerItemDidPlayToEndTimeNotification
													   object: _avPlayer.currentItem];
		}
		if (!_avPlayer)
		{
			[self setPlayState:PlayStateFailed];
			return;
		}
        [_avPlayer play];
		if (_avPlayer.status == AVPlayerStatusFailed)
		{
			[self setPlayState:PlayStateFailed];
			[_avPlayer release];
			_avPlayer = nil;
			return;
		}
        self.playState = PlayStatePlaying;
    }}

- (void) pause {
    if (!_avPlayerAvailable)
    {
        NSAssert(self.mpPlayer != nil, @"MPMediaPlayer is unavailabel!");
        [self.mpPlayer pause];
    }
    else
    {
        [_avPlayer pause];
        self.playState = PlayStatePaused;
    }
}

- (void) stop {
    if (!self.mediaItem || !self.isPlaying)
        return;
    
    if (!_avPlayerAvailable)
    {
        NSAssert(self.mpPlayer != nil, @"MPMediaPlayer is unavailabel!");
        [self.mpPlayer stop];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver: self
                                                        name: AVPlayerItemDidPlayToEndTimeNotification
                                                      object: _avPlayer.currentItem];
        [_avPlayer seekToTime:kCMTimeZero];

        //[_avPlayer pause];
        [_avPlayer release];
        _avPlayer = nil;
        self.playState = PlayStateStopped;
    }
}

- (BOOL) seek:(NSTimeInterval)schedule {
    if (!_avPlayerAvailable)
    {
        NSAssert(self.mpPlayer != nil, @"MPMediaPlayer is unavailabel!");
        [self.mpPlayer setCurrentPlaybackTime:schedule];
    }
    else
    {
        if ([self isPlaying]) {
            [_avPlayer pause];
        }
		//NSLog(@"Seek: %lf", schedule);
        CMTime time = CMTimeMake(schedule * 1000, 1000);
        [_avPlayer seekToTime:time];
        if ([self isPlaying]) {
            [_avPlayer play];
        }
    }
    return TRUE;
}

@end
