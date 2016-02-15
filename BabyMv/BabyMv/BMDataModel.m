//
//  BMDataModel.m
//  BabyMv
//
//  Created by ma on 2/11/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMDataModel.h"

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

