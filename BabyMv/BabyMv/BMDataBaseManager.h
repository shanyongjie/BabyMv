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

@interface BMDataBaseManager : NSObject
+(instancetype)sharedInstance;

-(NSArray *)getAllCateIds;
-(NSArray *)getAllMusicCate;
-(BOOL)addMusicCateArr:(NSArray *) arr;
-(void)updateMusicCate:(BMDataModel *) cate;

-(NSArray *)getAllCollectionIds;
-(NSArray *)getAllMusicCollection;
-(BOOL)addMusicCollectionArr:(NSArray *) arr;
-(void)favMusicCollection:(BMCollectionDataModel *) collection;

-(NSArray *)getAllMusicList;
-(BOOL)addMusicListArr:(NSArray *)arr;
-(void)updateMusicList:(BMListDataModel *)list;
-(void)downLoadMusicList:(BMListDataModel *)list;
-(void)listenMusicList:(BMListDataModel *)list;

@end
