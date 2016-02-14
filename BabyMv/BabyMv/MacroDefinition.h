//
//  MacroDefinition.h
//  BabyMv
//
//  Created by ma on 2/7/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#ifndef MacroDefinition_h
#define MacroDefinition_h



typedef enum : NSUInteger {
    MyListVCTypeMusic,
    MyListVCTypeCartoon,
} MyListVCType;

typedef enum : NSUInteger {
    MyTableViewTypeMusic,
    MyTableViewTypeMusicDown,
    MyTableViewTypeCartoon,
} MyTableViewType;

typedef enum : NSUInteger {
    MyRequestTypeMusic,
    MyRequestTypeCartoon,
} MyRequestType;





#define IPA_VER @"BabyMv_ip_1.0.0.0_dbg.ipa"

#define CARTOON_CATE            [NSString stringWithFormat:@"http://coollisten.duapp.com/?type=getNewVideoCate&ver=%@", IPA_VER]
#define CARTOON_COLLECT(cateId) [NSString stringWithFormat:@"http://coollisten.duapp.com/?type=getNewMvList&cateId=%@&ver=%@", cateId, IPA_VER]
#define CARTOON_LIST(mvId)      [NSString stringWithFormat:@"http://coollisten.duapp.com/?type=getNewVideoList&mvId=%@&ver=%@", mvId, IPA_VER]

#define MUSIC_CATE              [NSString stringWithFormat:@"http://coollisten.duapp.com/?type=getAudioCateList&ver=%@", IPA_VER]
#define MUSIC_COLLECT(cateId)   [NSString stringWithFormat:@"http://coollisten.duapp.com/?type=getAudioCollectList&cateId=%@&ver=%@", cateId, IPA_VER]
#define MUSIC_LIST(mvId)        [NSString stringWithFormat:@"http://coollisten.duapp.com/?type=getAudioList&collectId=%@&ver=%@", mvId, IPA_VER]

//#define FEEDBACK_URL [NSString stringWithFormat:@"http://coollisten.duapp.com/?type=statistic&source=xxxxx&rid=xxxxx"]


#define InitViewX(viewType, viewName, SUPERVIEW, TAG)              \
viewType* viewName = [viewType new];                        \
viewName.translatesAutoresizingMaskIntoConstraints=NO;      \
self.viewName = viewName;                               \
viewName.tag = TAG;                                         \
[SUPERVIEW addSubview:viewName];


#define InitView(viewType, viewName, SUPERVIEW, TAG)              \
viewType* viewName = [viewType new];                        \
viewName.translatesAutoresizingMaskIntoConstraints=NO;      \
viewName.tag = TAG;                                         \
[SUPERVIEW addSubview:viewName];


#define ViewAddCons(VIEW, FORMAT, METRICS, MAP)                     \
[VIEW addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT options:0 metrics:METRICS views:MAP]];

//这里的align是更具多个成员之间取最小的来做排版，而不会影响它们自己和SuperView
#define ViewAddConsAlign(VIEW, FORMAT, OPTIONS ,METRICS, MAP)       \
[VIEW addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT options:OPTIONS metrics:METRICS views:MAP]];

#define ViewAddCenterX(BASEVIEW, VIEW)       \
[BASEVIEW addConstraint:[NSLayoutConstraint constraintWithItem:VIEW attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:BASEVIEW attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];

#define ViewAddCenterY(BASEVIEW, VIEW)       \
[BASEVIEW addConstraint:[NSLayoutConstraint constraintWithItem:VIEW attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:BASEVIEW attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];



#define MAIN_WIDTH    ([UIScreen mainScreen].applicationFrame.size.width)
#define MAIN_HEIGHT   ([UIScreen mainScreen].applicationFrame.size.height-44)

#define MAIN_BOUNDS_WIDTH    [[UIScreen mainScreen] bounds].size.width
#define MAIN_BOUNDS_HEIGHT   [[UIScreen mainScreen] bounds].size.height

//颜色宏
#define RGB(colorRgb,__a)  [UIColor colorWithRed:((colorRgb & 0xFF0000) >> 16)/255.0 green:((colorRgb & 0xFF00) >> 8)/255.0 blue:((colorRgb & 0xFF)/255.0) alpha:__a]
#define RGBColor(__r,__g,__b,__a)  [UIColor colorWithRed:(CGFloat)__r/0xff green:(CGFloat)__g/0xff blue:(CGFloat)__b/0xff alpha:__a]


#define NavBarYellow RGB(0xfecd3f, 1.0)


#define SCREEN_SCALE ((int)[[UIScreen mainScreen] scale])
#define IOS8WIDTH    (self.frame.size.width)


#define LAYOUT_DEFAULT_WIDTH    ([UIScreen mainScreen].applicationFrame.size.width)
#define LAYOUT_DEFAULT_HEIGHT   ([UIScreen mainScreen].applicationFrame.size.height-44)
#define VIEW_DEFAULT_WIDTH      LAYOUT_DEFAULT_WIDTH//(self.view.bounds.size.width)
#define VIEW_DEFAULT_HEIGHT     (self.view.bounds.size.height)


#define LOAD_MUSIC_CATEGORY_DATA_FINISHED  @"LOAD_MUSIC_CATEGORY_DATA_FINISHED"
#define LOAD_MUSIC_COLLECTION_DATA_FINISHED  @"LOAD_MUSIC_COLLECTION_DATA_FINISHED"
#define LOAD_MUSIC_LIST_DATA_FINISHED  @"LOAD_MUSIC_LIST_DATA_FINISHED"

#define LOAD_CARTOON_CATEGORY_DATA_FINISHED  @"LOAD_CARTOON_CATEGORY_DATA_FINISHED"
#define LOAD_CARTOON_COLLECTION_DATA_FINISHED  @"LOAD_CARTOON_COLLECTION_DATA_FINISHED"
#define LOAD_CARTOON_LIST_DATA_FINISHED  @"LOAD_CARTOON_LIST_DATA_FINISHED"



#endif /* MacroDefinition_h */
