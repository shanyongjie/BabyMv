/*
 *  AudioPlayer.h
 *  AudioPlayer
 *
 *  Created by YeeLion on 11-4-2.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#include <CoreFoundation/CoreFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#include <pthread.h>
//#include <semaphore.h>

#define INOUT

#include "AutoLock.h"
#include "CAStreamBasicDescription.h"
#include "CAXException.h"
#include "StreamFile.h"

typedef enum
{
	PS_INITIALIZED = 0,
	PS_BUFFERING,
	PS_PLAYING,
	PS_PAUSED,
	PS_STOPPED,
    PS_BUFFERINGFAILED,
    PS_FAILED
} AudioStreamState;

typedef enum
{
	STOP_FLAG_PLAYING = 0,
	STOP_FLAG_EOF,
	STOP_FLAG_USER_ACTION,
	STOP_FLAG_ERROR,
    STOP_FLAG_SEEK,
	STOP_FLAG_BUFFERING
} AudioStopFlag;

typedef enum
{
	E_AUDIO_NO_ERROR = 0,
	E_AUDIO_UNKNOW_ERROR,
	E_AUDIO_NET_CONNECT_FAILED,
    E_AUDIO_FILE_READ_FAILED,
    E_AUDIO_FILE_SEEK_FAILED,
	E_AUDIO_STREAM_GET_PROPERTY_FAILED,
	E_AUDIO_STREAM_SEEK_FAILED,
	E_AUDIO_STREAM_PARSE_BYTES_FAILED,
	E_AUDIO_STREAM_OPEN_FAILED,
	E_AUDIO_STREAM_CLOSE_FAILED,
	E_AUDIO_DATA_NOT_FOUND,
	E_AUDIO_QUEUE_CREATE_FAILED,
	E_AUDIO_QUEUE_BUFFER_ALLOC_FAILED,
	E_AUDIO_QUEUE_ENQUEUE_FAILED,
	E_AUDIO_QUEUE_ADD_LISTENER_FAILED,
	E_AUDIO_QUEUE_REMOVE_LISTENER_FAILED,
	E_AUDIO_QUEUE_START_FAILED,
	E_AUDIO_QUEUE_PAUSE_FAILED,
	E_AUDIO_QUEUE_BUFFER_MISMATCH,
	E_AUDIO_QUEUE_DISPOSE_FAILED,
	E_AUDIO_QUEUE_STOP_FAILED,
	E_AUDIO_QUEUE_FLUSH_FAILED,
	E_AUDIO_QUEUE_GET_TIME_FAILED,
	E_AUDIO_QUEUE_BUFFER_TOO_SMALL
} AudioStreamErrorCode;


typedef void (*AudioPlayerStateHandler) (AudioStreamState state, AudioStreamState oldState, void* handlerData);
typedef void (*AudioPlayerErrorHandler) (AudioStreamErrorCode error, void* handlerData);

//class CPlayerObserver
//{
//public:
//    virtual void OnPlayerStateChange(AudioStreamState state, AudioStreamState stateOld) = 0;
//    virtual void OnPlayerError(AudioStreamErrorCode error) = 0;
//};

#define kAQNumberBuffers    3
#define kAQDefaultBufSize   4096
#define kAQMaxPacketDescs   512

#define kBufferDurationSeconds 1.f

#define kAudioStreamBufSize 1024    // just make the I/O efficitily, and not too large to parse one time.


//#define LOG_AUDIO_FILE_CONTENT

class CAudioPlayer
{
public:
    CAudioPlayer();
    ~CAudioPlayer();
    
public:
    BOOL Initialize();
    BOOL Uninitialize();
    
public:
    //BOOL SetObserver(CPlayerObserver* pObserver);
    void SetEventHandler(AudioPlayerStateHandler stateHandler, AudioPlayerErrorHandler errorHandler, void* handlerData);
    
public:
    BOOL OpenStreamFile(CStreamFile* pStreamFile, AudioFileTypeID audioFileTypeHint, UInt32 bitrate);
    //vieriplayer
    BOOL InitCAudioPlayer(CStreamFile* pStreamFile, AudioFileTypeID audioFileTypeHint, UInt32 bitrate);
    BOOL Play();
    BOOL Pause();
    BOOL Stop();
    
    BOOL Seek(float time);

    Float64 GetSchedule();
    Float64 GetDuration();
    
    Float32 GetVolume() const;
    BOOL SetVolume(Float32 volume);
    
    AudioStreamState GetPlayState() const;
    BOOL IsOpen() const;
    BOOL IsBuffering() const;
    BOOL IsPlaying() const;
    BOOL IsPaused() const;
    
public:
	UInt32 GetBitrate() const;
	UInt32 GetFormatID() const;
	
    int GetBlockCount() const;
	uint64_t GetBlockTime() const;// milliseconds
    
    BOOL ParseStreamFormat();

private:
    BOOL OpenAudioStream(CStreamFile* pStreamFile, AudioFileTypeID audioFileTypeHint);
    BOOL ReopenAudioStream();
    void CloseAudioStream();
    
    BOOL CreateAudioQueue();
    BOOL StartAudioQueue();
    BOOL PauseAudioQueue();
    BOOL StopAudioQueue(BOOL immediate);
    void ReleaseAudioQueue();

    BOOL GetAudioFileFormat(AudioStreamBasicDescription* pFormat, UInt64* pDataOffset, int* pBitrate, double* pDuration);
    BOOL CalculateBitRate();

    BOOL CalculateBufferSizeForTime(float time, UInt32* outPackets, UInt32* outBufferSize);
    BOOL CalculatePacketsSizeForSeekTime(float time, SInt64* outPackets, SInt64* outBytesOffset);
    
private:
    // Audio Queue callbacks
    void AudioQueueOutputProc(AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer);
    static void AudioQueueOutputCallback(void* inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer);
    
    void AudioQueueIsRunningProc(AudioQueueRef inAudioQueue, AudioQueuePropertyID inID);
    static void AudioQueueIsRunningCallback(void* inUserData, AudioQueueRef inAudioQueue, AudioQueuePropertyID inID);
    
    void AudioStreamPropertyListenerProc(AudioFileStreamID          inAudioFileStream, 
                                         AudioFileStreamPropertyID  inPropertyID, 
                                         UInt32                     *ioFlags);
    static void AudioStreamPropertyListenerCallback(void                        *inUserData, 
                                                    AudioFileStreamID           inAudioFileStream, 
                                                    AudioFileStreamPropertyID   inPropertyID, 
                                                    UInt32                      *ioFlags);
    
    void AudioStreamPacketsProc(UInt32                          inNumberBytes,
                                UInt32                          inNumberPackets,
                                const void                      *inInputData,
                                AudioStreamPacketDescription    *inPacketDescriptions);
    static void AudioStreamPacketsCallback (void                            *inUserData,
                                            UInt32                          inNumberBytes,
                                            UInt32                          inNumberPackets,
                                            const void                      *inInputData,
                                            AudioStreamPacketDescription    *inPacketDescriptions);
    
    //void AudioSessionInterruptionListenerProc(UInt32 inInterruptionState);
    //static void AudioSessionInterruptionListenerCallback(void* inUserData, UInt32 inInterruptionState);
        
private:
    void SetPlayState(AudioStreamState state);

    void SetErrorCode(AudioStreamErrorCode error);
    
    void NotifyStateChange(AudioStreamState state, AudioStreamState stateOld);
    void NotifyError(AudioStreamErrorCode error);

private:
    BOOL Reset();

	// parse some data, until the first packet(s) data parsed.
	//BOOL ParseStreamFormat();

	// read and parse some data, fill packets into mAudioBuffer, or cache it into mAudioBufferCache.
	// this action will be done in AudioStreamPacketsCallback or AudioStreamPacketsProc.
	BOOL ParseStreamData();

	// store some packets data in filling buffer.
	BOOL FillStreamBufferPackets(AudioQueueBufferRef pAudioBuffer, UInt32& nVbrPacketCount, AudioStreamPacketDescription* pVbrPacketDescs,
								 UInt32 nBytes, UInt32 nPackets, 
								 const void* pPacketData, AudioStreamPacketDescription* pPacketDescs, 
                                 UInt32& nBytesOffset, UInt32& nPacketStart);

	// fill buffer, the buffer really be filled is mAudioBuffer. 
	UInt32 FillStreamBuffer();

	// copy packets cached to filling buffer, this just switch the tow buffers.
	UInt32 FillStreamBufferFromCache();

	// enqueue the filled buffer to the audio queue, and reset mAudioBuffer to NULL. 
	BOOL EnqueueStreamBuffer();

     // return number of empty buffer
    int AddEmptyBuffer(AudioQueueBufferRef buffer);
    AudioQueueBufferRef GetEmptyBuffer(BOOL erase);
    BOOL ResetEmptyBuffer();
    BOOL IsAllBufferEmpty() const;
    
private:
    //CPlayerObserver*    m_pObserver;
    AudioPlayerStateHandler m_stateHandler;
    AudioPlayerErrorHandler m_errorHandler;
    void*                   m_handlerData;

//    dispatch_queue_t        m_dispatch_queue;

    AudioQueueRef					mAudioQueue;
    BOOL                            mPlaying;
    
    CStreamFile*                    m_pStreamFile;
    
    AudioFileTypeID                 mAudioType;
    AudioFileStreamID               mAudioStream;
    CAStreamBasicDescription		mAudioFormat;
    
    AudioQueueBufferRef				mAudioBuffers[kAQNumberBuffers + 1];
    AudioQueueBufferRef				mAudioBuffersEmpty[kAQNumberBuffers];
    UInt32                          mEmptyBufferCount;

	AudioQueueBufferRef				mAudioBuffer;
	UInt32                          mVbrPacketCount;
    AudioStreamPacketDescription    mVbrPacketDescs[kAQMaxPacketDescs];

	AudioQueueBufferRef				mAudioBufferCache;	// this is one item in mAudioBuffers, just the extra one.
	UInt32                          mVbrPacketCountCache;
    AudioStreamPacketDescription    mVbrPacketDescsCache[kAQMaxPacketDescs];

    pthread_mutex_t                 mBufferMutex;
    
    Float64                         mSchedule;
    Float64                         mDuration;
    Float64                         mSeekTime;

    UInt32                          mFragmentOffset;
    UInt32                          mFragmentSize;
    
    Float32                         mVolume;

    UInt32                          mDataOffset;
    UInt32                          m_nAudioDataSize;
    UInt32                          mMaxPacketSize;
    BOOL                            mReadyToProducePackets;
    
    UInt32                          mBitRate;
    Float64                         mSampleRate;
    Float64                         mPacketDuration;
    UInt32                          mNumberOfChannels;
    BOOL                            mIsVbr;

    AudioStreamState                mPlayState;
    BOOL                            mFlushEof;
    BOOL                            mBuffering;
    pthread_mutex_t                 mBufferingMutex;
    pthread_cond_t                  mBufferingCondition;

    BOOL                            m_bSeeking;
    BOOL                            m_bStoping;
    
    int m_blockCount;
	uint64_t m_blockTime;
	struct timeval m_tmv;

#ifdef LOG_AUDIO_FILE_CONTENT
    char mParseFile[512];
    char mEnqueneFile[512];
    char mPlayFile[512];
    char mReadFile[512];
#endif
};

