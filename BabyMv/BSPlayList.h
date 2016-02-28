//
//  BSPlayList.h
//  babysong
//
//  Created by 单永杰 on 14-7-10.
//  Copyright (c) 2014年 ShanYongjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMDataModel.h"

@interface BSPlayList : NSObject

@property (nonatomic, assign)int listID;
@property (nonatomic, strong) NSArray* arryPlayList;

+(BSPlayList*)sharedInstance;

- (void)setPlayList : (NSArray*)arry_play_list;
- (BMListDataModel*) currentItem;
- (BMListDataModel*) nextItem;
- (BMListDataModel*) prevItem;
- (void)setCurIndex : (int)n_index;
- (int)getCurIndex;

- (void)savePlaylist;

@end
