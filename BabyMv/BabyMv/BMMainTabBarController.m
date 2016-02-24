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
#import "MacroDefinition.h"
#import "AppDelegate.h"
#import "UITabBarController+Orientation.h"
#import "UINavigationController+Orientation.h"
#import "Notification.h"
#import "BSPlayList.h"
#import "AudioPlayerAdapter.h"
#import "UITabBar+Custom.h"

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

@property(nonatomic, strong) CABasicAnimation* rotationAnimation;
@property(nonatomic, strong) UIButton* midButton;
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
    
    self.musicVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"儿歌" normalImage:[UIImage imageNamed:@"tab_song"] highlightedImage:[UIImage imageNamed:@"tab_song_selected"] tag:0];
    [self.musicVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:NavBarYellow} forState:UIControlStateSelected];
    [self.musicVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:TabBarGray} forState:UIControlStateNormal];
    
    self.cartoonVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"动画" normalImage:[UIImage imageNamed:@"tab_cartoon"] highlightedImage:[UIImage imageNamed:@"tab_cartoon_selected"] tag:1];
    [self.cartoonVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:NavBarYellow} forState:UIControlStateSelected];
    [self.cartoonVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:TabBarGray} forState:UIControlStateNormal];
    
    self.playingVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"播放" image:nil tag:2];
    [self.playingVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:NavBarYellow} forState:UIControlStateNormal];
    
    self.myVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"我的" normalImage:[UIImage imageNamed:@"tab_fav"] highlightedImage:[UIImage imageNamed:@"tab_fav_selected"] tag:3];
    [self.myVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:NavBarYellow} forState:UIControlStateSelected];
    [self.myVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:TabBarGray} forState:UIControlStateNormal];
    
    self.settingVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"设置" normalImage:[UIImage imageNamed:@"tab_download"] highlightedImage:[UIImage imageNamed:@"tab_download_selected"] tag:4];
    [self.settingVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:NavBarYellow} forState:UIControlStateSelected];
    [self.settingVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:TabBarGray} forState:UIControlStateNormal];
    
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
    
    {
        int buttonImageWidth = 60;
        int buttonImageHeight = 60;
        self.midButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.midButton addTarget:self action:@selector(switchToPlayPage) forControlEvents:UIControlEventTouchUpInside];
        [self.midButton setBackgroundImage:[UIImage imageNamed:@"middle_play"] forState:UIControlStateNormal];
        [self.midButton setBackgroundImage:[UIImage imageNamed:@"middle_play"] forState:UIControlStateHighlighted];
        self.midButton.frame = CGRectMake(self.tabBar.frame.size.width/2-30, [UIScreen mainScreen].bounds.size.height-60, buttonImageWidth, buttonImageHeight);
        [self.view addSubview:self.midButton];

/*
        _rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        _rotationAnimation.toValue =  [NSNumber numberWithFloat: M_PI * 2.0 ];
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _rotationAnimation.duration = 10;
        _rotationAnimation.repeatCount = 1000;//你可以设置到最大的整数值
        _rotationAnimation.autoreverses = NO;
        _rotationAnimation.cumulative = NO;
        _rotationAnimation.removedOnCompletion = NO;
        _rotationAnimation.fillMode = kCAFillModeForwards;
        if ([UIApplication sharedApplication].keyWindow) {
            [[UIApplication sharedApplication].keyWindow addSubview:self.midButton];
        } else if ([[UIApplication sharedApplication] windows].count>0) {
            [[[[UIApplication sharedApplication] windows]objectAtIndex:0] addSubview:self.midButton];
        }
        */
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AudioPlayFinishedNotification:) name:kCNotificationPlayItemFinished object:nil];
    }
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

- (void)switchToPlayPage {
    BMPlayingVC* vc = [BMPlayingVC new];
    vc.midButton = self.midButton;
    self.midButton.hidden = YES;
    [self.selectedViewController pushViewController:vc animated:YES];
    [self.selectedViewController hidesBottomBarWhenPushed];
//    [self.selectedViewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark ----- audio play notification
- (void)AudioPlayFinishedNotification:(NSNotification*)notification{
    if ([BSPlayList sharedInstance].nextItem) {
        [[AudioPlayerAdapter sharedPlayerAdapter] playNext];
    }else {
        [[BSPlayList sharedInstance] setCurIndex:0];
        [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:[BSPlayList sharedInstance].currentItem inList:[BSPlayList sharedInstance].listID delegate:nil];
    }
}
@end
