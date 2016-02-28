//
//  BMMainTabBarController.h
//  BabyMv
//
//  Created by ma on 2/5/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMMainTabBarController : UITabBarController
@property(nonatomic, readonly) UINavigationController* musicNAV;
@property(nonatomic, readonly) UINavigationController* cartoonNAV;

- (void)setGlobalReturnBtnHidden:(BOOL)hidden;
- (void)startTimingTimer;
- (void)endTimingTimer;

@end
