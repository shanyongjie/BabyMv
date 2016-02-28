//
//  KuwoMusicPlayer.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-24.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMDataModel.h"
#import "StreamFile.h"
#import "AudioPlayer.h"
#import "PlayState.h"
#import "MediaPlayerProtocol.h"
#import "PlayerEventHandlerDelegate.h"
#import "AudioPlayerInterruptionDelegate.h"
#import "DownloadManager.h"

@interface DownloadProgressParam : NSObject
{
@public
    int requestId;
    int step;
    int total;
}
@end

@interface DownloadStatusParam : NSObject
{
@public
    int requestId;
    int status;
}
@end

@interface DownloadResultParam : NSObject
{
@public
    int requestId;
    int result;
}
@end


@interface KuwoMusicPlayer : NSObject <MediaPlayerProtocol, AudioPlayerInterruptionDelegate> {
    CAudioPlayer* _audioPlayer;
	
    PlayState _playState;
    
    BOOL _isInterrpted;
    
    BMDataModel* _mediaItemInfo;
    UInt32 _cacheSize;

    id _playerEventHandler;
    
    CStreamFile* mStreamFile;
    
    int mRequestId;
    HANDLE mDownloadFileHandle;
    float _progress; // 0 to 1
    
    DownloadManager* _dldMgr;
    CLock* _lock;
    
    // log
    BOOL _localMusic;
	MediaFormat _audioFormat;
	UInt32 _audioFormatID;
    int _result;
    NSTimeInterval _bufferingStartTime;
    NSTimeInterval _startTime;
    NSTimeInterval _bufferingTime;
    
    //vieriplayer
    volatile BOOL _isFirstPacket;
    volatile BOOL _isFindFrame;
}

@property (nonatomic, readonly) PlayState playState;
@property (nonatomic, copy) BMDataModel* mediaItemInfo;
@property (nonatomic, assign) float progress;
@property (nonatomic, assign) id<PlayerEventHandlerDelegate> playerEventHandler;

// -------------------------------------------------------
// begin MediaPlayerDelegate
- (PlayState) playState;
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

- (float) cacheRate;

// end MediaPlayerDelegate
// -------------------------------------------------------

//- (void) onProgressChanged:(float)progress;
- (void) onPlaystateChanged:(PlayState)state;

- (void) handlerPlayerStateChanged:(AudioStreamState)state oldState:(AudioStreamState)oldState;
- (void) handlerPlayerError:(AudioStreamErrorCode)error;

//- (void) onVolumeChanged;

- (void) handlerDownloadProgress:(int)requestId step:(int)step total:(int)total;
- (void) handlerDownloadStatus:(int)requestId status:(int)status;
- (void) handlerDownloadResult:(int)requestId result:(int)result;
//- (void) handlerDownloadProgress:(DownloadProgressParam*)param;
//- (void) handlerDownloadStatus:(DownloadStatusParam*)param;
//- (void) handlerDownloadResult:(DownloadResultParam*)param;

//- (const char*) musicFormat;
//- (int) musicBitrate;

- (BOOL) isLocalMusic;
- (int) playResult;
- (int) blockCount;
- (uint64_t) blockTime;
- (NSTimeInterval) startTime;
- (NSTimeInterval) bufferingTime;

//vieriplayer
- (BOOL) InitKuwoMusicPlayer; 

@end
