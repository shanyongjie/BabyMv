//
//  BMDataModel.h
//  BabyMv
//
//  Created by ma on 2/11/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _MediaFormat {
    MediaFormatUnknow = 0,
    MediaFormatMP3,
    MediaFormatAAC,
    MediaFormatWMA,
    MediaFormatWAV,
    MediaFormatCount,
} MediaFormat;

inline const char* GetFormatString(MediaFormat format)
{
    const char* s_mediaFormat[MediaFormatCount] = {
        "",
        "mp3",
        "aac",
        "wma",
        "wav",
    };
    return s_mediaFormat[format];
}

@interface BMDataModel : NSObject<NSCopying, NSCoding>
@property(nonatomic, strong)NSNumber* Rid;
@property(nonatomic, strong)NSString* Name;
@property(nonatomic, strong)NSString* Artist;
@property(nonatomic, strong)NSString* Url;
@property(nonatomic, strong)NSNumber* Time;

+(instancetype)parseData:(NSDictionary *)dicData;
@end

@interface BMCollectionDataModel : BMDataModel<NSCopying, NSCoding>
@property(nonatomic, strong)NSNumber* CateId;
@property(nonatomic, strong)NSNumber* IsFaved;
@property(nonatomic, strong)NSNumber* FavedTime;

+(instancetype)parseData:(NSDictionary *)dicData;
@end

@interface BMListDataModel : BMDataModel<NSCopying, NSCoding>
@property(nonatomic, strong)NSNumber* CollectionId;
@property(nonatomic, strong)NSNumber* ListenCount;
@property(nonatomic, strong)NSNumber* IsDowned;
@property(nonatomic, strong)NSNumber* DownloadTime;
@property(nonatomic, strong)NSNumber* LastListeningTime;

+(instancetype)parseData:(NSDictionary *)dicData;
@end

@interface BMCartoonCollectionDataModel : BMCollectionDataModel
+(instancetype)parseData:(NSDictionary *)dicData;
@end

@interface BMCartoonListDataModel : BMListDataModel<NSCopying>
@property(nonatomic, strong)NSString* PicUrl;

+(instancetype)parseData:(NSDictionary *)dicData;
@end

