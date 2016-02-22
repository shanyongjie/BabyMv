//
//  KuwoMusicPlayer.mm
//  KWPlayer
//
//  Created by YeeLion on 11-1-24.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "logger.h"
#import "BMDataModel.h"
#import "AudioPlayer.h"
#import "KuwoMusicPlayer.h"
#import "NetworkConfigure.h"
#import "BSDir.h"
#import "Notification.h"


#define DEFAULT_MP3_BITRATE     96
#define FIRST_CACHE_TIME        5  // seconds
#define INTERRUPT_CACHE_TIME    10  // seconds

PlayState translatePlaystate(AudioStreamState state)
{
    PlayState ps = PLayStateUndefined;
    switch (state) {
        case PS_INITIALIZED:
            ps = PlayStateStopped;
            break;
        case PS_BUFFERING:
            ps = PlayStateBuffering;
            break;
        case PS_PLAYING:
            ps = PlayStatePlaying;
            break;
        case PS_PAUSED:
            ps = PlayStatePaused;
            break;
        case PS_BUFFERINGFAILED:
            ps = PlayStateBufferingFailed;
            break;
        case PS_FAILED:
            ps = PlayStateFailed;
            break;
        case PS_STOPPED:
            ps = PlayStateStopped;
            break;
        default:
            assert(FALSE);
            break;
    }
    return ps;
}

@implementation DownloadProgressParam
@end

@implementation DownloadStatusParam
@end

@implementation DownloadResultParam
@end


@interface KuwoMusicPlayer (_KuwoMusicPlayerPrivate)

- (void) onAudioInterruption:(UInt32)interruptionState;

- (void) onAudioRouteChange:(AudioSessionPropertyID)inPropertyID
          propertyValueSize:(UInt32)inPropertyValueSize
              propertyValue:(const void*)inPropertyValue;
@end


//==============================================================================
// player callback
void AudioPlayerStateCallback(AudioStreamState state, AudioStreamState oldState, void* userData)
{
    KuwoMusicPlayer* kwplayer = (KuwoMusicPlayer*)userData;
    [kwplayer handlerPlayerStateChanged:state oldState:oldState];
}

void AudioPlayerErrorCallback(AudioStreamErrorCode error, void* userData)
{
    KuwoMusicPlayer* kwplayer = (KuwoMusicPlayer*)userData;
    [kwplayer handlerPlayerError:error];
}

//==============================================================================
// download callback
void MusicDownloadProgressCallback(int session, int step, int total, void* userData)
{
    KuwoMusicPlayer* kwplayer = (KuwoMusicPlayer*)userData;
    [kwplayer handlerDownloadProgress:session step:step total:total];
//    DownloadProgressParam* param = [[DownloadProgressParam alloc] init];
//    param->requestId = session;
//    param->step = step;
//    param->total = total;
//    [kwplayer performSelectorOnMainThread:@selector(handlerDownloadProgress:) withObject:param waitUntilDone:FALSE];
//    [param release];
}

void MusicDownloadStatusCallback(int session, DOWNLOADSTATUS status, void* userData)
{
    KuwoMusicPlayer* kwplayer = (KuwoMusicPlayer*)userData;
    [kwplayer handlerDownloadStatus:session status:status];
//    DownloadStatusParam* param = [[DownloadStatusParam alloc] init];
//    param->requestId = session;
//    param->status = status;
//    [kwplayer performSelectorOnMainThread:@selector(handlerDownloadStatus:) withObject:param waitUntilDone:FALSE];
//    [param release];
}

void MusicDownloadResultCallback(int session ,int errorNO, void* userData)
{
    KuwoMusicPlayer* kwplayer = (KuwoMusicPlayer*)userData;
    [kwplayer handlerDownloadResult:session result:errorNO];
//    DownloadResultParam* param = [[DownloadResultParam alloc] init];
//    param->requestId = session;
//    param->result = errorNO;
//    [kwplayer performSelectorOnMainThread:@selector(handlerDownloadResult:) withObject:param waitUntilDone:FALSE];
//    [param release];
}


// Audio session callback function for responding to audio route changes. If playing 
//		back application audio when the headset is unplugged, this callback pauses 
//		playback and displays an alert that allows the user to resume or stop playback.
//
//		The system takes care of iPod audio pausing during route changes--this callback  
//		is not involved with pausing playback of iPod audio.
void audioRouteChangeListenerCallback (
                                       void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueSize,
                                       const void                *inPropertyValue
                                       )
{
    KuwoMusicPlayer* player = (KuwoMusicPlayer*) inUserData;
    [player onAudioRouteChange:inPropertyID propertyValueSize:inPropertyValueSize propertyValue:inPropertyValue];
}

// Use iPod volumn listener is OK.
/*void audioVolumeListenerCallback (
                                  void                      *inUserData,
                                  AudioSessionPropertyID    inPropertyID,
                                  UInt32                    inPropertyValueSize,
                                  const void                *inPropertyValue
                                  ) {
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_CurrentHardwareOutputVolume) return;
    
    KuwoMusicPlayer* player = (KuwoMusicPlayer*)inUserData;
    [player onVolumeChanged];
}*/

//void audioSessionInterruptionListenerCallback(void* inUserData, UInt32 inInterruptionState)
//{
//    KuwoMusicPlayer* player = (KuwoMusicPlayer*)inUserData;
//    [player onAudioInterruption:inInterruptionState];
//}


@implementation KuwoMusicPlayer

@synthesize playState = _playState;
@synthesize mediaItemInfo = _mediaItemInfo;
@synthesize progress = _progress;
@synthesize playerEventHandler = _playerEventHandler;

- (id) init {
    self = [super init];
    _dldMgr = DownloadManager::Instance();
    _lock = new CLock();
    
    _audioPlayer = new CAudioPlayer();
    if (!_audioPlayer) {
        [super dealloc];
        self = nil;
    }
    _audioPlayer->Initialize();
    _audioPlayer->SetEventHandler(AudioPlayerStateCallback, AudioPlayerErrorCallback, self);
	
	//_bgTaskId = 0;
    
    _isInterrpted = FALSE;
    _playState = translatePlaystate(_audioPlayer->GetPlayState());
    
    mStreamFile = new CStreamFile;
    mRequestId = 0;
    mDownloadFileHandle = nil;

//    AudioSessionInitialize (
//                            NULL,                          // 'NULL' to use the default (main) run loop
//                            NULL,                          // 'NULL' to use the default run loop mode
//                            audioSessionInterruptionListenerCallback,  // a reference to your interruption callback
//                            self                           // data to pass to your interruption listener callback
//                            );

    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
    
    // Registers the audio route change listener callback function
    AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     self
                                     );
    /*AudioSessionAddPropertyListener (
                                     kAudioSessionProperty_CurrentHardwareOutputVolume,
                                     audioVolumeListenerCallback,
                                     self
                                     );*/
    
    AudioSessionSetActive(true);
    
    return self;
}

- (void) dealloc {
    AudioSessionSetActive(false);
    AudioSessionRemovePropertyListenerWithUserData (
                                                    kAudioSessionProperty_AudioRouteChange,
                                                    audioRouteChangeListenerCallback,
                                                    self
                                                    );
    [self stop];
    if (_audioPlayer) {
        _audioPlayer->Uninitialize();
        delete _audioPlayer;
        _audioPlayer = NULL;
    }
    
    delete mStreamFile;
    
    [_mediaItemInfo release];
    
    _dldMgr = NULL;
    
    delete _lock;
    
    [super dealloc];
}

#pragma mark MediaPlayerDelegate

//- (PlayState) playState {
//    NSLog(@"Unresolved method!");
//    return _playState;
//}

- (NSTimeInterval) schedule {
    if (_audioPlayer) {
        return (NSTimeInterval)_audioPlayer->GetSchedule();
    }
    return 0.0;
}

- (NSTimeInterval) duration {
    NSTimeInterval duration = 0.0;
    if (_audioPlayer) {
        duration = (NSTimeInterval)_audioPlayer->GetDuration();
    }
    
    return duration;
}

- (float) volume {
    if (_audioPlayer) {
        return (NSTimeInterval)_audioPlayer->GetVolume();
    }
    return 0.0;
}

- (void) setProgress:(float)progress {
    _progress = progress;
    if (_playerEventHandler) {
        [_playerEventHandler onPlayer:self bufferProgressChanged:progress];
    }
}

- (BOOL) isPlaying {
    return _playState == PlayStatePlaying;
}

- (BOOL) isBuffering {
    return _playState == PlayStateBuffering;
}

- (void) setVolume:(float)volume {
    _audioPlayer->SetVolume(volume);
}

// implement by property
//- (void) setPlayerEventHandler:(id)eventHandler {
//}

- (UInt32) CalculateBufferSizeForTime:(UInt32)timeInSecond {
    UInt32 bitRate = 0;//_mediaItemInfo.bitRate;
    if (!bitRate)
        bitRate = DEFAULT_MP3_BITRATE;
    UInt32 cbBytes = bitRate * 1000 / 8 * timeInSecond;
    return cbBytes;
}

- (void) setMediaItemInfo:(BMDataModel*)itemInfo {
    if (![_mediaItemInfo isEqual:itemInfo]) {
        [self stop];
    }
    NSLog(@"setMediaItemInfo: %@, old: %@", itemInfo, _mediaItemInfo);
    if (_mediaItemInfo != itemInfo) {
        [_mediaItemInfo release];
        _mediaItemInfo = [itemInfo copy];
    }
	if (!_mediaItemInfo)
		return;
	
//	NSString* file = CLocalMusicManager::GetInstance()->GetLocalFilePathForMediaItem(_mediaItemInfo);
//    NSString* audioFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"千千阙歌_128kbps.mp3"];
//    NSString* file = audioFile;
    _cacheSize = [self CalculateBufferSizeForTime:FIRST_CACHE_TIME];
}

- (BOOL) openStreamFile {
    CAutoLock lock(_lock);
    if (!_mediaItemInfo) {
        return FALSE;
    }
    
    if (mStreamFile->IsOpen()) {
        return TRUE;
    }
    
    if (mRequestId) {
        return FALSE;
    }

    string file;

    _startTime = 0;
    _bufferingStartTime = 0;
    _bufferingTime = 0;
    
	_localMusic = NO;
    NSString* nsfile = nil;
    BMListDataModel* down_item = (BMListDataModel*)_mediaItemInfo;
    if (down_item.IsDowned) {
        NSString* strex = Dir::GetFileExt(down_item.Url);
        if ([strex isEqualToString:@"aac"]) {
            nsfile = [Dir::GetPath(Dir::PATH_LOCALMUSIC) stringByAppendingPathComponent:[NSString stringWithFormat:@"%u.m4a", [down_item.Rid intValue]]];
        }else {
            nsfile = [Dir::GetPath(Dir::PATH_LOCALMUSIC) stringByAppendingPathComponent:[NSString stringWithFormat:@"%u.%@", [down_item.Rid intValue], strex]];
        }
    }
    /*CLocalMusicManager::GetInstance()->GetLocalFilePathForMediaItem(_mediaItemInfo);*/
//    nsfile = @"/Users/momo/Library/Application Support/iPhone Simulator/5.0/Applications/4ACC0BAB-B2B9-4A5E-99D1-9472060C4318/Library/Caches/cache/85042.1096";
    if (nsfile) {
        _localMusic = YES;
		_audioFormat = MediaFormatMP3;
        file = [nsfile UTF8String];
        assert(!file.empty());
        self.progress = 1.0;
    } else {
        assert(!mRequestId);
		_audioFormat = [NetworkConfigure sharedInstance].isWiFiNetwork ? MediaFormatAAC : MediaFormatMP3;
        file = _dldMgr->GetDownloadFileItem(_mediaItemInfo, _audioFormat, "",
                                            [_mediaItemInfo.Rid intValue], &mRequestId,
                                            MusicDownloadProgressCallback, MusicDownloadStatusCallback, MusicDownloadResultCallback, self);
        //NSLog(@"request id: %p, file: %s", mRequestId, file.c_str());
        if (mRequestId) {
            //_localMusic = YES;
            _bufferingStartTime = [NSDate timeIntervalSinceReferenceDate];
            [self onPlaystateChanged:PlayStateBuffering];
            //int total = _dldMgr->GetDownloadItemFileSize(mRequestId);
            //int step = _dldMgr->GetDownloadItemProgress(mRequestId);
            //self.progress = (float)step / total;
            self.progress = 0.0;
        } else {
            //_localMusic = NO;
            if (file.empty()) {
                [self onPlaystateChanged:PlayStateBufferingFailed];
                return FALSE;
            }
            self.progress = 1.0;
        }
    }
    
    if (file.empty()) {
        assert(mRequestId != 0);
        return FALSE;
    }
    
    //NSLog(@"music file cached: %s", file.c_str());
    assert(mStreamFile != NULL);
    if (!mStreamFile->OpenFile(file.c_str(), AUTO_FILE_SIZE)) {
        [self onPlaystateChanged:PlayStateFailed];
        return FALSE;
    }
    
//    if (!_localMusic && !mRequestId) {
//        RTLog_DownloadMusic(AR_CACHE, NETWORK_NAME, 
//                            [_mediaItemInfo.title UTF8String], [_mediaItemInfo.artist UTF8String], [_mediaItemInfo.album UTF8String], 
//                            [self musicFormat], [self musicBitrate], _mediaItemInfo.duration, 
//                            mStreamFile->GetFileSize(), 0, 0, 0);
//    }

    
    return TRUE;
}

- (void) closeStreamFile {
    CAutoLock lock(_lock);
    if (mRequestId) {
        //RTLog_RequestMusic(AR_CANCEL, NETWORK_NAME, [_mediaItemInfo.title UTF8String], [_mediaItemInfo.artist UTF8String], [_mediaItemInfo.album UTF8String]);
//		RTLog_DownloadMusic(AR_CANCEL, NETWORK_NAME, 
//							[_mediaItemInfo.title UTF8String], [_mediaItemInfo.artist UTF8String], [_mediaItemInfo.album UTF8String], 
//							[self musicFormat], [self musicBitrate], _mediaItemInfo.duration, 
//							mStreamFile->GetFileSize(), 0, 0, 0);
        int requestId = mRequestId;
        mRequestId = 0;
        _lock->Unlock();
        _dldMgr->CancelDownloadItemCache(requestId);
        //NSLog(@"clear id: %p", requestId);
        _lock->Lock();
    }
    
    if (mStreamFile) {
        mStreamFile->CloseFile();
    }
    
    if (mDownloadFileHandle) {
        _dldMgr->ReleaseDownloadItem(mDownloadFileHandle);
        mDownloadFileHandle = NULL;
    }
}

- (BOOL) InitKuwoMusicPlayer{
    if (!_audioPlayer->IsOpen()) {
		_audioFormatID = 0;
		MediaFormat fmt = MediaFormatMP3;//CLocalMusicManager::GetDownloadFileFormat(mStreamFile->GetFilePath(), NULL);
		switch (fmt) {
			case MediaFormatWAV:
				_audioFormatID = kAudioFileWAVEType;
				break;
			case MediaFormatMP3:
				_audioFormatID = kAudioFileMP3Type;
				break;
			case MediaFormatAAC:
				_audioFormatID = kAudioFileAAC_ADTSType; //kAudioFileM4AType
				break;
			default:
				break;
		}
        if (!_audioPlayer->InitCAudioPlayer(mStreamFile, _audioFormatID, 0)) {
            [self onPlaystateChanged:PlayStateFailed];//vieriplayer需要判断一下如果是正在缓存状态则不认为是失败
            return FALSE;
        }
		_audioFormatID = _audioPlayer->GetFormatID();
    }
    return TRUE;
}

- (BOOL)startPlay{
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );

    if (!_audioPlayer->Play()) {
        [self onPlaystateChanged:PlayStateFailed];
        _audioPlayer->Stop();
        return FALSE;
    }
    return TRUE;
}

- (int) readAudioFileType:(const char*)file
{
    CFURLRef fileURL = CFURLCreateFromFileSystemRepresentation (kCFAllocatorDefault, (const UInt8 *)file, strlen(file), false);
    CFAutorelease(fileURL);

    AudioFileID audioFile;
    OSStatus err = AudioFileOpenURL(fileURL, kAudioFileReadPermission, kAudioFileMP3Type, &audioFile);

    UInt32 fileType = 0;
    UInt32 size = sizeof(fileType);
	err = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyFileFormat, &size, &fileType);

    return fileType;
}

- (BOOL) playInternal {
    if (!_audioPlayer->IsOpen()) {
		_audioFormatID = 0;

//        int format = [self readAudioFileType:mStreamFile->GetFilePath()];
//        NSLog(@"%d", format);

		MediaFormat fmt = MediaFormatAAC;//CLocalMusicManager::GetDownloadFileFormat(mStreamFile->GetFilePath(), NULL);
		switch (fmt) {
			case MediaFormatWAV:
				_audioFormatID = kAudioFileWAVEType;
				break;
			case MediaFormatMP3:
				_audioFormatID = kAudioFileMP3Type;
				break;
			case MediaFormatAAC:
				_audioFormatID = kAudioFileAAC_ADTSType; //kAudioFileM4AType
				break;
			default:
				break;
		}
        if (!_audioPlayer->OpenStreamFile(mStreamFile, _audioFormatID, 0)) {
            //_audioPlayer->CloseAudioStream();
            _audioPlayer->Stop();
            [self onPlaystateChanged:PlayStateFailed];//vieriplayer需要判断一下如果是正在缓存状态则不认为是失败
            
            
            return FALSE;
        }
		_audioFormatID = _audioPlayer->GetFormatID();
    }
//	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
////		if (_bgTaskId && _bgTaskId != UIBackgroundTaskInvalid) {
////			[[UIApplication sharedApplication] endBackgroundTask: _bgTaskId];
////			NSLog(@"End Background Task 4");
////		}
//		_bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
//		NSLog(@"Begin Background Task 1");
//		NSTimeInterval time = [[UIApplication sharedApplication] backgroundTimeRemaining];
//		NSLog(@"time remain 1: %lf", time);
//	}
    ///*by vieriplayer
	if (mStreamFile->IsBufferingReady(_cacheSize)) {
		if (![self startPlay]) {
			return FALSE;
		}
	} else if (mStreamFile->IsBuffering()) {
        [self onPlaystateChanged:PlayStateBuffering];
    } else {
        //_audioPlayer->CloseAudioStream();
        _audioPlayer->Stop();
		[self onPlaystateChanged:PlayStateBufferingFailed];
        
        return FALSE;
	}
     //*/
    return TRUE;
}

- (void) play {
	CAutoLock lock(_lock);
    //vieriplayer
    _isFirstPacket = YES;
    _isFindFrame = NO;
    
//    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kCNotificationPlayItemStarted object:@{@"status":@"0"} userInfo:nil];
//    });
    
    if (!_audioPlayer->IsOpen()
        && ![self openStreamFile]) {
        return;
    }
    
    [self playInternal];
}

- (void) pause {
	CAutoLock lock(_lock);
    if ([self isBuffering]) {
        [self onPlaystateChanged:PlayStatePaused];
    }
    _audioPlayer->Pause();
    _isInterrpted = FALSE;
	
//	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
//		if (_bgTaskId && _bgTaskId != UIBackgroundTaskInvalid) {
//			[[UIApplication sharedApplication] endBackgroundTask: _bgTaskId];
//			NSLog(@"End Background Task 1");
//			_bgTaskId = 0;
//		}
//	}
}

- (void) stop {
	CAutoLock lock(_lock);
    
    if (_playState == PlayStateStopped || _playState == PlayStateBufferingFailed || _playState == PlayStateFailed)
        return;

    _audioPlayer->Stop();
    _isInterrpted = FALSE;
    [self onPlaystateChanged:PlayStateStopped];

    [self closeStreamFile];
    
//	if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
//		if (_bgTaskId && _bgTaskId != UIBackgroundTaskInvalid) {
//			[[UIApplication sharedApplication] endBackgroundTask: _bgTaskId];
//			NSLog(@"End Background Task 2");
//			_bgTaskId = 0;
//		}
//	}
}

- (BOOL) seek:(NSTimeInterval)schedule {
	CAutoLock lock(_lock);
    return _audioPlayer->Seek(schedule);
}

- (float) cacheRate {
    if (!mStreamFile || !_cacheSize)
        return 0.0;
    return mStreamFile->GetBufferingRate(_cacheSize);
}

- (void) onPlaystateChanged:(PlayState)state {
    CAutoLock lock(_lock);
    _playState = state;
    
    if (state == PlayStateFailed || state == PlayStateBufferingFailed) {
        _result = 1; // AR_FAIL
    } else if (state == PlayStateStopped) {
        _result = 0; // AR_SUCCESS
    } else if (state == PlayStatePlaying) {
//		if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
//			if (_bgTaskId && _bgTaskId != UIBackgroundTaskInvalid) {
//				[[UIApplication sharedApplication] endBackgroundTask: _bgTaskId];
//				NSLog(@"End Background Task 3");
//			}
//			_bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
//			NSLog(@"Begin Background Task 2");
//			NSTimeInterval time = [[UIApplication sharedApplication] backgroundTimeRemaining];
//			NSLog(@"time remain 2: %lf", time);
//		}
	}

    dispatch_async(dispatch_get_main_queue(), ^{
        if (_playerEventHandler) {
            [_playerEventHandler onPlayerPlayStateChanged:self];
        }
    });
}
   
- (void) handlerPlayerStateChanged:(AudioStreamState)state oldState:(AudioStreamState)oldState
{
    if (state == PS_STOPPED
        || state == PS_BUFFERINGFAILED
        || state == PS_FAILED) {
        [self closeStreamFile];
    }
    //PlayState psOld = translatePlaystate(oldState);
    PlayState psNew = translatePlaystate(state);

    //NSLog(@"player status changed: %d -> %d", psOld, psNew);
    [self onPlaystateChanged:psNew];
}

- (void) handlerPlayerError:(AudioStreamErrorCode)error {
    //[self onPlaystateChanged:PlayStateFailed];
    //NSLog(@"Player error handled, %d", error);
}

/*- (void) onVolumeChanged {
    if (_playerEventHandler) {
        [_playerEventHandler onPlayerVolumeChanged:self];
    }
}*/

- (void) onAudioRouteChange:(AudioSessionPropertyID)inPropertyID
          propertyValueSize:(UInt32)inPropertyValueSize
              propertyValue:(const void*)inPropertyValue {
    
	// ensure that this callback was invoked for a route change
	if (inPropertyID != kAudioSessionProperty_AudioRouteChange) {
        return;
    }
    
    //NSLog(@"Audio route changed but not yet been processed.");
//    PlayState ps = [self playState];
//    if (ps != PlayStatePlaying && ps!= PlayStateBuffering) {
//        
        //NSLog(@"Audio route change while application audio is stopped.");
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([_playerEventHandler respondsToSelector:@selector(onPlayer:audioRouteChange:propertyValueSize:propertyValue:)]) {
            [_playerEventHandler onPlayer:self audioRouteChange:inPropertyID propertyValueSize:inPropertyValueSize propertyValue:inPropertyValue];
            }
            return;
        
//        } else {
//            
//            // Determines the reason for the route change, to ensure that it is not
//            //		because of a category change.
//            CFDictionaryRef	routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
//            
//            CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (
//                                                                                  routeChangeDictionary,
//                                                                                  CFSTR (kAudioSession_AudioRouteChangeKey_Reason)
//                                                                                  );
//            
//            SInt32 routeChangeReason;
//            
//            CFNumberGetValue (
//                              routeChangeReasonRef,
//                              kCFNumberSInt32Type,
//                              &routeChangeReason
//                              );
//            
//            // "Old device unavailabel" indicates that a headset was unplugged, or that the
//            //	device was removed from a dock connector that supports audio output. This is
//            //	the recommended test for when to pause audio.
//            if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
//
//                if (g_config->IsWithOutEarphonePause())
//                {
//                    [self pause];
//                    //NSLog(@"Output device removed, so application audio was paused.");
//                }
//                
//            } else {
//                
//                //NSLog(@"A route change occurred that does not require pausing of application audio.");
//            }
//        }
    });
}

- (void) onAudioInterruption:(UInt32)interruptionState {
    if (interruptionState == kAudioSessionBeginInterruption)
    {
        //NSLog(@"Audio interruption begin");
        AudioSessionSetActive( false );
        if ([self isPlaying]
            || [self isBuffering])
        {
            [self pause];
            _isInterrpted = TRUE;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_playerEventHandler respondsToSelector:@selector(onPlayer:audioInterruption:)]) {
                    [_playerEventHandler onPlayer:self audioInterruption:interruptionState];
                }
            });
        }
    }
    else if (interruptionState == kAudioSessionEndInterruption)
    {
        //NSLog(@"Audio interruption end");
        AudioSessionSetActive( true );
        //if (IsPaused()) {
        if (_isInterrpted) {
            [self play];
            _isInterrpted = FALSE;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_playerEventHandler respondsToSelector:@selector(onPlayer:audioInterruption:)]) {
                    [_playerEventHandler onPlayer:self audioInterruption:interruptionState];
                }
            });
        }
    }
}

- (void)handleAudioSessionInterruption:(UInt32)interruptionState
{
    [self onAudioInterruption:interruptionState];
}

- (void) handlerDownloadProgress:(int)requestId step:(int)step total:(int)total {
//- (void) handlerDownloadProgress:(DownloadProgressParam*)param {
//    int requestId = param->requestId;
//    int step = param->step;
//    int total = param->total;

    if (!_dldMgr)
        return;

    CAutoLock lock(_lock);
    //NSLog(@"progress id: %p, new: %p len: %d, total: %d", mRequestId, requestId, step, total);
    //ASSERT(!mRequestId || requestId == mRequestId);
    if (requestId != mRequestId)
        return;
    assert (step >= 0 && total > 0 && step <= total);
    assert(mDownloadFileHandle != NULL);
    assert(mStreamFile->IsOpen());
    assert(total == mStreamFile->GetFileSize());
    mStreamFile->SetAvailableDataSize(step);
    float percentTmp = mStreamFile->GetBufferingProgress();
    [self setProgress:percentTmp];
	float rate = mStreamFile->GetBufferingRate(_cacheSize) * 100;
	if (rate < 100.0) {
        //NSLog(@"progress id: %p, new: %p len: %d, total: %d, percent: %.4f%%", mRequestId, requestId, step, total, rate);
    }
    ///*
    if (_isFirstPacket) {
        [self InitKuwoMusicPlayer];
        _isFirstPacket = NO;
        //_cacheSize = total * 0.0001;
    }
    if (!_isFindFrame && (step >= _cacheSize/2 || step >= total)) {
        _isFindFrame = _audioPlayer->ParseStreamFormat();
    }

    //if (!_isFindFrame) {
        //if (mStreamFile->IsBufferingReady(_cacheSize)) {
         //   _isFindFrame = _audioPlayer->ParseStreamFormat();
        //}
        if (_isFindFrame) {
            //if(!_isPlaying)
            if ([self isBuffering])
            {
                if (_startTime == 0) {
                    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
                    _startTime = time - _bufferingStartTime;
                }
                if (mStreamFile->IsBufferingReady(_cacheSize)) {
                    [self startPlay];
                    //_audioPlayer->Play();
                    _cacheSize = [self CalculateBufferSizeForTime:INTERRUPT_CACHE_TIME];
                    //_isPlaying = YES;
                }
            }
        }
    //}

    return;
     //*/

        /*
         if ([self isBuffering]) {
            if (mStreamFile->IsBufferingReady(_cacheSize)) {
                if (_startTime == 0) {
                    NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
                    _startTime = time - _bufferingStartTime;
                }
                [self playInternal];//with no parser!
                _cacheSize = [self CalculateBufferSizeForTime:INTERRUPT_CACHE_TIME];
            }
        }
         //*/
}

- (void) handlerDownloadStatus:(int)requestId status:(int)status {
//- (void) handlerDownloadStatus:(DownloadStatusParam*)param {
//    int requestId = param->requestId;
//    int status = param->status;

    if (!_dldMgr)
        return;

    CAutoLock lock(_lock);
    if (requestId != mRequestId)
        return;

	//NSLog(@"Online playing download state: %d, requestId: %p", status, requestId);
    switch (status)
    {
        case DOWNLOADREQTINGSTATUS:
        {
            assert(!mDownloadFileHandle);
            mDownloadFileHandle = _dldMgr->GetDownloadItem(mRequestId);
            assert(!mStreamFile->IsOpen());
            string file = _dldMgr->getClientFileName(mRequestId);
			//NSLog(@"Online playing requesting: file: %s", file.c_str());
            if (!file.empty())
            {
                int total = _dldMgr->GetDownloadItemFileSize(mRequestId);
                int step = _dldMgr->GetDownloadItemProgress(mRequestId);
                if (total > 0 && step > 0
                    && mStreamFile->OpenFile(file.c_str(), total))
				{
                    mStreamFile->SetBuffering(true, step);
				}
				else
				{
					//NSLog(@"Online playing file not opened: file: %s, step: %d, total: %d", file.c_str(), step, total);
				}
            }
            break;
        }
        case DOWNLOADINGSTATUS:
        {
            if (!mDownloadFileHandle)
                mDownloadFileHandle = _dldMgr->GetDownloadItem(mRequestId);
            if (!mStreamFile->IsOpen())
            {
                string file = _dldMgr->getClientFileName(mRequestId);
				//NSLog(@"Online playing downloading: file: %s", file.c_str());
                if (!file.empty())
                {
                    int total = _dldMgr->GetDownloadItemFileSize(mRequestId);
                    int step = _dldMgr->GetDownloadItemProgress(mRequestId);
                    if (mStreamFile->OpenFile(file.c_str(), total))
                    {
                        mStreamFile->SetBuffering(true, step);
                        break;
                    }
                    else
                    {
						//NSLog(@"Online playing open file failed!");
                        [self onPlaystateChanged:PlayStateBufferingFailed];
                    }
                }
            }
            break;
        }
        case DOWNLOADCOMPLETESTATUS:
//            {
//                NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
//                _bufferingTime = time - _bufferingStartTime;
//            }
//            mRequestId = 0;
//            if (mStreamFile->IsOpen())
//                mStreamFile->SetBuffering(false, AUTO_FILE_SIZE);
            break;
        case DOWNLOADREQFILEDSTATUS:
        case DOWNLOADFAILEDSTATUS:
//            mRequestId = 0;
//            if (mStreamFile->IsOpen())
//            {
//                //NSLog(@"Online playing download state: failed");
//                mStreamFile->SetBuffering(false, mStreamFile->GetAvalilableDataSize());
//                //if ([self isBuffering]) {
//                //    [self playInternal];
//                //}
//            }
//			if (![self isPlaying])
//			{
//				if (_audioPlayer->IsBuffering()) {
//					_audioPlayer->Stop();
//				} else {
//					//NSLog(@"Online playing download state: close file");
//                    //_audioPlayer->CloseAudioStream();
//                    _audioPlayer->Stop();
//					[self closeStreamFile];
//					[self onPlaystateChanged:PlayStateBufferingFailed];
//				}
//			}
            break;
        default:
            break;
    }
}

- (void) handlerDownloadResult:(int)requestId result:(int)result {
//- (void) handlerDownloadResult:(DownloadResultParam*)param {
//    int requestId = param->requestId;
//    int result = param->result;

    if (!_dldMgr)
        return;

    CAutoLock lock(_lock);
    //if (requestId != mRequestId)
    //    return;

    if (result == DLDOk)
    {
        {
            NSTimeInterval time = [NSDate timeIntervalSinceReferenceDate];
            _bufferingTime = time - _bufferingStartTime;
        }
        mRequestId = 0;
        if (mStreamFile->IsOpen())
            mStreamFile->SetBuffering(false, AUTO_FILE_SIZE);
    }
    else
    {
        mRequestId = 0;
        if (mStreamFile->IsOpen())
        {
            //NSLog(@"Online playing download state: failed");
            mStreamFile->SetBuffering(false, mStreamFile->GetAvalilableDataSize());
            //if ([self isBuffering]) {
            //    [self playInternal];
            //}
        }
        if (![self isPlaying])
        {
            if (_audioPlayer->IsBuffering()) {
                _audioPlayer->Stop();
            } else {
                //NSLog(@"Online playing download state: close file");
                //_audioPlayer->CloseAudioStream();
                _audioPlayer->Stop();
                [self closeStreamFile];
                [self onPlaystateChanged:PlayStateBufferingFailed];
            }
        }
    }

    // only for log below.
//    ACTION_RESULT ar = AR_SUCCESS;
//    // download music log
//    switch (result) {
//        case DLDOk:                 //成功
//            ar = AR_SUCCESS;
//            break;
//        case DLDOpenStreamError:    //打开流失败
//        case DLDResumeFialed:       //续传失败
//            ar = AR_CONN_ERROR;
//            break;
//        case DLDReadError:          //读失败（recive 失败）
//            ar = AR_READ_ERROR;
//            break;
//        case DLDTimeOut:            //超时
//        case DLDWriteFileFailed:    //写文件失败
//            ar = AR_FAIL;
//            break;
//        case DLDRequestSongFailed:  //请求歌曲时服务器返回失败（一般是404）
//            ar = AR_NETSRC_ERROR;
//            break;
//        case DLDGetRealSongFailed:  //防盗链失败
//            ar = AR_NETSRC_ERROR;
//            break;
//        case DLDNotNet:
//            ar = AR_NO_NETWORK;
//            break;
//        case DLDFileRemoved:
//        default:
//            ar = AR_FAIL;
//            ASSERT(FALSE);
//            break;
//    }

    //根据状态判断 来确定url的值（是防盗链之前的还是防盗链之后的）
    string url = _dldMgr->GetRealURL(requestId);
    if (!url.empty())
    {
        //RTLog_RequestMusic(ar, NETWORK_NAME, [_mediaItemInfo.title UTF8String], [_mediaItemInfo.artist UTF8String], [_mediaItemInfo.album UTF8String]);
        
//        RTLog_DownloadMusic(ar, NETWORK_NAME, 
//                            [_mediaItemInfo.title UTF8String], [_mediaItemInfo.artist UTF8String], [_mediaItemInfo.album UTF8String], 
//                            [self musicFormat], [self musicBitrate], _mediaItemInfo.duration, 
//                            mStreamFile->GetFileSize(), 0, 0, 0);
    }
    else
    {
        url = _dldMgr->GetRawURL(requestId);
    }
//    RTLog_GetMusicUrl(ar, NETWORK_NAME, [_mediaItemInfo.title UTF8String], [_mediaItemInfo.artist UTF8String], [_mediaItemInfo.album UTF8String], _mediaItemInfo.persistentId);

    if (!url.empty()) {
//        g_config->NetworkStatusTrack(url.c_str(), ar);
    }
}

//- (const char*) musicFormat {
//	const char* format = "Unknow";
//	switch (_audioFormat) {
//		case MP3128:
//		case MP3192:
//		case MP3320:
//		case MP3BitRateUnknow:
//			format = "mp3";
//			break;
//		case AAC48:
//		case AACBitRateUnknow:
//			format = "aac";	break;
//		default:
//			break;
//	}
//
////	char temp[8] = {0};
////	UInt32 big = CFSwapInt32HostToBig(_audioFormatID);
////	memcpy(temp, &big, sizeof(big));
////	sprintf(format, "%s%s", src, temp);
//	return format;
//}

//- (int) musicBitrate {
//	int br = 0;
//	switch (_audioFormat) {
//		case MP3128:
//			br = 128;	break;
//		case MP3192:
//			br = 192;	break;
//		case MP3320:
//			br = 320;	break;
//		case AAC48:
//			br = 48;	break;
//		case MP3BitRateUnknow:
//		case AACBitRateUnknow:
//			br = _audioPlayer->GetBitrate() / 1000;	break;
//		default:
//			break;
//	}
//	return br;
//}

- (BOOL) isLocalMusic {
    return _localMusic;
}

- (int) playResult {
    return _result;
}

- (int) blockCount {
    return _audioPlayer->GetBlockCount();
}

- (uint64_t) blockTime {
	return _audioPlayer->GetBlockTime() / 1000;
}

- (NSTimeInterval) startTime {
    return _startTime;
}

- (NSTimeInterval) bufferingTime {
    return _bufferingTime;
}

@end
