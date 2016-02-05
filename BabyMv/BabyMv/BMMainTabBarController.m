//
//  BMMainTabBarController.m
//  BabyMv
//
//  Created by ma on 2/5/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "BMMainTabBarController.h"
#import "BMMusicVC.h"
#import "BMCartoonVC.h"
#import "BMPlayingVC.h"
#import "BMMYVC.h"
#import "BMSettingVC.h"



@interface BMMainTabBarController ()
@property(nonatomic, strong) BMMusicVC* musicVC;
@property(nonatomic, strong) BMCartoonVC* cartoonVC;
@property(nonatomic, strong) BMPlayingVC* playingVC;
@property(nonatomic, strong) BMMYVC* myVC;
@property(nonatomic, strong) BMSettingVC* settingVC;
@end

@implementation BMMainTabBarController

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.musicVC = [BMMusicVC new];
    self.cartoonVC = [BMCartoonVC new];
    self.playingVC = [BMPlayingVC new];
    self.myVC = [BMMYVC new];
    self.settingVC = [BMSettingVC new];
    
    self.musicVC.tabBarItem.title = @"儿歌";
    self.cartoonVC.tabBarItem.title = @"动画";
    self.playingVC.tabBarItem.title = @"播放";
    self.myVC.tabBarItem.title = @"我的";
    self.settingVC.tabBarItem.title = @"设置";
    
    self.viewControllers = @[self.musicVC, self.cartoonVC, self.playingVC, self.myVC, self.settingVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
