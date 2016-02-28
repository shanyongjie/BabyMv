//
//  BMRequestManager.m
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMRequestManager.h"
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

+(void)loadCategoryData:(MyRequestType)requestType {
    [[BMRequestManager sharedInstance] loadCategoryData:requestType];
}

#pragma mark 加载分类数据
-(void)loadCategoryData:(MyRequestType)requestType {
    NSString* url = nil;
    switch (requestType) {
        case MyRequestTypeMusic:
            url = MUSIC_CATE;
            break;
        case MyRequestTypeCartoon:
            url = CARTOON_CATE;
            break;
        default:
            return;
            break;
    }
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
                                                                            options:0
                                                                              error:nil]:nil;
        NSArray* dataList = dic[@"dataList"];
        if ([[NSNull null] isEqual:dataList] ||!dataList.count) {
            NSLog(@"loadCategoryData zero object");
            return;
        }
        NSMutableArray* CateArr = [NSMutableArray new];
        for (NSDictionary* cateDic in dataList) {
            BMDataModel* musicCate = [BMDataModel parseData:cateDic];
            [CateArr addObject:musicCate];
        }
        if (requestType == MyRequestTypeMusic && [[BMDataBaseManager sharedInstance] addMusicCateArr:CateArr]) {
            [BMDataCacheManager setMusicCate:CateArr];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_MUSIC_CATEGORY_DATA_FINISHED object:nil];
        }
        if (requestType == MyRequestTypeCartoon && [[BMDataBaseManager sharedInstance] addCartoonCateArr:CateArr]) {
            [BMDataCacheManager setCartoonCate:CateArr];
            [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_CARTOON_CATEGORY_DATA_FINISHED object:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

#pragma mark 根据分类加载合集
-(void)loadCollectionDataWithCategoryId:(NSNumber *)musicCateId requestType:(MyRequestType)requestType {
    NSString* url = nil;
    switch (requestType) {
        case MyRequestTypeMusic:
            url = MUSIC_COLLECT(musicCateId);
            break;
        case MyRequestTypeCartoon:
            url = CARTOON_COLLECT(musicCateId);
            break;
        default:
            return;
            break;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
                                                                            options:0
                                                                              error:nil]:nil;
        //都是shan，你这货，返回的关键字不一样，让我只能用两个if
        if (requestType == MyRequestTypeMusic) {
            NSArray* collectList = dic[@"CollectList"];
            NSArray* songList = dic[@"SongList"];
            NSString* collectId = dic[@"CollectId"];
            NSNumber* collectionId = [NSNumber numberWithInt:0];
            if (collectId.length) {
                collectionId = [NSNumber numberWithInt:[collectId intValue]];
            }
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
                musicList.CollectionId = collectionId;
                [musicListArr addObject:musicList];
            }
            
            // 根据musicCateId来确定需要刷新的vc
            [BMDataCacheManager setMusicCollectionId:[NSNumber numberWithInt:[collectId intValue]] cateId:musicCateId];
            if ([[BMDataBaseManager sharedInstance] addMusicListArr:musicListArr]) {
//                [BMDataCacheManager setMusicList:musicListArr collectionId:collectionId];
                //确保cache里的数据和数据库里的一样，[[BMDataBaseManager sharedInstance] addMusicListArr:setMusicList:musicListArr］会更新原有的数据，保留已经下载等状态
                [BMDataCacheManager setMusicList:[[BMDataBaseManager sharedInstance] getMusicListByCollectionId:collectionId] collectionId:collectionId];
            }
            if ([[BMDataBaseManager sharedInstance] addMusicCollectionArr:musicCollectArr] && [[BMDataBaseManager sharedInstance] updateMusicCateId:musicCateId withBindingCollectionId:collectionId]) {
                NSDictionary* dic = nil;
                if (musicListArr.count) {
                    dic = @{@"musicCateId":musicCateId, @"SongList":musicListArr};
                } else {
                    dic = @{@"musicCateId":musicCateId};
                }
//                [BMDataCacheManager setMusicCollection:musicCollectArr cateId:musicCateId];
                //确保cache里的数据和数据库里的一样
                [BMDataCacheManager setMusicCollection:[[BMDataBaseManager sharedInstance] getMusicCollectionByCateId:musicCateId] cateId:musicCateId];
                //发通知的时机很重要，所有数据都加载后再发通知
                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_MUSIC_COLLECTION_DATA_FINISHED object:dic];
            }
            return;
        }
        
        if (requestType == MyRequestTypeCartoon) {
            NSArray* collectList = dic[@"dataList"];
            NSArray* cartoonList = dic[@"VideoList"];
            NSString* collectId = dic[@"MvId"];
            NSNumber* collectionId = [NSNumber numberWithInt:0];
            if (collectId.length) {
                collectionId = [NSNumber numberWithInt:[collectId intValue]];
            }
            NSMutableArray* cartoonCollectArr = [NSMutableArray new];
            NSMutableArray* cartoonListArr = [NSMutableArray new];
            if ([[NSNull null] isEqual:collectList] ||!collectList.count || [[NSNull null] isEqual:cartoonList] ||!cartoonList.count) {
                NSLog(@"loadCollectionData zero object");
                return;
            }
            for (NSDictionary* cateDic in collectList) {
                BMCartoonCollectionDataModel* cartoonCollection = [BMCartoonCollectionDataModel parseData:cateDic];
                cartoonCollection.CateId = musicCateId;
                [cartoonCollectArr addObject:cartoonCollection];
            }
            for (NSDictionary* cartoonDic in cartoonList) {
                BMCartoonListDataModel* cartoonList = [BMCartoonListDataModel parseData:cartoonDic];
                cartoonList.CollectionId = collectionId;
                [cartoonListArr addObject:cartoonList];
            }
            
            // 根据cartoonCateId来确定需要刷新的vc
            [BMDataCacheManager setCartoonCollectionId:[NSNumber numberWithInt:[collectId intValue]] cateId:musicCateId];
            if ([[BMDataBaseManager sharedInstance] addCartoonListArr:cartoonListArr]) {
//                [BMDataCacheManager setCartoonList:cartoonListArr collectionId:collectionId];
                //确保cache里的数据和数据库里的一样
                [BMDataCacheManager setCartoonList:[[BMDataBaseManager sharedInstance] getCartoonListByCollectionId:collectionId] collectionId:collectionId];
            }
            if ([[BMDataBaseManager sharedInstance] addCartoonCollectionArr:cartoonCollectArr] && [[BMDataBaseManager sharedInstance] updateCartoonCateId:musicCateId withBindingCollectionId:collectionId]) {
                NSDictionary* dic = nil;
                if (cartoonListArr.count) {
                    dic = @{@"cartoonCateId":musicCateId, @"cartoonList":cartoonListArr};
                } else {
                    dic = @{@"cartoonCateId":musicCateId};
                }
//                [BMDataCacheManager setCartoonCollection:cartoonCollectArr cateId:musicCateId];
                //确保cache里的数据和数据库里的一样
                [BMDataCacheManager setCartoonCollection:[[BMDataBaseManager sharedInstance] getCartoonCollectionByCateId:musicCateId] cateId:musicCateId];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_CARTOON_COLLECTION_DATA_FINISHED object:dic];
            }
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark 根据合集加载列表
-(void)loadListDataWithCollectionId:(NSNumber *)collectionId requestType:(MyRequestType)requestType {
    NSString* url = nil;
    switch (requestType) {
        case MyRequestTypeMusic:
            url = MUSIC_LIST(collectionId);
            break;
        case MyRequestTypeCartoon:
            url = CARTOON_LIST(collectionId);
            break;
        default:
            return;
            break;
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
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
        
        //返回的key不一样，新增model类型
        if (requestType == MyRequestTypeMusic) {
            for (NSDictionary* musicDic in dataList) {
                BMListDataModel* music = [BMListDataModel parseData:musicDic];
                music.CollectionId = collectionId;
                [musicListArr addObject:music];
            }
            if ([[BMDataBaseManager sharedInstance] addMusicListArr:musicListArr]) {
                // 根据collectionId来确定需要刷新的vc
                NSDictionary* dic = @{@"collectionId":collectionId};
//                [BMDataCacheManager setMusicList:musicListArr collectionId:collectionId];
                //确保cache里的数据和数据库里的一样
                [BMDataCacheManager setMusicList:[[BMDataBaseManager sharedInstance] getMusicListByCollectionId:collectionId] collectionId:collectionId];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_MUSIC_LIST_DATA_FINISHED object:dic];
            }
            return;
        }
 
        
        if (requestType == MyRequestTypeCartoon) {
            for (NSDictionary* cartoonDic in dataList) {
                BMCartoonListDataModel* cartoon = [BMCartoonListDataModel parseData:cartoonDic];
                cartoon.CollectionId = collectionId;
                [musicListArr addObject:cartoon];
            }
            if ([[BMDataBaseManager sharedInstance] addCartoonListArr:musicListArr]) {
                // 根据collectionId来确定需要刷新的vc
                NSDictionary* dic = @{@"collectionId":collectionId};
//                [BMDataCacheManager setCartoonList:musicListArr collectionId:collectionId];
                //确保cache里的数据和数据库里的一样
                [BMDataCacheManager setCartoonList:[[BMDataBaseManager sharedInstance] getCartoonListByCollectionId:collectionId] collectionId:collectionId];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_CARTOON_LIST_DATA_FINISHED object:dic];
            }
            return;
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

@end

//-(void)loadCollectionData {
//    NSArray* arr = [[BMDataBaseManager sharedInstance] getAllMusicCate];
//    for (BMDataModel* musicCate in arr) {
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.securityPolicy.allowInvalidCertificates = YES;
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        NSString* url = MUSIC_COLLECT(musicCate.Rid);
//        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
//                                                                                options:0
//                                                                                  error:nil]:nil;
//            NSArray* collectList = dic[@"CollectList"];
//            NSArray* songList = dic[@"SongList"];
//            NSMutableArray* musicCollectArr = [NSMutableArray new];
//            NSMutableArray* musicListArr = [NSMutableArray new];
//            if ([[NSNull null] isEqual:collectList] ||!collectList.count || [[NSNull null] isEqual:songList] ||!songList.count) {
//                NSLog(@"loadCollectionData zero object");
//                return;
//            }
//            for (NSDictionary* cateDic in collectList) {
//                BMCollectionDataModel* musicCollection = [BMCollectionDataModel parseData:cateDic];
//                musicCollection.CateId = musicCate.Rid;
//                [musicCollectArr addObject:musicCollection];
//            }
//            for (NSDictionary* musicDic in songList) {
//                BMListDataModel* musicList = [BMListDataModel parseData:musicDic];
//                musicList.CollectionId = musicCate.Rid;
//                [musicListArr addObject:musicList];
//            }
////            [BMDataCacheManager setCurrentMusicList:musicListArr];
//
//            if ([[BMDataBaseManager sharedInstance] addMusicCollectionArr:musicCollectArr]) {
//                [BMDataCacheManager setMusicCollection:musicCollectArr cateId:musicCate.Rid];
//                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_MUSIC_COLLECTION_DATA_FINISHED object:nil];
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"%@", error);
//        }];
//    }
//}

//-(void)loadListData {
//    NSArray* arr = [[BMDataBaseManager sharedInstance] getAllMusicCollection];
//    if (!arr.count) {
//        NSLog(@"zero object");
//        return;
//    }
//    for (BMCollectionDataModel* listData in arr) {
//        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//        manager.securityPolicy.allowInvalidCertificates = YES;
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//        NSString* url = MUSIC_LIST(listData.Rid);
//        [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSDictionary* dic = responseObject? [NSJSONSerialization JSONObjectWithData:responseObject
//                                                                                options:0
//                                                                                  error:nil]:nil;
//            NSArray* dataList = dic[@"dataList"];
//            NSMutableArray* musicListArr = [NSMutableArray new];
//            if ([[NSNull null] isEqual:dataList] ||!dataList.count) {
//                NSLog(@"loadListData zero object");
//                return;
//            }
//            for (NSDictionary* musicDic in dataList) {
//                BMListDataModel* music = [BMListDataModel parseData:musicDic];
//                music.CollectionId = listData.Rid;
//                [musicListArr addObject:music];
//            }
//
//            if ([[BMDataBaseManager sharedInstance] addMusicListArr:musicListArr]) {
//                [BMDataCacheManager setMusicList:musicListArr collectionId:listData.Rid];
//                [[NSNotificationCenter defaultCenter] postNotificationName:LOAD_MUSIC_LIST_DATA_FINISHED object:nil];
//            }
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"%@", error);
//        }];
//    }
//}

