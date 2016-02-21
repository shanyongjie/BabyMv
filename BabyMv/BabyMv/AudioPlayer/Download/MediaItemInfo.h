//
//  MediaItemInfo.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-22.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MPMediaItem.h>

typedef enum _MUSIC_TYPE {
	ONLINE_MUSIC = 0,
	LOCAL_MUSIC,
	IPOD_MUSIC
} MUSIC_TYPE;

typedef enum {
    MediaTypeMPMediaItem = 0,   // iPod media
    MediaTypeLocal,
    MediaTypeOnline,
} KuwoMediaType;

#define IsIPodMedia(mediaType)		((mediaType) == MediaTypeMPMediaItem)
#define IsOnlineMedia(mediaType)	((mediaType) == MediaTypeOnline)
#define IsLocalMedia(mediaType)		((mediaType) == MediaTypeLocal)

typedef enum _MediaFormat {
	MediaFormatUnknow = 0,
    MediaFormatWAV,
    MediaFormatMP3,
    MediaFormatAAC,
    MediaFormatWMA,
	MediaFormatCount,
} MediaFormat;

typedef enum{
    MusicUnknow = 0,//未知格式
    MP3128 = 1, //128kbps mp3
    MP3192, //192kbps mp3
    MP3224,//224kbps mp3
    MP3320,  //320kbps mp3
    AAC48 ,  //48kbps aac
    //AAC32,//32kbps aac
    MP3BitRateUnknow,//MP3 格式 比特率未知
    AACBitRateUnknow,//aac 格式 比特率未知
} CacheMusicFormat;//缓存音乐文件的格式

@interface MediaItemInfo : NSObject <NSCopying> {
    KuwoMediaType type;
    UInt64 persistentId;     // Persistent ID, music id in iPod music lib or server music lib
    NSString* file;
    //NSString* url;
    NSString* source;
    NSString* title;
    NSString* album;
    NSString* artist;
    UInt32 bitRate;
    UInt32 duration;
    NSString* uniqueId;   //unique id for the music, just for lyrics and pictures map
}

@property (nonatomic, assign) KuwoMediaType type;
@property (nonatomic, assign) UInt64 persistentId;
@property (nonatomic, copy) NSString* file;
//@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) NSString* source;
@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* album;
@property (nonatomic, copy) NSString* artist;
@property (nonatomic, assign) UInt32 bitRate;
@property (nonatomic, assign) UInt32 duration;
@property (nonatomic, copy) NSString* uniqueId;

- (id) initWithType:(KuwoMediaType)type;

- (BOOL) isEqual:(MediaItemInfo*)item;

- (BOOL) isIPodMediaItem;

- (NSString*) sourceUrlOfMp3;

+ (MediaItemInfo*) mediaItemInfoWithType:(KuwoMediaType)type;

+ (MediaItemInfo*) mediaItemInfoWithMPMediaItem:(MPMediaItem*)item;

@end
