//
//  BMVlcVideoPlayViewController.h
//  BabyMv
//
//  Created by 单永杰 on 15/6/19.
//  Copyright (c) 2015年 happybaby. All rights reserved.
//
#import <UIKit/UIKit.h>

@class BMCartoonListDataModel;

@interface BMVlcVideoPlayViewController : BMBaseVC{
    
    UIView* _waitingView;
    CGRect  _tipsRect;
    
    bool bScreenLock;
}
@property (nonatomic, strong) UIView* playerView;
@property (nonatomic, strong) UIView* topBackgroundView;
@property (nonatomic, strong) UIView* bottomBackgroundView;
@property (nonatomic, strong) UIView* gestureResponseView;
@property (nonatomic, strong) BMCartoonListDataModel* videoInfo;
@property (nonatomic, strong) UIButton* btnScreenLock;
@property (nonatomic, assign) BOOL      isPauseClicked;
@property (nonatomic, assign) NSInteger currentPlayingIndex;
@property (nonatomic, strong) NSArray* currentPlayingList;

-(void)setVideoInfo:(BMCartoonListDataModel *)videoInfo index:(NSInteger)index videoList:(NSArray *)currentPlayingList;
@end
