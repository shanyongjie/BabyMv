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
-(void)updateMusicCate:(BMDataModel *) cate;

-(NSArray *)getFavoriteMusicCollections;
-(BOOL)IsMusicCollectionFaved:(NSNumber *) CollectionId;
-(NSArray *)getAllCollectionIds;
-(NSArray *)getAllMusicCollection;
-(BOOL)addMusicCollectionArr:(NSArray *) arr;
-(void)favMusicCollection:(BMCollectionDataModel *) collection;

-(NSArray *)getDownloadedMusicList;
-(NSArray *)getAllMusicList;
-(BOOL)addMusicListArr:(NSArray *)arr;
-(void)updateMusicList:(BMListDataModel *)list;
-(void)downLoadMusicList:(BMListDataModel *)list;
-(void)listenMusicList:(BMListDataModel *)list;

#pragma mark - cartoon
-(NSArray *)getAllCartoonCateIds;
-(NSArray *)getAllCartoonCate;
-(BOOL)addCartoonCateArr:(NSArray *) arr;
-(void)updateCartoonCate:(BMDataModel *) cate;

-(NSArray *)getFavoriteCartoonCollections;
-(BOOL)IsCartoonCollectionFaved:(NSNumber *) CollectionId;
-(NSArray *)getAllCartoonCollectionIds;
-(NSArray *)getAllCartoonCollection;
-(BOOL)addCartoonCollectionArr:(NSArray *) arr;
-(void)favCartoonCollection:(BMCartoonCollectionDataModel *) collection;

-(NSArray *)getDownloadedCartoonList;
-(NSArray *)getAllCartoonList;
-(BOOL)addCartoonListArr:(NSArray *)arr;
-(void)updateCartoonList:(BMCartoonListDataModel *)list;
-(void)downLoadCartoonList:(BMCartoonListDataModel *)list;
-(void)openCartoonList:(BMCartoonListDataModel *)list;

@end

