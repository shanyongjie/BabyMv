/*
 *  AudioPlayer.cpp
 *  AudioPlayer
 *
 *  Created by YeeLion on 11-4-2.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#include <sys/time.h>
#include <algorithm>
#if TARGET_OS_IPHONE
#import <CFNetwork/CFNetwork.h>
#define kCFCoreFoundationVersionNumber_MIN 550.32
#else
#define kCFCoreFoundationVersionNumber_MIN 550.00
#endif
#include "utility.h"
#include "logger.h"
#include "AudioPlayer.h"
//extern char* path1;
//extern char* path2;
//extern char* path3;

//#define PAUSE_BEFORE_BUFFER_EMPTY


#if 0
#define pthread_mutex_lock(mutex) { printf("lock %p, line: %d\n", mutex, __LINE__); pthread_mutex_lock(mutex); printf("locked line: %d\n", __LINE__); }
#define pthread_mutex_unlock(mutex) { printf("unlock %p, line: %d\n", mutex, __LINE__); pthread_mutex_unlock(mutex); }
#define pthread_cond_signal(cond) { printf("signal %p, line: %d\n", cond,  __LINE__); pthread_cond_signal(cond); }
#define pthread_cond_wait(cond, mutex) { printf("wait %p, %p, line: %d\n", cond, mutex, __LINE__); pthread_cond_wait(cond, mutex); printf("waited line: %d\n", __LINE__); }
#define pthread_cond_timewait(cond, mutex, time) { printf("wait %p, %p, line: %d\n", cond, mutex, __LINE__); pthread_cond_timewait(cond, mutex, time); printf("waited line: %d\n", __LINE__); }

#define Lock() Lock(__LINE__)
#define Unlock() Unlock(__LINE__)
#endif

inline void LogAudioError(OSStatus err, int line, const char* msg = NULL)
{
    fprintf(stderr, "Audio error occured: %08x - \"%s\" line: %d msg: %s\n", (int)err, CAX4CCString(err).get(), line, msg ? msg : "");
}

inline void LogAudioMessage(const char* format, ...)
{
	va_list args;
	va_start(args, format);
	vfprintf(stdout, format, args);
	va_end(args);
}

#define intstr2(x) #x
#define intstr(x) intstr2(x)

#if (defined DEBUG) || (defined _DEBUG)
#define LogAudioError(err, msg) LogAudioError(err, __LINE__, msg)
#define LogAudioMessage(format...) LogAudioMessage("Audio message (" intstr(__LINE__) "): " format)
#else
#define LogAudioError(...)
#define LogAudioMessage(...)
#endif


CAudioPlayer::CAudioPlayer()
{
    //Initialize();
	
	m_blockCount = 0;
	m_blockTime = 0;
}

CAudioPlayer::~CAudioPlayer()
{
    Uninitialize();
}

BOOL CAudioPlayer::Initialize()
{
    //m_pObserver = NULL;
    m_stateHandler = NULL;
    m_errorHandler = NULL;
    m_handlerData = NULL;
    
    pthread_mutex_init(&mBufferMutex, NULL);
    
    pthread_mutex_init(&mBufferingMutex, NULL);
    pthread_cond_init(&mBufferingCondition, NULL);
    
    mVolume = 1.0;

//    char name[32] = {0};
//    sprintf(name, "com.misty.audioplayer_%08x", (int)this);
//    m_dispatch_queue = dispatch_queue_create(name, nil);

    Reset();
    
    /*(AudioSessionInitialize (
                            NULL,                          // 'NULL' to use the default (main) run loop
                            NULL,                          // 'NULL' to use the default run loop mode
                            AudioSessionInterruptionListenerCallback,  // a reference to your interruption callback
                            this                            // data to pass to your interruption listener callback
                            );
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );

    AudioSessionSetActive(true);*/
        
    return TRUE;
}

BOOL CAudioPlayer::Uninitialize()
{
    Stop();
    
    //AudioSessionSetActive(false);

    pthread_mutex_destroy(&mBufferMutex);
    
    pthread_mutex_destroy(&mBufferingMutex);
    pthread_cond_destroy(&mBufferingCondition);

//    dispatch_release(m_dispatch_queue);

    return TRUE;
}

//BOOL CAudioPlayer::SetObserver(CPlayerObserver* pObserver)
//{
//    return (m_pObserver = pObserver) != NULL;
//}
void CAudioPlayer::SetEventHandler(AudioPlayerStateHandler stateHandler, AudioPlayerErrorHandler errorHandler, void* handlerData)
{
    m_stateHandler = stateHandler;
    m_errorHandler = errorHandler;
    m_handlerData = handlerData;
}

BOOL CAudioPlayer::OpenStreamFile(CStreamFile* pStreamFile, AudioFileTypeID audioFileTypeHint, UInt32 bitrate)
{
    if (IsPlaying() || IsPaused())
        Stop();

	CloseAudioStream();
    
	if (!OpenAudioStream(pStreamFile, audioFileTypeHint))
		return FALSE;
    mBitRate = bitrate;

    m_blockCount = 0;
	m_blockTime = 0;
    
    //return YES;
	return ParseStreamFormat();
}

BOOL CAudioPlayer::InitCAudioPlayer(CStreamFile* pStreamFile, AudioFileTypeID audioFileTypeHint, UInt32 bitrate){
    if (IsPlaying() || IsPaused())
        Stop();
    
	CloseAudioStream();
    
	if (!OpenAudioStream(pStreamFile, audioFileTypeHint))
		return FALSE;
    mBitRate = bitrate;
    
    m_blockCount = 0;
	m_blockTime = 0;
    return YES;
}

BOOL CAudioPlayer::Play()
{
    if (!m_pStreamFile || !m_pStreamFile->IsOpen())
        return FALSE;

	//m_bIsWaitingForPlay = TRUE;
    if (!mAudioQueue
        && !CreateAudioQueue())	// create audio queue and all buffers.
    {
        SetPlayState(PS_FAILED);
        return FALSE;
    }

	if (mBuffering)
	{
		struct timeval tmv;
		gettimeofday(&tmv, NULL);
		uint64_t elapsed = GetTimeElapsed(&m_tmv, &tmv);
		m_blockTime += elapsed / 1000;
	}
	
    pthread_mutex_lock(&mBufferMutex);
	assert(mAudioQueue != NULL);
    assert(mAudioBuffer == NULL);

	while((mAudioBuffer = GetEmptyBuffer(FALSE)))
	{
		UInt32 size = FillStreamBuffer();
        if (size == 0)
        {
            mAudioBuffer = NULL;
            break;
        }
        if (!EnqueueStreamBuffer())
        {
			ResetEmptyBuffer();
            pthread_mutex_unlock(&mBufferMutex);
            SetPlayState(PS_FAILED);
			return FALSE;
		}
		GetEmptyBuffer(TRUE);
	}
    pthread_mutex_unlock(&mBufferMutex);

    // none buffer is filled
    if (IsAllBufferEmpty())
    {
		if (IsBuffering() && mBuffering)
		{
			SetPlayState(PS_BUFFERING);
		}
		else
		{
			Stop();
		}
        return TRUE;
    }
#ifdef PAUSE_BEFORE_BUFFER_EMPTY
    mBuffering = FALSE;
#endif
	
    return StartAudioQueue();
}

BOOL CAudioPlayer::Pause()
{
    //if (!IsPlaying() && !IsBuffering())
    //    return FALSE;
    
    if (!PauseAudioQueue())
        return FALSE;
    
    SetPlayState(PS_PAUSED);
    return TRUE;
}

BOOL CAudioPlayer::Stop()
{
    if (!mAudioQueue)
        return TRUE;
    
    LogAudioMessage("Stop mPlaying: %d\n", mPlaying);
    if (mPlaying)
    {
        LogAudioMessage("Stopping... %p\n", this);
        m_bStoping = TRUE;
        StopAudioQueue(TRUE);
        while (mPlaying) {
            usleep(10*1000);
        }
        m_bStoping = FALSE;
        LogAudioMessage("Stopped... %p\n", this);
    }
    
    BOOL bIsBufferingFailed = (m_pStreamFile && m_pStreamFile->IsOpen()) 
                              ? m_pStreamFile->IsEof() && m_pStreamFile->IsBufferingFailed() 
                              : FALSE;
    CloseAudioStream();
	
    ReleaseAudioQueue();
    
    if (IsBuffering() || IsPlaying() || IsPaused()) {
        if (bIsBufferingFailed)
            SetPlayState(PS_BUFFERINGFAILED);
        else
            SetPlayState(PS_STOPPED);
    }

    Reset();
    
    return TRUE;
}

BOOL CAudioPlayer::Seek(float time)
{
    if (!mAudioQueue)
        return FALSE;
    if (!mPacketDuration)
        return FALSE;

    SInt64 seekBytesOffset = 0;
    SInt64 seekNumPackets = 0;
    if (!CalculatePacketsSizeForSeekTime(time, &seekNumPackets, &seekBytesOffset))
    {
        SetErrorCode(E_AUDIO_FILE_SEEK_FAILED);
        return FALSE;
    }
    SInt64 seekFileOffset = seekBytesOffset + mDataOffset;
    
    pthread_mutex_lock(&mBufferingMutex);
    if (m_pStreamFile->GetAvalilableDataSize() < seekFileOffset)
    {
        pthread_mutex_unlock(&mBufferingMutex);
        return FALSE;
    }
    pthread_mutex_unlock(&mBufferingMutex);

    m_bSeeking = TRUE;

    if (!StopAudioQueue(TRUE))
    {
        SetErrorCode(E_AUDIO_QUEUE_STOP_FAILED);
        return FALSE;
    }
    while (mPlaying) {
        usleep(10*1000);
    }
 
    pthread_mutex_lock(&mBufferingMutex);
    ResetEmptyBuffer();
    m_pStreamFile->Seek((UInt32)seekFileOffset, SEEK_SET);
    //mSeekTime = time;
    mSeekTime = seekBytesOffset * 8.0 / mBitRate;
    //mSeekTime = seekNumPackets * mPacketDuration;
    m_bSeeking = FALSE;
    mSchedule = mSeekTime;
    pthread_mutex_unlock(&mBufferingMutex);
    
    if (IsPlaying() || IsBuffering()) {
        return Play();
    }
    return TRUE;
}

Float64 CAudioPlayer::GetSchedule()
{
    if (!mReadyToProducePackets || mSampleRate == 0.f || !mAudioQueue)
        return 0.f;
    
    if (!IsPlaying() && !IsBuffering())
        return mSchedule;
    
//    const OSStatus kAudioQueueStopped = 0x73746F70; // 0x73746F70 is 'stop'
    AudioTimeStamp queueTime;
    Boolean discontinuity;
    OSStatus err = AudioQueueGetCurrentTime(mAudioQueue, NULL, &queueTime, &discontinuity);
    if (err != noErr)
    {
//		const OSStatus kAudioQueueStopped = 0x73746F70; // 0x73746F70 is 'stop'
//		LogAudioError(err, "AudioQueueGetCurrentTime failed");
//		if (err != kAudioQueueStopped)
//			SetErrorCode(E_AUDIO_QUEUE_GET_TIME_FAILED);
        return mSchedule;
    }
    
    Float64 schedule = mSeekTime + queueTime.mSampleTime / mSampleRate;
    mSchedule = schedule > 0.f ? schedule : 0.f;
    
    return mSchedule;
}

Float64 CAudioPlayer::GetDuration()
{
    if (mDuration == 0.f)
    {
        if (!mReadyToProducePackets || mBitRate == 0.f)
            return 0.f;

        mDuration = (Float64)m_nAudioDataSize / (mBitRate * 0.125);
    }
    return mDuration;
}

Float32 CAudioPlayer::GetVolume() const
{
    return mVolume;
}

BOOL CAudioPlayer::SetVolume(Float32 volume)
{
    if (volume < 0)
        volume = 0;
    else if (volume > 1)
        volume = 1;
    if (mAudioQueue) {
        AudioQueueSetParameter(mAudioQueue, kAudioQueueParam_Volume, volume);
    }
    mVolume = volume;
    return TRUE;
}

AudioStreamState CAudioPlayer::GetPlayState() const
{
    return mPlayState;
}

BOOL CAudioPlayer::IsOpen() const
{
    return m_pStreamFile != NULL;
}

BOOL CAudioPlayer::IsBuffering() const
{
    if (m_pStreamFile)
    {
        return m_pStreamFile->IsBuffering();
    }
    
    return mPlayState == PS_BUFFERING;
}

BOOL CAudioPlayer::IsPlaying() const
{
    return mPlayState == PS_PLAYING;
}

BOOL CAudioPlayer::IsPaused() const
{
    return mPlayState == PS_PAUSED;
}

UInt32 CAudioPlayer::GetBitrate() const
{
	return mBitRate;
}

UInt32 CAudioPlayer::GetFormatID() const
{
	return mAudioFormat.mFormatID;
}
 
int CAudioPlayer::GetBlockCount() const
{
    return m_blockCount;
}

uint64_t CAudioPlayer::GetBlockTime() const
{
	return m_blockTime;
}

BOOL CAudioPlayer::OpenAudioStream(CStreamFile* pStreamFile, AudioFileTypeID audioFileTypeHint)
{
    LogAudioMessage("OpenAudioStream: %p\n", this);

    assert (!mAudioStream);
    assert (m_pStreamFile == NULL);
    if (!pStreamFile || !pStreamFile->IsOpen())
    {
        LogAudioMessage("Open audio file failed!\n");
        assert(FALSE);
        return FALSE;
    }
#ifdef LOG_AUDIO_FILE_CONTENT
    NSLog(@"File Path: %s", pStreamFile->GetFilePath());
    strcpy(mParseFile, pStreamFile->GetFilePath());
    strcat(mParseFile, ".psr");
    
    strcpy(mPlayFile, pStreamFile->GetFilePath());
    strcat(mPlayFile, ".ply");
    
    strcpy(mEnqueneFile, pStreamFile->GetFilePath());
    strcat(mEnqueneFile, ".enq");
    
    strcpy(mReadFile, pStreamFile->GetFilePath());
    strcat(mReadFile, ".red");
#endif
    m_pStreamFile = pStreamFile;
    OSStatus err = AudioFileStreamOpen(this, AudioStreamPropertyListenerCallback, AudioStreamPacketsCallback, audioFileTypeHint, &mAudioStream);
    if (noErr != err)
    {
        LogAudioError(err, "can't open file path");
        SetErrorCode(E_AUDIO_STREAM_OPEN_FAILED);
        return FALSE;
    }
    
    return TRUE;
}

void CAudioPlayer::CloseAudioStream()
{
    pthread_mutex_lock(&mBufferingMutex);
    if (mAudioStream)
    {
        AudioFileStreamClose(mAudioStream);
        mAudioStream = NULL;
    }
    m_pStreamFile = NULL;
    memset(&mAudioFormat, 0, sizeof(mAudioFormat));
    m_nAudioDataSize = 0;
    mReadyToProducePackets = FALSE;
    mBuffering = FALSE;
    pthread_mutex_unlock(&mBufferingMutex);
}

BOOL CAudioPlayer::CreateAudioQueue()
{
    LogAudioMessage("CreateAudioQueue()");
	mSampleRate = mAudioFormat.mSampleRate;
	mPacketDuration = mAudioFormat.mFramesPerPacket / mSampleRate;
	
	mNumberOfChannels = mAudioFormat.mChannelsPerFrame;
	
	// create the audio queue
	OSStatus err = AudioQueueNewOutput(&mAudioFormat, CAudioPlayer::AudioQueueOutputCallback, this, NULL, NULL, 0, &mAudioQueue);
    if (err != noErr)
    {
        LogAudioError(err, "Create new audio queue failed");
        SetErrorCode(E_AUDIO_QUEUE_CREATE_FAILED);
        return FALSE;
    }
	
	// listen to the "isRunning" property
	err = AudioQueueAddPropertyListener(mAudioQueue, kAudioQueueProperty_IsRunning, AudioQueueIsRunningCallback, this);
    if (err != noErr)
    {
        LogAudioError(err, "adding property listener failed");
        ReleaseAudioQueue();
        SetErrorCode(E_AUDIO_QUEUE_ADD_LISTENER_FAILED);
        return FALSE;
    }
	
	// get the packet size if it is available
    UInt32 packetBufferSize = 0;
	/*if (mIsVbr)
	{
		UInt32 sizeOfUInt32 = sizeof(UInt32);
		err = AudioFileStreamGetProperty(mAudioStream, kAudioFileStreamProperty_PacketSizeUpperBound, &sizeOfUInt32, &packetBufferSize);
		if (err != noErr || packetBufferSize == 0)
		{
            LogAudioError(err, "Audio stream get packet size upper bound failed");
			err = AudioFileStreamGetProperty(mAudioStream, kAudioFileStreamProperty_MaximumPacketSize, &sizeOfUInt32, &packetBufferSize);
			if (err != noErr || packetBufferSize == 0)
			{
                LogAudioError(err, "Audio stream get packet maximum packet size failed");
				// No packet size available, just use the default
				packetBufferSize = kAQDefaultBufSize;
			}
		}
	}
	else
	{
		packetBufferSize = kAQDefaultBufSize;
	}*/
    
    UInt32 bufferSize = 0;
    if (this->CalculateBufferSizeForTime(kBufferDurationSeconds, NULL, &bufferSize))
        packetBufferSize = bufferSize;
    else
        packetBufferSize = kAQDefaultBufSize;
        
    // allocate audio queue buffers
	for (unsigned int i = 0; i < kAQNumberBuffers + 1; ++i)
	{
		err = AudioQueueAllocateBuffer(mAudioQueue, packetBufferSize, &mAudioBuffers[i]);
		if (err != noErr)
		{
            LogAudioError(err, "Audio queue alloc buffer failed");
            ReleaseAudioQueue();
            SetErrorCode(E_AUDIO_QUEUE_BUFFER_ALLOC_FAILED);
			return FALSE;
		}
	}
    ResetEmptyBuffer();
    
	// get the cookie size and data, and set it for audio queue.
	UInt32 cookieSize;
	Boolean writable;
	err = AudioFileStreamGetPropertyInfo(mAudioStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, &writable);
	if (err == noErr)
	{
        if (void* cookieData = malloc(cookieSize))
        {
            err = AudioFileStreamGetProperty(mAudioStream, kAudioFileStreamProperty_MagicCookieData, &cookieSize, cookieData);
            if (err == noErr)
            {
                // set the cookie on the queue.
                err = AudioQueueSetProperty(mAudioQueue, kAudioQueueProperty_MagicCookie, cookieData, cookieSize);
            }
            free(cookieData);
        }
    }
    
	// set the volume of the queue
	err = AudioQueueSetParameter(mAudioQueue, kAudioQueueParam_Volume, mVolume);
    if (err != noErr)
    {
        LogAudioError(err, "Audio queue set volume failed");
    };

    return TRUE;
}

BOOL CAudioPlayer::StartAudioQueue()
{
    if (!mAudioQueue)
        return FALSE;

    LogAudioMessage("StartAudioQueue(%p)\n", mAudioQueue);
	int attempt = 3;	// retry 3 times
	while (true)
	{
		OSStatus err;
		//kAudioQueueHardwareCodecPolicy_Default
		UInt32 codec = kAudioQueueHardwareCodecPolicy_PreferHardware;
		err = AudioQueueSetProperty(mAudioQueue, kAudioQueueProperty_HardwareCodecPolicy, &codec, sizeof(codec));
		if (err != noErr)
			LogAudioError(err, "SetAudioQueueCodecPolicy failed.");

		err = AudioQueueStart(mAudioQueue, NULL);
		if (err == noErr)
			break;

		LogAudioError(err, "StartAudioQueue failed.");
		//const OSStatus kAudioQueueBufferError = 0x21627566; // 0x73746F70 is '!buf'
		//const OSStatus kAudioQueueErrorNope = 'nope';
		if (/*err == kAudioQueueBufferError &&*/ --attempt > 0)
		{
			//mSeekTime = m_pStreamFile->GetFilePos() * 8.0 / mBitRate;
			usleep(10*1000);
			continue;
		}
		
		SetErrorCode(E_AUDIO_QUEUE_START_FAILED);
		return FALSE;
	}

    SetPlayState(PS_PLAYING);

    return TRUE;
}

BOOL CAudioPlayer::PauseAudioQueue()
{
    if (!mAudioQueue)
        return FALSE;        
    
    LogAudioMessage("PauseAudioQueue(%p)\n", mAudioQueue);
    OSStatus err = AudioQueuePause(mAudioQueue);
    if (err != noErr)
    {
        LogAudioError(err, "AudioQueuePause failed");
        SetErrorCode(E_AUDIO_QUEUE_PAUSE_FAILED);
        return FALSE;
    }
    SetPlayState(PS_PAUSED);
    
    return TRUE;
}

BOOL CAudioPlayer::StopAudioQueue(BOOL immediate)
{
    if (!mAudioQueue)
        return FALSE;

    LogAudioMessage("StopAudioQueue(%p)\n", mAudioQueue);
    
//    AudioQueuePause(mAudioQueue);

    OSStatus err = AudioQueueStop(mAudioQueue, immediate);  // lock this line could lead a dead-lock
    if (err != noErr)
    {
        LogAudioError(err, "AudioQueueStop failed");
        SetErrorCode(E_AUDIO_QUEUE_STOP_FAILED);
    }

    return !err;
}

void CAudioPlayer::ReleaseAudioQueue()
{
    LogAudioMessage("ReleaseAudioQueue(%p)\n", mAudioQueue);
    if (mAudioQueue)
    {
        AudioQueueDispose(mAudioQueue, true);
        mAudioQueue = 0;
    }
    memset(mAudioBuffers, 0, sizeof(mAudioBuffers));
    memset(mAudioBuffersEmpty, 0, sizeof(mAudioBuffersEmpty));
    mVbrPacketCount = 0;
    mVbrPacketCountCache = 0;
}

BOOL CAudioPlayer::GetAudioFileFormat(AudioStreamBasicDescription* pFormat, UInt64* pDataOffset, int* pBitrate, double* pDuration)
{
    if (!IsOpen() || IsBuffering())
        return FALSE;
    CFURLRef inputFileURL = CFURLCreateFromFileSystemRepresentation (kCFAllocatorDefault, (const UInt8 *)m_pStreamFile->GetFilePath(), strlen(m_pStreamFile->GetFilePath()), false);
    if (!inputFileURL)
        return FALSE;

    AudioFileID inputFile;
	OSStatus err = AudioFileOpenURL(inputFileURL, kAudioFileReadPermission, 0, &inputFile);
//	XThrowIfError (err, "AudioFileOpen");
    if (0 != err) {
        return NO;
    }

    if (pFormat)
    {
        bool doPrint = true;
        UInt32 size;
        AudioFileGetPropertyInfo(inputFile, kAudioFilePropertyFormatList, &size, NULL);
        if (0 != err) {
            return NO;
        }
        
        UInt32 numFormats = size / sizeof(AudioFormatListItem);
        AudioFormatListItem *formatList = new AudioFormatListItem [ numFormats ];

        AudioFileGetProperty(inputFile, kAudioFilePropertyFormatList, &size, formatList);
        if (0 != err) {
            return NO;
        }
        
        numFormats = size / sizeof(AudioFormatListItem); // we need to reassess the actual number of formats when we get it
        if (numFormats == 1) {
            // this is the common case
            *pFormat = formatList[0].mASBD;
        } else {
            if (doPrint) {
                printf ("File has a %d layered data format:\n", (int)numFormats);
                for (unsigned int i = 0; i < numFormats; ++i)
                    CAStreamBasicDescription(formatList[i].mASBD).Print();
                printf("\n");
            }
            // now we should look to see which decoders we have on the system
            AudioFormatGetPropertyInfo(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &size);
            if (0 != err) {
                return NO;
            }
            
            UInt32 numDecoders = size / sizeof(OSType);
            OSType *decoderIDs = new OSType [ numDecoders ];
            AudioFormatGetProperty(kAudioFormatProperty_DecodeFormatIDs, 0, NULL, &size, decoderIDs);
            if (0 != err) {
                return NO;
            }
            
            unsigned int i = 0;
            for (; i < numFormats; ++i) {
                OSType decoderID = formatList[i].mASBD.mFormatID;
                bool found = false;
                for (unsigned int j = 0; j < numDecoders; ++j) {
                    if (decoderID == decoderIDs[j]) {
                        found = true;
                        break;
                    }
                }
                if (found) break;
            }
            delete [] decoderIDs;
            
            if (i >= numFormats) {
                fprintf (stderr, "Cannot play any of the formats in this file\n");
                throw kAudioFileUnsupportedDataFormatError;
            }
            *pFormat = formatList[i].mASBD;
        }
        delete [] formatList;
    }

    if (pDataOffset)
    {
        // Get the data offset, packet and frame count.
        UInt64 dataOffset = 0;
        UInt32 size = sizeof(dataOffset);
        AudioFileGetProperty(inputFile, kAudioFilePropertyDataOffset, &size, &dataOffset);
        if (0 != err) {
            return NO;
        }
        *pDataOffset = dataOffset;
    }

    if (pDuration)
    {
        double duration = 0.0;
        UInt32 size = sizeof(duration);
        AudioFileGetProperty(inputFile, kAudioFilePropertyEstimatedDuration, &size, &duration);
        if (0 != err) {
            return NO;
        }
        *pDuration = duration;
    }

    if (pBitrate)
    {
        int bitrate = 0.0;
        UInt32 size = sizeof(bitrate);
        AudioFileGetProperty(inputFile, kAudioFilePropertyBitRate, &size, &bitrate);
        *pBitrate = bitrate;
    }

    AudioFileClose(inputFile);
    CFRelease(inputFileURL);

    return true;
}

BOOL CAudioPlayer::CalculateBitRate()
{
    if (!mAudioStream)
        return FALSE;
    
    if (mBitRate != 0)
        return TRUE;
    
    UInt32 bitRate;
    UInt32 bitRateSize = sizeof(bitRate);
    OSStatus err = AudioFileStreamGetProperty(mAudioStream, kAudioFileStreamProperty_BitRate, &bitRateSize, &bitRate);
    if (noErr == err)
    {
        mBitRate = bitRate;
        if (mBitRate % 1000) {  // kbps
//            assert(mBitRate < 1000);
            mBitRate *= 1000;
        }
        LogAudioMessage("Audio stream file bitRate from property: %d, calc: %d\n", (int)bitRate, (int)mBitRate);
    }
    else
    {
        LogAudioError(err, "AudioFileStreamGetProperty failed.\n");
        bitRate = 8 * mAudioFormat.mSampleRate * mAudioFormat.mBytesPerPacket * mAudioFormat.mFramesPerPacket;
        if (bitRate != 0)
        {
            mBitRate = bitRate;
        }
        else
        {
            int bitrate = 0;
            if (GetAudioFileFormat(NULL, NULL, &bitrate, NULL))
                mBitRate = bitrate;
        }

        if (!mBitRate)
        {
            //从文件名读取码率
            std::string tmpStr = m_pStreamFile->GetFilePath();
            int pos = tmpStr.rfind(".");
            if (pos == -1) {
//                assert(pos != -1);
                mBitRate = 48 * 1000;
            }else{
                std::string tmp = tmpStr.substr(pos+1,tmpStr.length() - pos);
                if (3 > tmp.length()) {
                    return 0;
                }
                tmp = tmp.substr(1,3);
                uint d = 0;
                sscanf(tmp.c_str(),"%u",&d);
                if(d > 1000 || d == 0){
                    mBitRate = 48 * 1000;
                }
                else{
                    mBitRate = d * 1000;
                }
            }
        }
    }
    LogAudioMessage("Audio stream file bitRate calculated: %d\n", (int)mBitRate);
    return mBitRate;
}

BOOL CAudioPlayer::CalculateBufferSizeForTime(float time, UInt32* outPackets, UInt32* outBufferSize)
{
    CalculateBitRate();
    if (!mBitRate)
        return FALSE;
    
    if (outPackets)
        *outPackets = ceil(time / mPacketDuration);
    
    if (outBufferSize)
        *outBufferSize = mBitRate / 8 * time;
    
    return TRUE;
}

BOOL CAudioPlayer::CalculatePacketsSizeForSeekTime(float time, SInt64* outPackets, SInt64* outBytesOffset)
{
    UInt32 ioFlags = 0;
    SInt64 seekBytesOffset = 0;
    SInt64 seekNumPackets = (SInt64)floor(time / mPacketDuration);
    OSStatus err = AudioFileStreamSeek(mAudioStream, seekNumPackets, &seekBytesOffset, &ioFlags);
    if (err != noErr)
    {
        LogAudioError(err, "AudioFileStreamSeek failed");
        return FALSE;
    }
    if (outPackets)
        *outPackets = seekNumPackets;
    if (outBytesOffset)
        *outBytesOffset = seekBytesOffset;
    
    return TRUE;
}

// Audio Queue callbacks
void CAudioPlayer::AudioQueueOutputProc(AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer)
{
#ifdef LOG_AUDIO_FILE_CONTENT
    FILE* fp = fopen(mPlayFile, "a+b");
    fwrite(inBuffer->mAudioData, 1, inBuffer->mAudioDataByteSize, fp);
    fclose(fp);
#endif

    LogAudioMessage("AudioQueueOutput AudioBuffer: %p\n", inBuffer);

    GetSchedule();
    pthread_mutex_lock(&mBufferMutex);
    if (m_bSeeking || m_bStoping)
    {
        AddEmptyBuffer(inBuffer);
        pthread_mutex_unlock(&mBufferMutex);
        return;
    }
    
    //pthread_mutex_lock(&mBufferMutex);
    mAudioBuffer = inBuffer;
	UInt32 size = FillStreamBuffer();
    if (size == 0
        || !EnqueueStreamBuffer())
    {
        AddEmptyBuffer(inBuffer);
        mAudioBuffer = NULL;
    }
    mAudioBuffer = NULL;
    pthread_mutex_unlock(&mBufferMutex);
    
#ifdef PAUSE_BEFORE_BUFFER_EMPTY
    if (mBuffering) {
        PauseAudioQueue();
        SetPlayState(PS_BUFFERING);
        ++m_blockCount;
		gettimeofday(&m_tmv, NULL);
    }
#endif
    
    if (IsAllBufferEmpty())	// no buffer enqueued.
    {
#ifndef PAUSE_BEFORE_BUFFER_EMPTY
        if (mBuffering) {
            PauseAudioQueue();
			SetPlayState(PS_BUFFERING);
            ++m_blockCount;
			gettimeofday(&m_tmv, NULL);
        }
		else
#endif
        if (m_bSeeking) {
            // do not change state
        } else /*if (mFlushEof)*/ { // no more buffer is enqueued, stop immediately.
            StopAudioQueue(FALSE);
            //SetPlayState(PS_STOPPED);
            //NSLog(@"AudioQueueOutputProc stopped");
        }
    }
}

void CAudioPlayer::AudioQueueOutputCallback(void* inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef inBuffer)
{
    CAudioPlayer* pThis = (CAudioPlayer*)inUserData;
    LogAudioMessage("AudioQueueOutputCallback: %p\n", pThis);
    pThis->AudioQueueOutputProc(inAudioQueue, inBuffer);
}

void CAudioPlayer::AudioQueueIsRunningProc(AudioQueueRef inAudioQueue, AudioQueuePropertyID inID)
{
    LogAudioMessage("AudioQueueIsRunningProc()\n");
    if (inID != kAudioQueueProperty_IsRunning)
        return;
    
    assert(inAudioQueue == mAudioQueue);
    
    UInt32 playing = 0;
    UInt32 size = sizeof(playing);
    OSStatus err = AudioQueueGetProperty(inAudioQueue, kAudioQueueProperty_IsRunning, &playing, &size);
    if (err != noErr)
    {
        LogAudioError(err, "AudioQueue get property isRunning failed");
    }
    LogAudioMessage("AudioQueueIsRunningProc() AudioQueue %s.\n", playing ? "started" : "stopped");

    if (mPlaying != playing)
    {
        mPlaying = playing;
        if (mPlaying)
        {
            SetPlayState(PS_PLAYING);
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                Stop();
            });
        }
    }
}

void CAudioPlayer::AudioQueueIsRunningCallback(void *inUserData, AudioQueueRef inAudioQueue, AudioQueuePropertyID inID)
{
    CAudioPlayer* pThis = (CAudioPlayer*)inUserData;
    pThis->AudioQueueIsRunningProc(inAudioQueue, inID);
}

void CAudioPlayer::AudioStreamPropertyListenerProc(AudioFileStreamID inAudioFileStream, 
                                                   AudioFileStreamPropertyID inPropertyID, 
                                                   UInt32* ioFlags)
{
    assert(inAudioFileStream == mAudioStream);
    LogAudioMessage("Audio stream property: %s\n", CAX4CCString(inPropertyID).get());
    OSStatus err= noErr;
    if (inPropertyID == kAudioFileStreamProperty_ReadyToProducePackets)
    {
        mReadyToProducePackets = true;
    }
    else if (inPropertyID == kAudioFileStreamProperty_DataOffset)
    {
        UInt64 offset;
        UInt32 offsetSize = sizeof(offset);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataOffset, &offsetSize, &offset);
        if (err)
        {
            LogAudioError(err, "AudioFileStream get data offset failed");
            SetErrorCode(E_AUDIO_STREAM_GET_PROPERTY_FAILED);
            return;
        }
        mDataOffset = (UInt32)offset;
        m_nAudioDataSize = m_pStreamFile->GetFileSize() - mDataOffset;
    }
    else if (inPropertyID == kAudioFileStreamProperty_AudioDataByteCount)
    {
        UInt64 dataByteCount;
        UInt32 byteCountSize = sizeof(dataByteCount);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_AudioDataByteCount, &byteCountSize, &dataByteCount);
        if (err)
        {
            LogAudioError(err, "AudioFileStream get audio data byte count failed");
            SetErrorCode(E_AUDIO_STREAM_GET_PROPERTY_FAILED);
            return;
        }
        if (m_pStreamFile->GetFileSize() - mDataOffset > dataByteCount)
        {
            m_nAudioDataSize = (UInt32)dataByteCount;
        }
    }
    else if (inPropertyID == kAudioFileStreamProperty_FileFormat)
    {
        UInt32 type;
        UInt32 typeSize = sizeof(type);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_FileFormat, &typeSize, &type);
        if (err)
        {
            LogAudioError(err, "AudioFileStream get file type failed");
            SetErrorCode(E_AUDIO_STREAM_GET_PROPERTY_FAILED);
            return;
        }
        LogAudioMessage("Audio file format: %s\n", CAX4CCString(type).get());
        mAudioType = type;
    }
    else if (inPropertyID == kAudioFileStreamProperty_DataFormat)
    {
        if (mAudioFormat.mSampleRate == 0)
        {
            UInt32 asbdSize = sizeof(mAudioFormat);
            
            // get the stream format.
            err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_DataFormat, &asbdSize, &mAudioFormat);
            if (err)
            {
                LogAudioError(err, "AudioFileStream get data format failed");
                SetErrorCode(E_AUDIO_STREAM_GET_PROPERTY_FAILED);
                return;
            }
            mSampleRate = mAudioFormat.mSampleRate;
            //LogAudioMessage("Audio stream file format: %s, SampleRate: %d\n", CAX4CCString(mAudioFormat.mFormatID).get(), (int)mSampleRate);
        }
    }
    else if(inPropertyID == kAudioFileStreamProperty_BitRate)
    {
        UInt32 bitRate;
        UInt32 bitRateSize = sizeof(bitRate);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_BitRate, &bitRateSize, &bitRate);
        if (err)
        {
            LogAudioError(err, "AudioFileStream get bit rate count failed");
            SetErrorCode(E_AUDIO_STREAM_GET_PROPERTY_FAILED);
            return;
        }
        mBitRate = bitRate;
        if (mBitRate % 1000) {  // kbps
            assert(mBitRate < 1000);
            mBitRate *= 1000;
        }
        LogAudioMessage("Audio stream file bitRate in header: %d, calc: %d\n", (int)bitRate, (int)mBitRate);
    }
    else if (inPropertyID == kAudioFileStreamProperty_FormatList)
    {
        Boolean outWriteable;
        UInt32 formatListSize;
        err = AudioFileStreamGetPropertyInfo(inAudioFileStream, kAudioFileStreamProperty_FormatList, &formatListSize, &outWriteable);
        if (err)
        {
            LogAudioError(err, "AudioFileStream get format list info failed");
            SetErrorCode(E_AUDIO_STREAM_GET_PROPERTY_FAILED);
            return;
        }
        
        AudioFormatListItem *formatList = (AudioFormatListItem*)malloc(formatListSize);
        err = AudioFileStreamGetProperty(inAudioFileStream, kAudioFileStreamProperty_FormatList, &formatListSize, formatList);
        if (err)
        {
            free(formatList);
            LogAudioError(err, "AudioFileStream get format list failed");
            SetErrorCode(E_AUDIO_STREAM_GET_PROPERTY_FAILED);
            return;
        }
        
        for (int i = 0; i * sizeof(AudioFormatListItem) < formatListSize; i += sizeof(AudioFormatListItem))
        {
            AudioStreamBasicDescription pasbd = formatList[i].mASBD;
            
            if(pasbd.mFormatID == kAudioFormatMPEG4AAC_HE_V2 && 
#if TARGET_OS_IPHONE			
//               [[UIDevice currentDevice] platformHasCapability:(UIDeviceSupportsARMV7)] &&
#endif
               kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_MIN)
            {
                // We found HE-AAC v2 (SBR+PS), but before trying to play it
                // we need to make sure that both the hardware and software are
                // capable of doing so...
                //NSLog(@"HE-AACv2 found!");
#if !TARGET_IPHONE_SIMULATOR
                mAudioFormat = pasbd;
#endif
                break;
            } else if (pasbd.mFormatID == kAudioFormatMPEG4AAC_HE)
            {
                //
                // We've found HE-AAC, remember this to tell the audio queue
                // when we construct it.
                //
#if !TARGET_IPHONE_SIMULATOR
                mAudioFormat = pasbd;
#endif
                break;
            }                                
        }
        free(formatList);
    }
}

void CAudioPlayer::AudioStreamPropertyListenerCallback(void*                        inUserData, 
                                                       AudioFileStreamID            inAudioFileStream, 
                                                       AudioFileStreamPropertyID    inPropertyID, 
                                                       UInt32*                      ioFlags)
{
    CAudioPlayer* pThis = (CAudioPlayer*)inUserData;
    pThis->AudioStreamPropertyListenerProc(inAudioFileStream, inPropertyID, ioFlags);
}

void CAudioPlayer::AudioStreamPacketsProc(UInt32                          inNumberBytes,
                                          UInt32                          inNumberPackets,
                                          const void                      *inInputData,
                                          AudioStreamPacketDescription    *inPacketDescs)
{
//    UInt32                          inNumberBytes1 = inNumberBytes;
//    UInt32                          inNumberPackets1 = inNumberPackets;
//    const void                      *inInputData1 = inInputData;
//    AudioStreamPacketDescription    *inPacketDescs1 = inPacketDescs;
    
    // we have successfully read the first packests from the audio stream, so
    // clear the "discontinuous" flag
    if (!mReadyToProducePackets)
        mReadyToProducePackets = TRUE;
    
    if (inPacketDescs) {
        mIsVbr = TRUE;
    }
    
    if (!mBitRate) {
        CalculateBitRate();
    }
    
	if (!mAudioQueue
		&& !CreateAudioQueue())	// create audio queue and all buffers.
		return;

    UInt32 nBytesOffset = 0;
    UInt32 nPacketStart = 0;

//    _setdbglogfile(path1);
//    _dbglog_hex(inInputData, inNumberBytes);
    
    if (mAudioBuffer 
        // for VBR format, some packet is too large to store in current buffer, 
        // but some next packet is smaller! for this condition, we should not save it in current buffer.
        && mAudioBufferCache->mAudioDataByteSize == 0)
    {
        if (!FillStreamBufferPackets(mAudioBuffer, mVbrPacketCount, mVbrPacketDescs,
                                     inNumberBytes, inNumberPackets, inInputData, inPacketDescs,
                                     nBytesOffset, nPacketStart))
            return;
    }

	if (inNumberBytes > nBytesOffset)
	{
		if (!FillStreamBufferPackets(mAudioBufferCache, mVbrPacketCountCache, mVbrPacketDescsCache,
                                     inNumberBytes, inNumberPackets, inInputData, inPacketDescs,
                                     nBytesOffset, nPacketStart))
            return;
	}
	if (inNumberBytes > nBytesOffset)
	{
//		assert(FALSE);	// buffer is too small!
	}
}

void CAudioPlayer::AudioStreamPacketsCallback (void                            *inUserData,
                                               UInt32                          inNumberBytes,
                                               UInt32                          inNumberPackets,
                                               const void                      *inInputData,
                                               AudioStreamPacketDescription    *inPacketDescriptions)
{
    CAudioPlayer* pThis = (CAudioPlayer*)inUserData;
    pThis->AudioStreamPacketsProc(inNumberBytes, inNumberPackets, inInputData, inPacketDescriptions);
}

/*
void CAudioPlayer::AudioSessionInterruptionListenerProc(UInt32 inInterruptionState)
{
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
        if (IsPlaying())
            Pause();
	}
	else if (inInterruptionState == kAudioSessionEndInterruption)
	{
		AudioSessionSetActive( true );
		if (IsPaused())
            Play();
	}
}

void CAudioPlayer::AudioSessionInterruptionListenerCallback(void* inUserData, UInt32 inInterruptionState)
{
    CAudioPlayer* pThis = (CAudioPlayer*)inUserData;
    pThis->AudioSessionInterruptionListenerProc(inInterruptionState);
}
*/

void CAudioPlayer::SetPlayState(AudioStreamState state)
{
    if (mPlayState == state)
        return;
    AudioStreamState stateOld = mPlayState;
    mPlayState = state;
    NotifyStateChange(mPlayState, stateOld);
}

void CAudioPlayer::SetErrorCode(AudioStreamErrorCode error)
{
    NotifyError(error);
}

void CAudioPlayer::NotifyStateChange(AudioStreamState state, AudioStreamState stateOld)
{
    LogAudioMessage("state change: %d -> %d\n", stateOld, state);
    //if (m_pObserver)
    //    m_pObserver->OnPlayerStateChange(state, stateOld);
    if (m_stateHandler) {
        (*m_stateHandler)(state, stateOld, m_handlerData);
    }
}

void CAudioPlayer::NotifyError(AudioStreamErrorCode error)
{
    //if (m_pObserver)
    //    m_pObserver->OnPlayerError(error);
    if (m_errorHandler) {
        (*m_errorHandler)(error, m_handlerData);
    }
}

BOOL CAudioPlayer::Reset()
{
    LogAudioMessage("Reset... %p\n", this);
    mAudioQueue = NULL;
    mPlaying = FALSE;
    
    mPlayState = PS_STOPPED;//PS_INITIALIZED;
    
    mReadyToProducePackets = FALSE;
    
	m_pStreamFile = NULL;
	
	mAudioType = 0;
    mAudioStream = NULL;
    memset(&mAudioFormat, 0, sizeof(mAudioFormat));
    
	memset(mAudioBuffers, 0, sizeof(mAudioBuffers));
	memset(mAudioBuffersEmpty, 0, sizeof(mAudioBuffersEmpty));
    mEmptyBufferCount = 0;
    mAudioBuffer = NULL;
	mVbrPacketCount = 0;
	mAudioBufferCache = NULL;
	mVbrPacketCountCache = 0;
    
    mSchedule = 0.f;
    mDuration = 0.f;
    mSeekTime = 0.f;
    
    mDataOffset = 0;
    m_nAudioDataSize = 0;
    mMaxPacketSize = 0;
    
    mBitRate = 0;
    mSampleRate = 0.f;
    mPacketDuration = 0.f;
    mNumberOfChannels = 0;
    mIsVbr = FALSE;
    
    m_bSeeking = FALSE;
    m_bStoping = FALSE;
	
	m_blockCount = 0;
	m_blockTime = 0;
    
    return TRUE;
}

// parse some data, until the first packet(s) data parsed.
BOOL CAudioPlayer::ParseStreamFormat()
{
	while(!mReadyToProducePackets)
	{
        BOOL bRet = ParseStreamData();
        //NSLog(@"bRet = %d",bRet);
		if (!bRet){
			//NSLog(@"bRet = %d",bRet);
            break;
        }
	}
	return mReadyToProducePackets;
}

// read and parse some data, fill packets into mAudioBuffer, or cache it into mAudioBufferCache.
// this action will be done in AudioStreamPacketsCallback or AudioStreamPacketsProc.
BOOL CAudioPlayer::ParseStreamData()
{
	//ASSERT(m_pStreamFile->IsOpen());
	//ASSERT(mAudioStream != NULL);
    if (!mAudioStream || 
        !m_pStreamFile || !m_pStreamFile->IsOpen())
        return FALSE;

    const int nBufferSize = kAudioStreamBufSize;
    Byte pbBuffer[nBufferSize];
    UInt32 size = nBufferSize;

	int len = m_pStreamFile->Read(pbBuffer, size);
	if (len > 0)
	{
#ifdef LOG_AUDIO_FILE_CONTENT
        FILE* fp = fopen(mReadFile, "a+b");
        fwrite(pbBuffer, 1, len, fp);
        fclose(fp);
#endif
		UInt32 flag = mReadyToProducePackets ? 0 : kAudioFileStreamParseFlag_Discontinuity;
		OSStatus err = AudioFileStreamParseBytes(mAudioStream, len, pbBuffer, flag);
		if (err)
		{
			LogAudioMessage("AudioFileStreamParseBytes error: %s\n", CAX4CCString(err).get());
			SetErrorCode(E_AUDIO_STREAM_PARSE_BYTES_FAILED);
			return FALSE;
		}
	}
    
#ifdef PAUSE_BEFORE_BUFFER_EMPTY
    if (mAudioBuffer && m_pStreamFile->IsBuffering() 
        && !m_pStreamFile->IsBufferingReady(mAudioBuffer->mAudioDataBytesCapacity))
    {
        mBuffering = TRUE;
        mFlushEof = FALSE;
    }
#endif
    
	if (len < size)
	{
		if (m_pStreamFile->IsBuffering())
        {
			mBuffering = TRUE;
            mFlushEof = FALSE;
        }
		else if(m_pStreamFile->IsEof())
        {
            mBuffering = FALSE;
			mFlushEof = TRUE;
        }
	}

	return (BOOL)(len > 0);
}

// fill buffer, the buffer really be filled is mAudioBuffer. 
UInt32 CAudioPlayer::FillStreamBuffer()
{
	assert (mAudioBuffer != NULL);
//	ASSERT (mVbrPacketCount == 0);//felix?
    if (!mAudioBuffer)//felix?
        return 0;
    if (mVbrPacketCount != 0) {
        LogAudioMessage("Logic error: mVbrPacketCount is not 0, last enqueue buffer may be failed.\n");
    }

    mAudioBuffer->mAudioDataByteSize = 0;
    mAudioBuffer->mPacketDescriptionCount = 0;

	// flush cache first.
	FillStreamBufferFromCache();

	while (mAudioBufferCache->mAudioDataByteSize == 0	// no cache data, buffer may not be filled completed.
		&& mAudioBuffer->mAudioDataByteSize < mAudioBuffer->mAudioDataBytesCapacity
		&& mVbrPacketCount < kAQMaxPacketDescs)
	{
		if (!ParseStreamData())
			break;
	}

    return mAudioBuffer->mAudioDataByteSize;
}

// store some packets data in filling buffer.
BOOL CAudioPlayer::FillStreamBufferPackets(AudioQueueBufferRef pAudioBuffer, UInt32& nVbrPacketCount, AudioStreamPacketDescription* pVbrPacketDescs,
                                           UInt32 nBytes, UInt32 nPackets, 
                                           const void* pPacketData, AudioStreamPacketDescription* pPacketDescs, 
                                           UInt32& nBytesOffset, UInt32& nPacketStart)
{
	assert(pAudioBuffer != NULL);

    // the following code assumes we're streaming VBR data. for CBR data, the second branch is used.
	if (pPacketDescs)
	{
        int packetIndex = nPacketStart;
        while (packetIndex < nPackets)
        {
            SInt64 packetOffset = pPacketDescs[packetIndex].mStartOffset;
            SInt64 packetSize   = pPacketDescs[packetIndex].mDataByteSize;
            if (packetSize > pAudioBuffer->mAudioDataBytesCapacity - pAudioBuffer->mAudioDataByteSize
                || nVbrPacketCount >= kAQMaxPacketDescs)
                break;

//            if (pAudioBuffer != mAudioBufferCache
//                && mAudioBufferCache->mAudioDataByteSize != 0)
//            {
//                ASSERT(false);
//            }
//            static int count = 0;
//            static int pos = 0;
//            count++;
//            pos += packetSize;
            //LogAudioMessage("================================= %d packet: %d, buffering: %d\n", count, pos, (int)(pAudioBuffer == mAudioBufferCache));
            // copy data to the audio queue buffer
            memcpy((Byte*)pAudioBuffer->mAudioData + pAudioBuffer->mAudioDataByteSize, (const Byte*)pPacketData + packetOffset, (size_t)packetSize);
            pVbrPacketDescs[nVbrPacketCount] = pPacketDescs[packetIndex];
            pVbrPacketDescs[nVbrPacketCount].mStartOffset = pAudioBuffer->mAudioDataByteSize;
            pAudioBuffer->mAudioDataByteSize += packetSize;
            nVbrPacketCount++;
            ++packetIndex;
            //nBytesOffset += packetSize;
            nBytesOffset = (UInt32)(packetOffset + packetSize);
            ++nPacketStart;
        }
    }
	else
	{
		// copy data
        assert(nBytes >= nBytesOffset);
		UInt32 copySize = std::min(nBytes - nBytesOffset, pAudioBuffer->mAudioDataBytesCapacity - pAudioBuffer->mAudioDataByteSize);
		memcpy((Byte*)pAudioBuffer->mAudioData + pAudioBuffer->mAudioDataByteSize, (const Byte*)pPacketData + nBytesOffset, copySize);
		pAudioBuffer->mAudioDataByteSize += copySize;
		nBytesOffset += copySize;
    }
    
	return TRUE;
}

// copy packets cached to filling buffer, this just switch the tow buffers.
UInt32 CAudioPlayer::FillStreamBufferFromCache()
{
	assert(mAudioBuffer != NULL);
	assert(mAudioBufferCache != NULL);
    if (mAudioBufferCache->mAudioDataByteSize == 0)
        return 0;
    
	AudioQueueBufferRef temp = mAudioBuffer;

	mAudioBuffer = mAudioBufferCache;
	mVbrPacketCount = mVbrPacketCountCache;
	memcpy(mVbrPacketDescs, mVbrPacketDescsCache, sizeof(mVbrPacketDescs[0]) * mVbrPacketCountCache);

	mAudioBufferCache = temp;
	mVbrPacketCountCache = 0;
/*
    memcpy(mAudioBuffer->mAudioData, mAudioBufferCache->mAudioData, mAudioBufferCache->mAudioDataByteSize);
	mAudioBuffer->mAudioDataByteSize = mAudioBufferCache->mAudioDataByteSize;
	memcpy(mVbrPacketDescs, mVbrPacketDescsCache, sizeof(AudioStreamPacketDescription) * mVbrPacketCountCache);
	mVbrPacketCount = mVbrPacketCountCache;
    LogAudioMessage("Read cache: %d bytes", mAudioBuffer->mAudioDataByteSize);
	mAudioBufferCache->mAudioDataByteSize = 0;
	mVbrPacketCountCache = 0;
*/
	return mAudioBuffer->mAudioDataByteSize;
}

// enqueue the filled buffer to the audio queue, and reset mAudioBuffer to NULL. 
BOOL CAudioPlayer::EnqueueStreamBuffer()
{
    assert(mAudioQueue != NULL);
	assert(mAudioBuffer != NULL);

//    _setdbglogfile(path2);
//    _dbglog_hex(mAudioBuffer->mAudioData, mAudioBuffer->mAudioDataByteSize);
#ifdef LOG_AUDIO_FILE_CONTENT
    FILE* fp = fopen(mEnqueneFile, "a+b");
    fwrite(mAudioBuffer->mAudioData, 1, mAudioBuffer->mAudioDataByteSize, fp);
    fclose(fp);
#endif
    LogAudioMessage("Enqueue AudioBuffer: %p\n", mAudioBuffer);
    OSStatus err = AudioQueueEnqueueBuffer(mAudioQueue, mAudioBuffer, mVbrPacketCount, mVbrPacketDescs);
    if (err != noErr)
    {
        LogAudioError(err, "AudioQueueEnqueueBuffer failed");
        SetErrorCode(E_AUDIO_QUEUE_ENQUEUE_FAILED);
        return FALSE;
    }

	mAudioBuffer = NULL;
	mVbrPacketCount = 0;
    return TRUE;
}

 // return number of empty buffer
int CAudioPlayer::AddEmptyBuffer(AudioQueueBufferRef buffer)
{
    assert(mEmptyBufferCount < kAQNumberBuffers);
    buffer->mAudioDataByteSize = 0;
    buffer->mPacketDescriptionCount = 0;
    mAudioBuffersEmpty[mEmptyBufferCount++] = buffer;
    return mEmptyBufferCount;
}

AudioQueueBufferRef CAudioPlayer::GetEmptyBuffer(BOOL erase)
{
    AudioQueueBufferRef buffer = mAudioBuffersEmpty[0];
    if (buffer != NULL && erase)
    {
        assert(0 < mEmptyBufferCount && mEmptyBufferCount <= kAQNumberBuffers);
        --mEmptyBufferCount;
        int i = 0;
        while (i < mEmptyBufferCount)
        {
            mAudioBuffersEmpty[i] = mAudioBuffersEmpty[i + 1];
            ++i;
        }
        mAudioBuffersEmpty[mEmptyBufferCount] = NULL;
    }
    return buffer;
}

BOOL CAudioPlayer::ResetEmptyBuffer()
{
    for (unsigned int i = 0; i < kAQNumberBuffers + 1; ++i)
    {
        if (AudioQueueBufferRef buffer = mAudioBuffers[i])
        {
            buffer->mAudioDataByteSize = 0;
            buffer->mPacketDescriptionCount = 0;
        }
    }

    // make all buffer empty.
	memcpy(mAudioBuffersEmpty, mAudioBuffers, sizeof(mAudioBuffersEmpty));
    mEmptyBufferCount = kAQNumberBuffers;
    mAudioBuffer = NULL;
	mVbrPacketCount = 0;

	mAudioBufferCache = mAudioBuffers[kAQNumberBuffers];
	mVbrPacketCountCache = 0;
    
	return TRUE;
}

BOOL CAudioPlayer::IsAllBufferEmpty() const
{
    return mEmptyBufferCount == kAQNumberBuffers;
}
