//
//  BMTopTabBar.m
//  BabyMv
//
//  Created by ma on 2/6/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMTopTabBar.h"
#import "UIImage+Helper.h"
#import "AudioPlayerAdapter.h"
#import "BSPlayInfo.h"
#import "BSPlayList.h"
#import "PopupMenuVIew.h"
#import "common.h"
#import "AppDelegate.h"

@interface BMTopTabButton ()
@end

@implementation BMTopTabButton
+(instancetype)NewWithName:(NSString*)name{
    BMTopTabButton* btn = [BMTopTabButton new];
    [btn setTitle:name forState:UIControlStateNormal];
    return btn;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setTitleColor:RGB(0x7b4703, 1.0) forState:UIControlStateNormal];
        [self setTitleColor:RGB(0x7b4703, 1.0) forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageNamed:@"tab1_topButton_bg"] forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage createImageWithColor:NavBarYellow] forState:UIControlStateNormal];
        
        self.titleLabel.font =[UIFont boldSystemFontOfSize:15];
    }
    return self;
}
-(void)setTitle:(NSString *)title {
    [self setTitle:title forState:UIControlStateNormal];
}
-(void)setSelected:(BOOL)selected{
    super.selected = selected;
}
@end


@interface BMTopTabBar ()
@property(nonatomic, strong)NSArray* items;
@end

@implementation BMTopTabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(void)setItems:(NSArray *)items height:(int)height {
    self.items = items;
    NSMutableString* hCons = [NSMutableString new];
    NSMutableDictionary* map = [NSMutableDictionary new];
    [hCons appendString:@"H:|-(1.5)-"];
    NSString* firstItem;
    for (int index = 0; index < items.count; ++index) {
        UIControl* control = items[index];
        control.layer.cornerRadius = 15;
        control.clipsToBounds = YES;
        NSString* key = [NSString stringWithFormat:@"item_%d", index];
        map[key] = control;
        control.translatesAutoresizingMaskIntoConstraints = NO;
        control.tag = 1000 + index;
        [self addSubview:control];
        if (0 == index) {
            [hCons appendString:[NSString stringWithFormat:@"[%@]-", key]];
            firstItem = key;
        } else {
            [hCons appendString:[NSString stringWithFormat:@"[%@(%@)]-(1.5)-", key, firstItem]];
        }
        
                NSString* vCons = [NSString stringWithFormat:@"V:|[%@(30)]|", key];
                ViewAddCons(self, vCons, nil, map)
//        ViewAddCenterY(self, control)
        [control addTarget:self action:@selector(genTabBtnCb:) forControlEvents:UIControlEventTouchUpInside];
    }
    [hCons appendString:@"|"];
    ViewAddConsAlign(self, hCons, NSLayoutFormatAlignAllCenterY, nil, map)
}

-(void)genTabBtnCb:(id)sender{
    UIControl* btn = (UIControl*)sender;
    self.tabTag = (int)btn.tag;
}
-(void)setTabTag:(int)tabTag{
    _tabTag = tabTag;
    for(UIControl* item in self.items){
        item.selected = NO;
    }
    for(UIControl* item in self.items){
        if(item.tag == tabTag){
            item.selected=YES;
            if(self.blk){
                self.blk(tabTag);
            }
            break;
        }
    }
}

@end


//////////

@interface BMBottomPlayingTabBar ()<PopupMenuDelegate>
@property(nonatomic, strong)NSArray* items;
@property(nonatomic, strong)UIButton* preBtn;
@property(nonatomic, strong)UIButton* timeBtn;
@property(nonatomic, strong)UIButton* playBtn;
@property(nonatomic, strong)UIButton* modeBtn;
@property(nonatomic, strong)UIButton* nextBtn;
@property(nonatomic, strong)UIProgressView* processView;
@property(nonatomic, strong)UILabel* currentTimeLab;
@property(nonatomic, strong)UILabel* totalTimeLab;

@property(nonatomic, strong)NSTimer* updateTimmer;
@end

@implementation BMBottomPlayingTabBar

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        InitViewX(UIProgressView, processView, self, 0);
        [processView setBackgroundColor:[UIColor clearColor]];
        processView.trackTintColor = RGB(0x999999, 1.0);
        processView.progressTintColor = RGB(0xea801a, 1.0);
        
        InitViewX(UIButton, preBtn, self, 0);
        [preBtn setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
        [preBtn setImage:[UIImage imageNamed:@"btn-back-down"] forState:UIControlStateHighlighted];
        [preBtn addTarget:self action:@selector(genTabBtnCb:) forControlEvents:UIControlEventTouchUpInside];
        preBtn.tag = 1001;
        
        InitViewX(UIButton, timeBtn, self, 0);
        [timeBtn setImage:[UIImage imageNamed:@"timing-no"] forState:UIControlStateNormal];
        [timeBtn setImage:[UIImage imageNamed:@"timing-no-down"] forState:UIControlStateHighlighted];
        [timeBtn addTarget:self action:@selector(onControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        timeBtn.tag = 1004;
        
        InitViewX(UIButton, playBtn, self, 0);
        [playBtn setImage:[UIImage imageNamed:@"btn-play"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"btn-play-down"] forState:UIControlStateHighlighted];
        [playBtn addTarget:self action:@selector(onControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        playBtn.tag = 1002;
        
        InitViewX(UIButton, modeBtn, self, 0);
        [modeBtn setImage:[UIImage imageNamed:@"btn-order"] forState:UIControlStateNormal];
        [modeBtn setImage:[UIImage imageNamed:@"btn-order-down"] forState:UIControlStateHighlighted];
        [modeBtn addTarget:self action:@selector(onControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        modeBtn.tag = 1000;
        
        InitViewX(UIButton, nextBtn, self, 0);
        [nextBtn setImage:[UIImage imageNamed:@"btn-next"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"btn-next-down"] forState:UIControlStateHighlighted];
        [nextBtn addTarget:self action:@selector(onControlBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        nextBtn.tag = 1003;
        
        InitViewX(UILabel, currentTimeLab, self, 0);
        currentTimeLab.font = [UIFont systemFontOfSize:13];
        currentTimeLab.textColor = [UIColor grayColor];
        currentTimeLab.text = @"00:00";
        InitViewX(UILabel, totalTimeLab, self, 0);
        totalTimeLab.font = [UIFont systemFontOfSize:13];
        totalTimeLab.textColor = [UIColor grayColor];
        totalTimeLab.text = @"00:00";
        //    NSArray *imgArr = @[@"btn-timing", @[@"btn-repeat-once", @"btn-order", @"btn-all-repeat"], @"btn-next"];
        NSDictionary* map = NSDictionaryOfVariableBindings(processView, currentTimeLab, totalTimeLab, preBtn, timeBtn, playBtn, modeBtn, nextBtn);
        NSDictionary* metrics = @{@"timeLabelWidth":@(42), @"playBtnWidth":@(42), @"btnWidth":@(33), @"processViewHeight":@(2)};
        ViewAddCons(self, @"H:|-[preBtn(btnWidth)]-[currentTimeLab(timeLabelWidth)]-(>=0)-[timeBtn(btnWidth)]-(25)-[modeBtn(btnWidth)]-(25)-[nextBtn(btnWidth)]-(25)-[playBtn(playBtnWidth)]-|", metrics, map);
        ViewAddCons(self, @"H:|-[preBtn(btnWidth)]-[totalTimeLab(timeLabelWidth)]-(>=0)-[timeBtn(btnWidth)]-(25)-[modeBtn(btnWidth)]-(25)-[nextBtn(btnWidth)]-(25)-[playBtn(playBtnWidth)]-|", metrics, map);
        ViewAddCons(self, @"H:|[processView]|", metrics, map);
        ViewAddCons(self, @"V:|[processView(processViewHeight)]-(2)-[playBtn(playBtnWidth)]", metrics, map);
        ViewAddCons(self, @"V:|-[currentTimeLab]-(>=0)-[totalTimeLab]-|", metrics, map);
        ViewAddCenterY(self, preBtn)
        ViewAddCenterY(self, timeBtn)
        ViewAddCenterY(self, modeBtn)
        ViewAddCenterY(self, nextBtn)
        
        self.items = @[preBtn, timeBtn, modeBtn, nextBtn, playBtn];
    }
    return self;
}

- (void)beginUpdates{
    if (!_updateTimmer) {
        [_updateTimmer invalidate];
        _updateTimmer = nil;
    }
    
    _updateTimmer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updatePlayingInfo) userInfo:nil repeats:YES];
}

- (void)endUpdates{
    if (_updateTimmer) {
        [_updateTimmer invalidate];
        _updateTimmer = nil;
    }
}

-(void)genTabBtnCb:(id)sender{
    UIControl* btn = (UIControl*)sender;
    self.tabTag = (int)btn.tag;
}

- (void)onControlBtnClick:(id)sender{
    UIButton* btn = (UIButton*)sender;
    if (btn) {
        switch (btn.tag) {
            case 1000:
            {
                PopupMenuView* menu = [[PopupMenuView alloc] init];
                [menu addItemWithText:@"顺序播放" image:[UIImage imageNamed:@"btn-order"] andSelector:@selector(handleMenuSequence) userData:nil];
                [menu addItemWithText:@"单曲循环" image:[UIImage imageNamed:@"btn-repeat-once"] andSelector:@selector(handleMenuSingle) userData:nil];
                [menu addItemWithText:@"循环播放" image:[UIImage imageNamed:@"btn-all-repeat"] andSelector:@selector(handleMenuRing) userData:nil];
                
                menu.delegate = self;
                [menu showInView:self.superview withAnchorPoint:RightTopPoint(self.frame) dropFlags:0 animated:YES];
                break;
            }
            case 1002:
            {
                if (PlayStatePlaying == [AudioPlayerAdapter sharedPlayerAdapter].playState) {
                    [[AudioPlayerAdapter sharedPlayerAdapter] pause];
                    [_playBtn setImage:[UIImage imageNamed:@"btn-stop"] forState:UIControlStateNormal];
                    [_playBtn setImage:[UIImage imageNamed:@"btn-stop-down"] forState:UIControlStateHighlighted];
                }else if(PlayStatePaused == [AudioPlayerAdapter sharedPlayerAdapter].playState){
                    [[AudioPlayerAdapter sharedPlayerAdapter] resume];
                    [_playBtn setImage:[UIImage imageNamed:@"btn-play"] forState:UIControlStateNormal];
                    [_playBtn setImage:[UIImage imageNamed:@"btn-play-down"] forState:UIControlStateHighlighted];
                }else {
                    [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:[BSPlayList sharedInstance].currentItem inList:[BSPlayList sharedInstance].listID delegate:nil];
                    [_playBtn setImage:[UIImage imageNamed:@"btn-play"] forState:UIControlStateNormal];
                    [_playBtn setImage:[UIImage imageNamed:@"btn-play-down"] forState:UIControlStateHighlighted];
                }
                break;
            }
            case 1003:
            {
                if ([BSPlayList sharedInstance].arryPlayList && [BSPlayList sharedInstance].arryPlayList.count) {
                    if ([[BSPlayList sharedInstance] nextItem]) {
                        int n_cur_index = [[BSPlayList sharedInstance] getCurIndex] + 1;
                        [[BSPlayList sharedInstance] setCurIndex:n_cur_index];
                        [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:[BSPlayList sharedInstance].currentItem inList:[BSPlayList sharedInstance].listID delegate:nil];
                    }else {
                        [[BSPlayList sharedInstance] setCurIndex:0];
                        [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:[BSPlayList sharedInstance].currentItem inList:[BSPlayList sharedInstance].listID delegate:nil];
                    }
                }
                
                break;
            }
            case 1004:
            {
                PopupMenuView* menu = [[PopupMenuView alloc] init];
                [menu addItemWithText:@"不限时" image:[UIImage imageNamed:@"timing-no"] andSelector:@selector(handleMenuNoTiming) userData:nil];
                [menu addItemWithText:@"60分钟停止" image:[UIImage imageNamed:@"timing-60"] andSelector:@selector(handleTiming60) userData:nil];
                [menu addItemWithText:@"30分钟停止" image:[UIImage imageNamed:@"timing-30"] andSelector:@selector(handleTiming30) userData:nil];
                [menu addItemWithText:@"20分钟停止" image:[UIImage imageNamed:@"timing-20"] andSelector:@selector(handleTiming20) userData:nil];
                [menu addItemWithText:@"10分钟停止" image:[UIImage imageNamed:@"timing-10"] andSelector:@selector(handleTiming10) userData:nil];
                
                menu.delegate = self;
                [menu showInView:self.superview withAnchorPoint:RightTopPoint(self.frame) dropFlags:0 animated:YES];
                break;
            }
            default:
                break;
        }
    }
}

-(void)setTabTag:(int)tabTag{
    _tabTag = tabTag;
    for(UIControl* item in self.items){
        item.selected = NO;
    }
    for(UIControl* item in self.items){
        if(item.tag == tabTag){
            item.selected=YES;
            if(self.blk){
                self.blk(tabTag);
            }
            break;
        }
    }
}

- (void)updatePlayingInfo{
    if (0.0 != [AudioPlayerAdapter sharedPlayerAdapter].duration) {
        [_processView setProgress:[AudioPlayerAdapter sharedPlayerAdapter].currentTime / [AudioPlayerAdapter sharedPlayerAdapter].duration];
    }else {
        [_processView setProgress:0];
    }
    
    [_currentTimeLab setText:[self convertTime:[AudioPlayerAdapter sharedPlayerAdapter].currentTime]];
    [_totalTimeLab setText:[self convertTime:[AudioPlayerAdapter sharedPlayerAdapter].duration]];
    switch ([AudioPlayerAdapter sharedPlayerAdapter].playState) {
        case PlayStatePlaying:
        {
            [_playBtn setImage:[UIImage imageNamed:@"btn-stop"] forState:UIControlStateNormal];
            [_playBtn setImage:[UIImage imageNamed:@"btn-stop-down"] forState:UIControlStateHighlighted];
            break;
        }
        default:
        {
            [_playBtn setImage:[UIImage imageNamed:@"btn-play"] forState:UIControlStateNormal];
            [_playBtn setImage:[UIImage imageNamed:@"btn-play-down"] forState:UIControlStateHighlighted];
            break;
        }
    }
    
    switch ([[BSPlayInfo sharedInstance] getTimingType]) {
        case E_TIMING_NO:
        {
            [_timeBtn setImage:[UIImage imageNamed:@"timing-no"] forState:UIControlStateNormal];
            [_timeBtn setImage:[UIImage imageNamed:@"timing-no-down"] forState:UIControlStateHighlighted];
            break;
        }
        case E_TIMING_10:
        {
            [_timeBtn setImage:[UIImage imageNamed:@"timing-10"] forState:UIControlStateNormal];
            [_timeBtn setImage:[UIImage imageNamed:@"timing-10-down"] forState:UIControlStateHighlighted];
            break;
        }
        case E_TIMING_20:
        {
            [_timeBtn setImage:[UIImage imageNamed:@"timing-20"] forState:UIControlStateNormal];
            [_timeBtn setImage:[UIImage imageNamed:@"timing-20-down"] forState:UIControlStateHighlighted];
            break;
        }
        case E_TIMING_30:
        {
            [_timeBtn setImage:[UIImage imageNamed:@"timing-30"] forState:UIControlStateNormal];
            [_timeBtn setImage:[UIImage imageNamed:@"timing-30-down"] forState:UIControlStateHighlighted];
            break;
        }
        case E_TIMING_60:
        {
            [_timeBtn setImage:[UIImage imageNamed:@"timing-60"] forState:UIControlStateNormal];
            [_timeBtn setImage:[UIImage imageNamed:@"timing-60-down"] forState:UIControlStateHighlighted];
            break;
        }
        default:
            break;
    }
    
    switch ([[BSPlayInfo sharedInstance] getPlayMode]) {
        case E_MODE_SEQUENCE:
        {
            [_modeBtn setImage:[UIImage imageNamed:@"btn-order"] forState:UIControlStateNormal];
            [_modeBtn setImage:[UIImage imageNamed:@"btn-order-down"] forState:UIControlStateHighlighted];
            break;
        }
        case E_MODE_RING:
        {
            [_modeBtn setImage:[UIImage imageNamed:@"btn-all-repeat"] forState:UIControlStateNormal];
            [_modeBtn setImage:[UIImage imageNamed:@"btn-all-repeat-down"] forState:UIControlStateHighlighted];
            
            break;
        }
        case E_MODE_SINGLE:
        {
            [_modeBtn setImage:[UIImage imageNamed:@"btn-repeat-once"] forState:UIControlStateNormal];
            [_modeBtn setImage:[UIImage imageNamed:@"btn-repeat-once-down"] forState:UIControlStateHighlighted];
            break;
        }
        default:
        {
            [_modeBtn setImage:[UIImage imageNamed:@"btn-all-repeat"] forState:UIControlStateNormal];
            [_modeBtn setImage:[UIImage imageNamed:@"btn-all-repeat-down"] forState:UIControlStateHighlighted];
            break;
        }
    }
}

- (NSString*)convertTime:(float)f_time{
    int n_minite = (int)f_time / 60;
    int n_second = ((int)f_time) % 60;
    return [NSString stringWithFormat:@"%@:%@", (n_minite < 10 ? [NSString stringWithFormat:@"0%d", n_minite] : [NSString stringWithFormat:@"%d", n_minite]), (n_second < 10 ? [NSString stringWithFormat:@"0%d", n_second] : [NSString stringWithFormat:@"%d", n_second])];
}

- (void)handleMenuSequence{
    [[BSPlayInfo sharedInstance] setPlayMode:E_MODE_SEQUENCE];
    [_modeBtn setImage:[UIImage imageNamed:@"btn-order"] forState:UIControlStateNormal];
    [_modeBtn setImage:[UIImage imageNamed:@"btn-order-down"] forState:UIControlStateHighlighted];
}

- (void)handleMenuRing{
    [[BSPlayInfo sharedInstance] setPlayMode:E_MODE_RING];
    [_modeBtn setImage:[UIImage imageNamed:@"btn-all-repeat"] forState:UIControlStateNormal];
    [_modeBtn setImage:[UIImage imageNamed:@"btn-all-repeat-down"] forState:UIControlStateHighlighted];
}

- (void)handleMenuSingle{
    [[BSPlayInfo sharedInstance] setPlayMode:E_MODE_SINGLE];
    [_modeBtn setImage:[UIImage imageNamed:@"btn-repeat-once"] forState:UIControlStateNormal];
    [_modeBtn setImage:[UIImage imageNamed:@"btn-repeat-once-down"] forState:UIControlStateHighlighted];
}

- (void)handleMenuNoTiming{
    [[BSPlayInfo sharedInstance] setTimingType:E_TIMING_NO];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-no"] forState:UIControlStateNormal];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-no-down"] forState:UIControlStateHighlighted];
    
    [[AppDelegate sharedAppDelegate].mainTabBarController endTimingTimer];
}

- (void)handleTiming60{
    [[BSPlayInfo sharedInstance] setTimingType:E_TIMING_60];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-60"] forState:UIControlStateNormal];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-60-down"] forState:UIControlStateHighlighted];
    
    [[AppDelegate sharedAppDelegate].mainTabBarController startTimingTimer];
}

- (void)handleTiming30{
    [[BSPlayInfo sharedInstance] setTimingType:E_TIMING_30];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-30"] forState:UIControlStateNormal];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-30-down"] forState:UIControlStateHighlighted];
    
    [[AppDelegate sharedAppDelegate].mainTabBarController startTimingTimer];
}

- (void)handleTiming20{
    [[BSPlayInfo sharedInstance] setTimingType:E_TIMING_20];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-20"] forState:UIControlStateNormal];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-20-down"] forState:UIControlStateHighlighted];
    
    [[AppDelegate sharedAppDelegate].mainTabBarController startTimingTimer];
}

- (void)handleTiming10{
    [[BSPlayInfo sharedInstance] setTimingType:E_TIMING_10];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-10"] forState:UIControlStateNormal];
    [_timeBtn setImage:[UIImage imageNamed:@"timing-10-down"] forState:UIControlStateHighlighted];
    
    [[AppDelegate sharedAppDelegate].mainTabBarController startTimingTimer];
}


@end

