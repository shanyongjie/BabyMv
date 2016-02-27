//
//  BMDataBaseManager.h
//  BabyMv
//
//  Created by ma on 2/8/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMDataModel;
@class BMCollectionDataModel;
@class BMListDataModel;
@class BMCartoonCollectionDataModel;
@class BMCartoonListDataModel;

@interface BMDataBaseManager : NSObject
+(instancetype)sharedInstance;

#pragma mark - music
-(NSArray *)getAllCateIds;
-(NSArray *)getAllMusicCate;
-(BOOL)addMusicCateArr:(NSArray *) arr;
-(BOOL)updateMusicCateId:(NSNumber *)cateId withBindingCollectionId:(NSNumber *)collectionId;

-(NSArray *)getFavoriteMusicCollections;
-(BMCollectionDataModel *)musicCollectionById:(NSNumber *) CollectionId;
-(BOOL)IsMusicCollectionFaved:(NSNumber *) CollectionId;
-(NSArray *)getAllCollectionIds;
-(NSArray *)getAllMusicCollection;
-(NSArray *)getMusicCollectionByCateId:(NSNumber *)cateId;
-(BOOL)addMusicCollectionArr:(NSArray *) arr;
-(void)favMusicCollection:(BMCollectionDataModel *) collection;

-(NSArray *)getDownloadedMusicList;
-(NSArray *)getListenMusicList;
-(NSArray *)getAllMusicList;
-(NSArray *)getMusicListByCollectionId:(NSNumber *) collectionId;
-(BOOL)addMusicListArr:(NSArray *)arr;
-(void)updateMusicList:(BMListDataModel *)list;
-(BOOL)downLoadMusicList:(BMListDataModel *)list;
-(void)listenMusicListArr:(NSArray *)arr;
-(void)listenMusicList:(BMListDataModel *)list;

#pragma mark - cartoon
-(NSArray *)getAllCartoonCateIds;
-(NSArray *)getAllCartoonCate;
-(BOOL)addCartoonCateArr:(NSArray *) arr;
-(BOOL)updateCartoonCateId:(NSNumber *)cateId withBindingCollectionId:(NSNumber *)collectionId;

-(NSArray *)getFavoriteCartoonCollections;
-(BOOL)IsCartoonCollectionFaved:(NSNumber *) CollectionId;
-(NSArray *)getAllCartoonCollectionIds;
-(NSArray *)getAllCartoonCollection;
-(NSArray *)getCartoonCollectionByCateId:(NSNumber *)cateId;
-(BOOL)addCartoonCollectionArr:(NSArray *) arr;
-(void)favCartoonCollection:(BMCartoonCollectionDataModel *) collection;

-(NSArray *)getDownloadedCartoonList;
-(NSArray *)getAllCartoonList;
-(NSArray *)getCartoonListByCollectionId:(NSNumber *) collectionId;
-(BOOL)addCartoonListArr:(NSArray *)arr;
-(void)updateCartoonList:(BMCartoonListDataModel *)list;
-(BOOL)downLoadCartoonList:(BMCartoonListDataModel *)list;
-(void)openCartoonList:(BMCartoonListDataModel *)list;

@end

