//
//  BMTopTabBar.m
//  BabyMv
//
//  Created by ma on 2/6/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMTopTabBar.h"
#import "UIImage+Helper.h"


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
        
        [self setTitleColor:RGB(0x7b4802, 1.0) forState:UIControlStateNormal];
        [self setTitleColor:RGB(0x7b4802, 1.0) forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage imageNamed:@"tab1_topButton_bg"] forState:UIControlStateSelected];
        [self setBackgroundImage:[UIImage createImageWithColor:NavBarYellow] forState:UIControlStateNormal];
        
        self.titleLabel.font =[UIFont systemFontOfSize:14];
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
    [hCons appendString:@"H:|-"];
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
            [hCons appendString:[NSString stringWithFormat:@"[%@(%@)]-", key, firstItem]];
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

@interface BMBottomPlayingTabBar ()
@property(nonatomic, strong)NSArray* items;
@property(nonatomic, strong)UIButton* preBtn;
@property(nonatomic, strong)UIButton* timeBtn;
@property(nonatomic, strong)UIButton* playBtn;
@property(nonatomic, strong)UIButton* modeBtn;
@property(nonatomic, strong)UIButton* nextBtn;
@property(nonatomic, strong)UIProgressView* processView;
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
        processView.progress = 0.3;
        
        InitViewX(UIButton, preBtn, self, 0);
        [preBtn setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
        [preBtn setImage:[UIImage imageNamed:@"btn-back-down"] forState:UIControlStateSelected];
        [preBtn addTarget:self action:@selector(genTabBtnCb:) forControlEvents:UIControlEventTouchUpInside];
        preBtn.tag = 1001;
        
        InitViewX(UIButton, timeBtn, self, 0);
        [timeBtn setImage:[UIImage imageNamed:@"btn-timing"] forState:UIControlStateNormal];
        [timeBtn setImage:[UIImage imageNamed:@"btn-timing-down"] forState:UIControlStateSelected];
        [timeBtn addTarget:self action:@selector(genTabBtnCb:) forControlEvents:UIControlEventTouchUpInside];
        timeBtn.tag = 1004;
        
        InitViewX(UIButton, playBtn, self, 0);
        [playBtn setImage:[UIImage imageNamed:@"btn-play"] forState:UIControlStateNormal];
        [playBtn setImage:[UIImage imageNamed:@"btn-play-down"] forState:UIControlStateSelected];
        [playBtn addTarget:self action:@selector(genTabBtnCb:) forControlEvents:UIControlEventTouchUpInside];
        playBtn.tag = 1002;
        
        InitViewX(UIButton, modeBtn, self, 0);
        [modeBtn setImage:[UIImage imageNamed:@"btn-order"] forState:UIControlStateNormal];
        [modeBtn setImage:[UIImage imageNamed:@"btn-all-repeat"] forState:UIControlStateSelected];
        [modeBtn addTarget:self action:@selector(genTabBtnCb:) forControlEvents:UIControlEventTouchUpInside];
        modeBtn.tag = 1000;
        
        InitViewX(UIButton, nextBtn, self, 0);
        [nextBtn setImage:[UIImage imageNamed:@"btn-next"] forState:UIControlStateNormal];
        [nextBtn setImage:[UIImage imageNamed:@"btn-next-down"] forState:UIControlStateSelected];
        [nextBtn addTarget:self action:@selector(genTabBtnCb:) forControlEvents:UIControlEventTouchUpInside];
        nextBtn.tag = 1003;
        
        //    NSArray *imgArr = @[@"btn-timing", @[@"btn-repeat-once", @"btn-order", @"btn-all-repeat"], @"btn-next"];
        NSDictionary* map = NSDictionaryOfVariableBindings(processView, preBtn, timeBtn, playBtn, modeBtn, nextBtn);
        NSDictionary* metrics = @{@"playBtnWidth":@(42), @"btnWidth":@(33), @"processViewHeight":@(2)};
        ViewAddCons(self, @"H:|-[preBtn(btnWidth)]-(>=0)-[timeBtn(btnWidth)]-(25)-[modeBtn(btnWidth)]-(25)-[nextBtn(btnWidth)]-(25)-[playBtn(playBtnWidth)]-|", metrics, map);
        ViewAddCons(self, @"H:|[processView]|", metrics, map);
        ViewAddCons(self, @"V:|[processView(processViewHeight)]-(2)-[playBtn(playBtnWidth)]", metrics, map);
        ViewAddCenterY(self, preBtn)
        ViewAddCenterY(self, timeBtn)
        ViewAddCenterY(self, modeBtn)
        ViewAddCenterY(self, nextBtn)
        
        self.items = @[preBtn, timeBtn, modeBtn, nextBtn, playBtn];
    }
    return self;
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

