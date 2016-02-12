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
    return model;
}
@end

@implementation BMCollectionDataModel
+(instancetype)parseData:(NSDictionary *)dicData {
    if (!dicData) {
        return nil;
    }
    [super parseData:dicData];
    BMCollectionDataModel* model = [BMCollectionDataModel new];
    model.Rid = dicData[@"collectId"];
    model.Name = dicData[@"collectName"];
    model.Artist = dicData[@"Artist"];
    model.Url = [dicData[@"collectPic"] isEqual:[NSNull null]]?@"":dicData[@"collectPic"];
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
    model.Url = [dicData[@"Url"] isEqual:[NSNull null]]?@"":dicData[@"Url"];;
    model.Artist = dicData[@"Artist"];
    model.CollectionId = nil;
    model.ListenCount = nil;
    model.IsDowned = nil;
    model.DownloadTime = nil;
    model.LastListeningTime = nil;
    return model;
}
@end
