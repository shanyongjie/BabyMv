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
#import "AppDelegate.h"


@interface BMMainTabBarController ()<UITabBarControllerDelegate>
@property(nonatomic, strong) UINavigationController* musicNAV;
@property(nonatomic, strong) UINavigationController* cartoonNAV;
@property(nonatomic, strong) UINavigationController* playingNAV;
@property(nonatomic, strong) UINavigationController* myNAV;
@property(nonatomic, strong) UINavigationController* settingNAV;

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
        self.delegate = self;
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
    self.musicVC.view.backgroundColor = [UIColor whiteColor];
    self.cartoonVC.view.backgroundColor = [UIColor whiteColor];
    self.playingVC.view.backgroundColor = [UIColor whiteColor];
    self.myVC.view.backgroundColor = [UIColor whiteColor];
    self.settingVC.view.backgroundColor = [UIColor whiteColor];
   
    self.musicNAV = [[UINavigationController alloc] initWithRootViewController:self.musicVC];
    [self.musicNAV.navigationBar setTranslucent:NO];
    self.cartoonNAV = [[UINavigationController alloc] initWithRootViewController:self.cartoonVC];
    [self.cartoonNAV.navigationBar setTranslucent:NO];
    self.playingNAV = [[UINavigationController alloc] initWithRootViewController:self.playingVC];
    [self.playingNAV.navigationBar setTranslucent:NO];
    self.myNAV = [[UINavigationController alloc] initWithRootViewController:self.myVC];
    [self.myNAV.navigationBar setTranslucent:NO];
    self.settingNAV = [[UINavigationController alloc] initWithRootViewController:self.settingVC];
    [self.settingNAV.navigationBar setTranslucent:NO];

    self.musicVC.tabBarItem.title = @"儿歌";
    self.cartoonVC.tabBarItem.title = @"动画";
    self.playingVC.tabBarItem.title = @"播放";
    self.myVC.tabBarItem.title = @"我的";
    self.settingVC.tabBarItem.title = @"设置";
    
    [self.musicVC.tabBarItem setImage:[UIImage imageNamed:@"tab_song"]];
    [self.musicVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_song_selected"]];
    [self.cartoonVC.tabBarItem setImage:[UIImage imageNamed:@"tab_cartoon"]];
    [self.cartoonVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_cartoon_selected"]];
    [self.playingVC.tabBarItem setImage:[UIImage imageNamed:@"tab_play1"]];
    [self.playingVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_play1_selected"]];
    [self.myVC.tabBarItem setImage:[UIImage imageNamed:@"tab_fav"]];
    [self.myVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_fav_selected"]];
    [self.settingVC.tabBarItem setImage:[UIImage imageNamed:@"tab_download"]];
    [self.settingVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_download_selected"]];
    
    self.viewControllers = @[self.musicNAV, self.cartoonNAV, self.playingNAV, self.myNAV, self.settingNAV];
    self.tabBar.backgroundColor = [UIColor yellowColor];
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

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController *) viewController;
        if ([nav.topViewController isEqual:self.playingVC]) {
            BMPlayingVC* vc = [BMPlayingVC new];
            [tabBarController.selectedViewController pushViewController:vc animated:YES];
            return NO;
        }
        return YES;
    }
    return NO;
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isEqual:self.musicVC]) {
        
    }
    if ([viewController isEqual:self.cartoonVC]) {
        
    }
    if ([viewController isEqual:self.playingVC]) {
        
    }
    if ([viewController isEqual:self.myVC]) {
        
    }
    if ([viewController isEqual:self.settingVC]) {
        
    }
}

@end