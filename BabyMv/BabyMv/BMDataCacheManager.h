//
//  BMDataCacheManager.h
//  BabyMv
//
//  Created by ma on 2/12/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMDataCacheManager : NSObject
+(void)resetCache;
+(NSArray *)musicCate;
+(NSArray *)musicCollectionWithCateId:(NSNumber *)cateId;
+(NSArray *)musicListWithCollectionId:(NSNumber *)collectionId;

+(NSArray *)cartoonCate;
+(NSArray *)cartoonCollectionWithCateId:(NSNumber *)cateId;
+(NSArray *)cartoonListWithCollectionId:(NSNumber *)collectionId;

+(void)setMusicCate:(NSArray *)arr;
+(void)setMusicCollection:(NSArray *)arr;
+(void)setMusicList:(NSArray *)arr;
+(void)setCartoonCate:(NSArray *)arr;
+(void)setCartoonCollection:(NSArray *)arr;
+(void)setCartoonList:(NSArray *)arr;

@end
