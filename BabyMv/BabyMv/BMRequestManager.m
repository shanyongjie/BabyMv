//
//  BMRequestManager.m
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMRequestManager.h"
#import "MacroDefinition.h"
#import "BMDataModel.h"
#import "BMDataBaseManager.h"
#import "BMDataCacheManager.h"

#import <AFNetworking.h>




@implementation BMRequestManager

+(instancetype)sharedInstance {
    static BMRequestManager* requestManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestManager = [BMRequestManager new];
    });
    return requestManager;
}

+(void)loadCategoryData {
    [[BMRequestManager sharedInstance] loadCategoryData];
}

-(void)loadCategoryData{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString* url = MUSIC_CATE;
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
                                                                            options:0
                                                                              error:nil]:nil;
        NSArray* dataList = dic[@"dataList"];
        if ([[NSNull null] isEqual:dataList] ||!dataList.count) {
            NSLog(@"loadCategoryData zero object");
            return;
        }
        NSMutableArray* musicCateArr = [NSMutableArray new];
        for (NSDictionary* cateDic in dataList) {
            BMDataModel* musicCate = [BMDataModel parseData:cateDic];
            [musicCateArr addObject:musicCate];
        }
        if ([[BMDataBaseManager sharedInstance] addMusicCateArr:musicCateArr]) {
            [BMDataCacheManager setMusicCate:musicCateArr];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_CATEGORY_DATA_FINISHED object:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

-(void)loadCollectionData {
    NSArray* arr = [[BMDataBaseManager sharedInstance] getAllMusicCate];
    for (BMDataModel* musicCate in arr) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSString* url = MUSIC_COLLECT(musicCate.Rid);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                options:0
                                                                                  error:nil]:nil;
            NSArray* collectList = dic[@"CollectList"];
            NSArray* songList = dic[@"SongList"];
            NSMutableArray* musicCollectArr = [NSMutableArray new];
            NSMutableArray* musicListArr = [NSMutableArray new];
            if ([[NSNull null] isEqual:collectList] ||!collectList.count || [[NSNull null] isEqual:songList] ||!songList.count) {
                NSLog(@"loadCollectionData zero object");
                return;
            }
            for (NSDictionary* cateDic in collectList) {
                BMCollectionDataModel* musicCollection = [BMCollectionDataModel parseData:cateDic];
                musicCollection.CateId = musicCate.Rid;
                [musicCollectArr addObject:musicCollection];
            }
            for (NSDictionary* musicDic in songList) {
                BMListDataModel* musicList = [BMListDataModel parseData:musicDic];
                musicList.CollectionId = musicCate.Rid;
                [musicListArr addObject:musicList];
            }
//            [BMDataCacheManager setCurrentMusicList:musicListArr];
            
            if ([[BMDataBaseManager sharedInstance] addMusicCollectionArr:musicCollectArr]) {
                [BMDataCacheManager setMusicCollection:musicCollectArr];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_COLLECTION_DATA_FINISHED object:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

-(void)loadListData {
    NSArray* arr = [[BMDataBaseManager sharedInstance] getAllMusicCollection];
    if (!arr.count) {
        NSLog(@"zero object");
        return;
    }
    for (BMCollectionDataModel* listData in arr) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.securityPolicy.allowInvalidCertificates = YES;
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSString* url = MUSIC_LIST(listData.Rid);
        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                options:0
                                                                                  error:nil]:nil;
            NSArray* dataList = dic[@"dataList"];
            NSMutableArray* musicListArr = [NSMutableArray new];
            if ([[NSNull null] isEqual:dataList] ||!dataList.count) {
                NSLog(@"loadListData zero object");
                return;
            }
            for (NSDictionary* musicDic in dataList) {
                BMListDataModel* music = [BMListDataModel parseData:musicDic];
                music.CollectionId = listData.Rid;
                [musicListArr addObject:music];
            }
            
            if ([[BMDataBaseManager sharedInstance] addMusicListArr:musicListArr]) {
                [BMDataCacheManager setMusicList:musicListArr];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_LIST_DATA_FINISHED object:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@", error);
        }];
    }
}

-(void)loadCollectionDataWithCategoryId:(NSNumber *)musicCateId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString* url = MUSIC_COLLECT(musicCateId);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
                                                                            options:0
                                                                              error:nil]:nil;
        NSArray* collectList = dic[@"CollectList"];
        NSArray* songList = dic[@"SongList"];
        NSMutableArray* musicCollectArr = [NSMutableArray new];
        NSMutableArray* musicListArr = [NSMutableArray new];
        if ([[NSNull null] isEqual:collectList] ||!collectList.count || [[NSNull null] isEqual:songList] ||!songList.count) {
            NSLog(@"loadCollectionData zero object");
            return;
        }
        for (NSDictionary* cateDic in collectList) {
            BMCollectionDataModel* musicCollection = [BMCollectionDataModel parseData:cateDic];
            musicCollection.CateId = musicCateId;
            [musicCollectArr addObject:musicCollection];
        }
        for (NSDictionary* musicDic in songList) {
            BMListDataModel* musicList = [BMListDataModel parseData:musicDic];
            musicList.CollectionId = musicCateId;
            [musicListArr addObject:musicList];
        }
        
        if ([[BMDataBaseManager sharedInstance] addMusicCollectionArr:musicCollectArr]) {
            NSDictionary* dic = nil;
            if (musicListArr.count) {
                dic = @{@"musicCateId":musicCateId, @"SongList":musicListArr};
            } else {
                dic = @{@"musicCateId":musicCateId};
            }
            [BMDataCacheManager setMusicCollection:musicCollectArr];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_COLLECTION_DATA_FINISHED object:dic];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

-(void)loadListDataWithCollectionId:(NSNumber *)collectionId {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString* url = MUSIC_LIST(collectionId);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
                                                                            options:0
                                                                              error:nil]:nil;
        NSArray* dataList = dic[@"dataList"];
        NSMutableArray* musicListArr = [NSMutableArray new];
        if ([[NSNull null] isEqual:dataList] ||!dataList.count) {
            NSLog(@"loadListData zero object");
            return;
        }
        for (NSDictionary* musicDic in dataList) {
            BMListDataModel* music = [BMListDataModel parseData:musicDic];
            music.CollectionId = collectionId;
            [musicListArr addObject:music];
        }
        
        if ([[BMDataBaseManager sharedInstance] addMusicListArr:musicListArr]) {
            NSDictionary* dic = @{@"collectionId":collectionId};
            [BMDataCacheManager setMusicList:musicListArr];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_LIST_DATA_FINISHED object:dic];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end
