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

-(NSArray *)getAllMusicCate;
-(BOOL)addMusicCateArr:(NSArray *) arr;
-(BOOL)addMusicCate:(BMDataModel *) cate;
-(void)updateMusicCate:(BMDataModel *) cate;

-(NSArray *)getAllMusicCollection;
-(BOOL)addMusicCollectionArr:(NSArray *) arr;
-(BOOL)addMusicCollection:(BMCollectionDataModel *) collection;
-(void)updateMusicCollection:(BMCollectionDataModel *) collection;
-(void)favMusicCollection:(BMCollectionDataModel *) collection;

-(NSArray *)getAllMusicList;
-(BOOL)addMusicListArr:(NSArray *)arr;
-(BOOL)addMusicList:(BMListDataModel *)list;
-(void)updateMusicList:(BMListDataModel *)list;
-(void)downLoadMusicList:(BMListDataModel *)list;
-(void)listenMusicList:(BMListDataModel *)list;

@end
