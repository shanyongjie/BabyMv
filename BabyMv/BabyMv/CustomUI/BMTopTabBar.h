//
//  BMTopTabBar.h
//  BabyMv
//
//  Created by ma on 2/6/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MacroDefinition.h"



@interface BMTopTabButton : UIButton
+(instancetype)NewWithName:(NSString*)name;
-(void)setTitle:(NSString *)title;
@end

typedef void(^BMTopTabsBLK)(int);

@interface BMTopTabBar : UIView
@property(nonatomic, copy)BMTopTabsBLK blk;
-(void)setItems:(NSArray *)items height:(int)height;
@property(nonatomic, assign)int tabTag;
@end


@interface BMBottomPlayingTabBar : UIView
@property(nonatomic, copy)BMTopTabsBLK blk;
-(void)setItems:(NSArray *)items height:(int)height;
- (void)beginUpdates;
- (void)endUpdates;
@property(nonatomic, assign)int tabTag;
@end
