//
//  BMDataModel.m
//  BabyMv
//
//  Created by ma on 2/11/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMDataModel.h"
#import "common.h"

@implementation BMDataModel
+(instancetype)parseData:(NSDictionary *)dicData {
    if (!dicData) {
        return nil;
    }
    BMDataModel* model = [BMDataModel new];
    model.Rid = dicData[@"CateId"];
    model.Name = dicData[@"CateName"];
    model.Artist = @"0";
    model.Url = @"0";
    model.Time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    return model;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        decode_property_object(Rid);
        decode_property_object(Name);
        decode_property_object(Artist);
        decode_property_object(Url);
        decode_property_object(Time);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    encode_property_object(Rid);
    encode_property_object(Name);
    encode_property_object(Artist);
    encode_property_object(Url);
    encode_property_object(Time);
}

- (id)copyWithZone:(NSZone *)zone
{
    BMDataModel* obj = [[self.class allocWithZone:zone] init];
    if (obj)
    {
        obj.Rid         = self.Rid;
        obj.Name    = self.Name;
        obj.Artist    = self.Artist;
        obj.Url      = self.Url;
        obj.Time      = self.Time;
    }
    return obj;
}

- (BOOL)isEqual:(id)obj
{
    if ([obj isKindOfClass:(self.class)])
    {
        return self.Rid == ((BMDataModel*)obj).Rid;
    }
    return FALSE;
}

@end

@implementation BMCollectionDataModel
+(instancetype)parseData:(NSDictionary *)dicData {
    if (!dicData) {
        return nil;
    }
    BMCollectionDataModel* model = [BMCollectionDataModel new];
    model.Rid = dicData[@"collectId"];
    model.Name = dicData[@"collectName"];
    model.Artist = dicData[@"Artist"];
    model.Url = [dicData[@"collectPic"] isEqual:[NSNull null]]?@"":dicData[@"collectPic"];
    model.Time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    model.CateId = nil;
    model.IsFaved = nil;
    model.FavedTime = nil;
    return model;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        decode_property_object(Rid);
        decode_property_object(Name);
        decode_property_object(Artist);
        decode_property_object(Url);
        decode_property_object(Time);
        decode_property_object(CateId);
        decode_property_object(IsFaved);
        decode_property_object(FavedTime);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    encode_property_object(Rid);
    encode_property_object(Name);
    encode_property_object(Artist);
    encode_property_object(Url);
    encode_property_object(Time);
    encode_property_object(CateId);
    encode_property_object(IsFaved);
    encode_property_object(FavedTime);
}

- (id)copyWithZone:(NSZone *)zone
{
    BMCollectionDataModel* obj = [[self.class allocWithZone:zone] init];
    if (obj)
    {
        obj.Rid         = self.Rid;
        obj.Name    = self.Name;
        obj.Artist    = self.Artist;
        obj.Url      = self.Url;// 是否是节点；
        obj.Time      = self.Time;
        obj.CateId     = self.CateId;
        obj.IsFaved     = self.IsFaved;
        obj.FavedTime   = self.FavedTime;
    }
    return obj;
}

- (BOOL)isEqual:(id)obj
{
    if ([obj isKindOfClass:(self.class)])
    {
        return self.Rid == ((BMCollectionDataModel*)obj).Rid;
    }
    return FALSE;
}

@end

@implementation BMListDataModel
+(instancetype)parseData:(NSDictionary *)dicData {
    if (!dicData) {
        return nil;
    }
    BMListDataModel* model = [BMListDataModel new];
    model.Rid = dicData[@"Rid"];
    model.Name = dicData[@"AudioName"];
    model.Artist = dicData[@"Artist"];
    model.Url = [dicData[@"Url"] isEqual:[NSNull null]]?@"":dicData[@"Url"];;
    model.Time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    model.CollectionId = nil;
    model.ListenCount = nil;
    model.IsDowned = nil;
    model.DownloadTime = nil;
    model.LastListeningTime = nil;
    return model;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        decode_property_object(Rid);
        decode_property_object(Name);
        decode_property_object(Artist);
        decode_property_object(Url);
        decode_property_object(Time);
        decode_property_object(CollectionId);
        decode_property_object(ListenCount);
        decode_property_object(IsDowned);
        decode_property_object(DownloadTime);
        decode_property_object(LastListeningTime);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    encode_property_object(Rid);
    encode_property_object(Name);
    encode_property_object(Artist);
    encode_property_object(Url);
    encode_property_object(Time);
    encode_property_object(CollectionId);
    encode_property_object(ListenCount);
    encode_property_object(IsDowned);
    encode_property_object(DownloadTime);
    encode_property_object(LastListeningTime);
}

- (id)copyWithZone:(NSZone *)zone
{
    BMListDataModel* obj = [[self.class allocWithZone:zone] init];
    if (obj)
    {
        obj.Rid         = self.Rid;
        obj.Name    = self.Name;
        obj.Artist    = self.Artist;
        obj.Url      = self.Url;// 是否是节点；
        obj.Time      = self.Time;
        obj.CollectionId     = self.CollectionId;
        obj.ListenCount     = self.ListenCount;
        obj.IsDowned   = self.IsDowned;
        obj.DownloadTime = self.DownloadTime;
        obj.LastListeningTime = self.LastListeningTime;
    }
    return obj;
}

- (BOOL)isEqual:(id)obj
{
    if ([obj isKindOfClass:(self.class)])
    {
        return self.Rid == ((BMListDataModel*)obj).Rid;
    }
    return FALSE;
}

@end

@implementation BMCartoonCollectionDataModel
+(instancetype)parseData:(NSDictionary *)dicData {
    if (!dicData) {
        return nil;
    }
    BMCartoonCollectionDataModel* model = [BMCartoonCollectionDataModel new];
    model.Rid = dicData[@"MvId"];
    model.Name = dicData[@"MvName"];
    model.Artist = dicData[@"Artist"];
    model.Url = [dicData[@"MvPic"] isEqual:[NSNull null]]?@"":dicData[@"MvPic"];
    model.Time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    model.CateId = nil;
    model.IsFaved = nil;
    model.FavedTime = nil;
    return model;
}
@end

@implementation BMCartoonListDataModel
+(instancetype)parseData:(NSDictionary *)dicData {
    if (!dicData) {
        return nil;
    }
    BMCartoonListDataModel* model = [BMCartoonListDataModel new];
    model.Rid = dicData[@"Rid"];
    model.Name = dicData[@"ChapterName"];
    model.Artist = dicData[@"Artist"];
    model.Url = [dicData[@"Url"] isEqual:[NSNull null]]?@"":dicData[@"Url"];;
    model.Time = [NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970]];
    model.PicUrl = [dicData[@"ChapterPic"] isEqual:[NSNull null]]?@"":dicData[@"ChapterPic"];;
    model.CollectionId = nil;
    model.ListenCount = nil;
    model.IsDowned = nil;
    model.DownloadTime = nil;
    model.LastListeningTime = nil;
    return model;
}
@end

