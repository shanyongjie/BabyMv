//
//  BMDataCacheManager.m
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMDataCacheManager.h"
#import "BMDataModel.h"
#import "BMDataBaseManager.h"

@interface BMDataCacheManager ()
@property(nonatomic, strong)NSMutableArray* currentPlayingList;         //music or cartoon
@property(nonatomic, strong)NSMutableArray* musicCate;
@property(nonatomic, strong)NSMutableDictionary* musicCate2CollectionDic;
@property(nonatomic, strong)NSMutableDictionary* musicCategoryId2CollectionId;
@property(nonatomic, strong)NSMutableDictionary* musicCollection2ListDic;

//@property(nonatomic, strong)NSMutableArray* musicCollection;
//@property(nonatomic, strong)NSMutableArray* musicList;
@property(nonatomic, strong)NSMutableArray* currentMusicList;
@property(nonatomic, strong)NSMutableArray* cartoonCate;
@property(nonatomic, strong)NSMutableDictionary* cartoonCate2CollectionDic;
@property(nonatomic, strong)NSMutableDictionary* cartoonCategoryId2CollectionId;
@property(nonatomic, strong)NSMutableDictionary* cartoonCollection2ListDic;
//@property(nonatomic, strong)NSMutableArray* cartoonCollection;
//@property(nonatomic, strong)NSMutableArray* cartoonList;
@end

@implementation BMDataCacheManager

+(instancetype)sharedInstance {
    static BMDataCacheManager* dataCacheManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataCacheManager = [BMDataCacheManager new];
        dataCacheManager.currentPlayingList = [NSMutableArray new];
        dataCacheManager.musicCate          = [NSMutableArray new];
        dataCacheManager.musicCate2CollectionDic = [NSMutableDictionary new];
        dataCacheManager.musicCategoryId2CollectionId = [NSMutableDictionary new];
        dataCacheManager.musicCollection2ListDic = [NSMutableDictionary new];
        
        dataCacheManager.cartoonCate        = [NSMutableArray new];
        dataCacheManager.cartoonCate2CollectionDic  = [NSMutableDictionary new];
        dataCacheManager.cartoonCategoryId2CollectionId  = [NSMutableDictionary new];
        dataCacheManager.cartoonCollection2ListDic  = [NSMutableDictionary new];
        
        dataCacheManager.currentMusicList        = [NSMutableArray new];
    });
    return dataCacheManager;
}

+(void)resetCache {
    [[BMDataCacheManager sharedInstance] resetCache];
}
-(void)resetCache {
    [self.currentPlayingList removeAllObjects];
    [self.musicCate removeAllObjects];
    [self.musicCate2CollectionDic removeAllObjects];
    [self.musicCategoryId2CollectionId removeAllObjects];
    [self.musicCollection2ListDic removeAllObjects];
    [self.cartoonCate removeAllObjects];
    [self.cartoonCate2CollectionDic removeAllObjects];
    [self.cartoonCategoryId2CollectionId removeAllObjects];
    [self.cartoonCollection2ListDic removeAllObjects];
}

+(NSArray *)currentPlayingList {
    return [[BMDataCacheManager sharedInstance] currentPlayingList];
}
-(NSArray *)currentPlayingList {
    return _currentPlayingList;
}
+(void)setCurrentPlayingList:(NSArray *)arr {
    [[BMDataCacheManager sharedInstance] setCurrentPlayingListArr:arr];
}
-(void)setCurrentPlayingListArr:(NSArray *)arr {
    [self.currentPlayingList removeAllObjects];
    [self.currentPlayingList addObjectsFromArray:arr];
}

+(NSArray *)musicCate {
    return [[BMDataCacheManager sharedInstance] musicCate];
}
-(NSArray *)musicCate {
    return _musicCate;
}
+(void)setMusicCate:(NSArray *)arr {
    [[BMDataCacheManager sharedInstance] setMusicCateArr:arr];
}
-(void)setMusicCateArr:(NSArray *)arr {
    [self.musicCate removeAllObjects];
    [self.musicCate addObjectsFromArray:arr];
}

+(NSArray *)musicCollectionWithCateId:(NSNumber *)cateId {
    return [[BMDataCacheManager sharedInstance] musicCollectionWithCateId:cateId];
}
-(NSArray *)musicCollectionWithCateId:(NSNumber *)cateId {
    return _musicCate2CollectionDic[cateId];
}
+(void)setMusicCollection:(NSArray *)arr cateId:(NSNumber *)cateId{
    [[BMDataCacheManager sharedInstance] setMusicCollectionArr:arr cateId:cateId];
}
-(void)setMusicCollectionArr:(NSArray *)arr cateId:(NSNumber *)cateId {
    NSMutableArray *oldData = [NSMutableArray arrayWithArray:self.musicCate2CollectionDic[cateId]];
    [oldData addObjectsFromArray:arr];
    self.musicCate2CollectionDic[cateId] = oldData;
}

+(NSNumber *)musicCollectionIdBinding2CategoryId:(NSNumber *)categoryId {
    return [BMDataCacheManager sharedInstance].musicCategoryId2CollectionId[categoryId];
}
+(void)setMusicCollectionId:(NSNumber *)collectionId cateId:(NSNumber *)cateId {
    [BMDataCacheManager sharedInstance].musicCategoryId2CollectionId[cateId] = collectionId;
}

+(NSArray *)musicListWithCollectionId:(NSNumber *)collectionId {
    return [[BMDataCacheManager sharedInstance] musicListWithCollectionId:collectionId];
}
-(NSArray *)musicListWithCollectionId:(NSNumber *)collectionId {
    return _musicCollection2ListDic[collectionId];
}
+(void)setMusicList:(NSArray *)arr collectionId:(NSNumber *)collectionId {
    [[BMDataCacheManager sharedInstance] setMusicListArr:arr collectionId:collectionId];
}
-(void)setMusicListArr:(NSArray *)arr collectionId:(NSNumber *)collectionId {
    NSMutableArray *oldData = [NSMutableArray arrayWithArray:self.musicCollection2ListDic[collectionId]];
    [oldData addObjectsFromArray:arr];
    self.musicCollection2ListDic[collectionId] = oldData;
}

+(NSArray *)cartoonCate {
    return [[BMDataCacheManager sharedInstance] cartoonCate];
}
-(NSArray *)cartoonCate {
    return _cartoonCate;
}
+(void)setCartoonCate:(NSArray *)arr {
    [[BMDataCacheManager sharedInstance] setCartoonCateArr:arr];
}
-(void)setCartoonCateArr:(NSArray *)arr {
    [self.cartoonCate removeAllObjects];
    [self.cartoonCate addObjectsFromArray:arr];
}

+(NSArray *)cartoonCollectionWithCateId:(NSNumber *)cateId {
    return [[BMDataCacheManager sharedInstance] cartoonCollectionWithCateId:cateId];
}
-(NSArray *)cartoonCollectionWithCateId:(NSNumber *)cateId {
    return _cartoonCate2CollectionDic[cateId];
}
+(void)setCartoonCollection:(NSArray *)arr cateId:(NSNumber *)cateId {
    [[BMDataCacheManager sharedInstance] setCartoonCollectionArr:arr cateId:cateId];
}
-(void)setCartoonCollectionArr:(NSArray *)arr cateId:(NSNumber *)cateId {
    NSMutableArray *oldData = [NSMutableArray arrayWithArray:self.cartoonCate2CollectionDic[cateId]];
    [oldData addObjectsFromArray:arr];
    self.cartoonCate2CollectionDic[cateId] = oldData;
}

+(NSNumber *)cartoonCollectionIdBinding2CategoryId:(NSNumber *)categoryId {
    return [BMDataCacheManager sharedInstance].cartoonCategoryId2CollectionId[categoryId];
}
+(void)setCartoonCollectionId:(NSNumber *)collectionId cateId:(NSNumber *)cateId {
    [BMDataCacheManager sharedInstance].cartoonCategoryId2CollectionId[cateId] = collectionId;
}

+(NSArray *)cartoonListWithCollectionId:(NSNumber *)collectionId {
    return [[BMDataCacheManager sharedInstance] cartoonListWithCollectionId:collectionId];
}
-(NSArray *)cartoonListWithCollectionId:(NSNumber *)collectionId {
    return _cartoonCollection2ListDic[collectionId];
}
+(void)setCartoonList:(NSArray *)arr collectionId:(NSNumber *)collectionId {
    [[BMDataCacheManager sharedInstance] setCartoonListArr:arr collectionId:collectionId];
}
-(void)setCartoonListArr:(NSArray *)arr collectionId:(NSNumber *)collectionId {
    NSMutableArray *oldData = [NSMutableArray arrayWithArray:self.cartoonCollection2ListDic[collectionId]];
    [oldData addObjectsFromArray:arr];
    self.cartoonCollection2ListDic[collectionId] = oldData;
}


+(void)updateMusicListDataDownLoadStatus:(BMListDataModel *)listData {
    [[BMDataCacheManager sharedInstance] updateMusicListDataDownLoadStatus:listData];
}
-(void)updateMusicListDataDownLoadStatus:(BMListDataModel *)listData {
    if ([[BMDataBaseManager sharedInstance] downLoadMusicList:listData]) {
        self.musicCollection2ListDic[listData.CollectionId] = [[BMDataBaseManager sharedInstance] getMusicListByCollectionId:listData.CollectionId];
    }
}

+(void)updateCartoonListDataDownLoadStatus:(BMCartoonListDataModel *)listData {
    [[BMDataCacheManager sharedInstance] updateCartoonListDataDownLoadStatus:listData];
}
-(void)updateCartoonListDataDownLoadStatus:(BMCartoonListDataModel *)listData {
    if ([[BMDataBaseManager sharedInstance] downLoadCartoonList:listData]) {
        self.cartoonCollection2ListDic[listData.CollectionId] = [[BMDataBaseManager sharedInstance] getCartoonListByCollectionId:listData.CollectionId];
    }
}


//+(NSArray *)currentMusicList {
//    return [[BMDataCacheManager sharedInstance] currentMusicList];
//}
//
//+(void)setCurrentMusicList:(NSArray *)arr {
//    [[BMDataCacheManager sharedInstance] setCurrentMusicListArr:arr];
//}
//-(void)setCurrentMusicListArr:(NSArray *)arr {
//    [self.currentMusicList removeAllObjects];
//    [self.currentMusicList addObjectsFromArray:arr];
//}
//
//-(NSArray *)currentMusicList {
//    return _currentMusicList;
//}

@end
