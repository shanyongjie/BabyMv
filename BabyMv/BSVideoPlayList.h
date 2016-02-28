//
//  BSVideoPlayList.h
//  babysong
//
//  Created by 单永杰 on 14-7-14.
//  Copyright (c) 2014年 ShanYongjie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMDataModel.h"

@interface BSVideoPlayList : NSObject

@property (nonatomic, assign)int listID;
@property (nonatomic, copy) NSArray* arryPlayList;

+(BSVideoPlayList*)sharedInstance;

- (void)setPlayList : (NSArray*)arry_play_list;
- (BMCartoonListDataModel*) currentItem;
- (BMCartoonListDataModel*) nextItem;
- (BMCartoonListDataModel*) prevItem;
- (void)setCurIndex : (int)n_index;
- (int)getCurIndex;

- (int)getVideoIndex:(BMCartoonListDataModel*)song_item;

- (void)savePlaylist;

@end
