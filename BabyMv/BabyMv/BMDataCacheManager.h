//
//  BMDataCacheManager.h
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BMListDataModel;
@class BMCartoonListDataModel;

@interface BMDataCacheManager : NSObject
+(void)resetCache;
+(NSArray *)musicCate;
+(NSArray *)musicCollectionWithCateId:(NSNumber *)cateId;
+(NSArray *)musicListWithCollectionId:(NSNumber *)collectionId;

+(NSArray *)cartoonCate;
+(NSArray *)cartoonCollectionWithCateId:(NSNumber *)cateId;
+(NSArray *)cartoonListWithCollectionId:(NSNumber *)collectionId;

+(void)setMusicCate:(NSArray *)arr;
+(void)setMusicCollection:(NSArray *)arr cateId:(NSNumber *)cateId;
+(void)setMusicList:(NSArray *)arr collectionId:(NSNumber *)collectionId;
+(void)setCartoonCate:(NSArray *)arr;
+(void)setCartoonCollection:(NSArray *)arr cateId:(NSNumber *)cateId;
+(void)setCartoonList:(NSArray *)arr collectionId:(NSNumber *)collectionId;

+(void)updateMusicListDataDownLoadStatus:(BMListDataModel *)listData;
+(void)updateCartoonListDataDownLoadStatus:(BMCartoonListDataModel *)listData;
@end


