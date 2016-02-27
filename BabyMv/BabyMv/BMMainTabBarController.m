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
#import "BSPlayInfo.h"
#import "UIImageView+WebCache.h"
#import "BMDataBaseManager.h"

#import <MediaPlayer/MediaPlayer.h>

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static int imageviewAngle = 0;

@interface BMMainTabBarController ()<UITabBarControllerDelegate>
@property(nonatomic, strong) UINavigationController* musicNAV;
@property(nonatomic, strong) UINavigationController* cartoonNAV;
@property(nonatomic, strong) UINavigationController* playingNAV;
@property(nonatomic, strong) UINavigationController* myNAV;
@property(nonatomic, strong) UINavigationController* settingNAV;
@property(nonatomic, weak)   UINavigationController* currentNAV;

@property(nonatomic, strong) BMMusicVC* musicVC;
@property(nonatomic, strong) BMCartoonVC* cartoonVC;
@property(nonatomic, strong) BMPlayingVC* playingVC;
@property(nonatomic, strong) BMMYVC* myVC;
@property(nonatomic, strong) BMSettingVC* settingVC;

@property(nonatomic, strong) CABasicAnimation* rotationAnimation;
@property(nonatomic, strong) UIImageView*  midImage;
@property(nonatomic, strong) UIButton* midButton;
@property(nonatomic, strong) UIButton* returnButton;

@property(nonatomic, strong) NSTimer*  timingTimer;

@property(nonatomic, assign) BOOL  bRotate;

@property(nonatomic, strong) NSTimer* rotateTimer;
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
    
    self.myVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"我的" normalImage:[UIImage imageNamed:@"wode"] highlightedImage:[UIImage imageNamed:@"wode_selected"] tag:3];
    [self.myVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:NavBarYellow} forState:UIControlStateSelected];
    [self.myVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:TabBarGray} forState:UIControlStateNormal];
    
    self.settingVC.tabBarItem = [[CustomTabBarItem alloc] initWithTitle:@"设置" normalImage:[UIImage imageNamed:@"setting"] highlightedImage:[UIImage imageNamed:@"setting_selected"] tag:4];
    [self.settingVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:NavBarYellow} forState:UIControlStateSelected];
    [self.settingVC.tabBarItem setTitleTextAttributes:
     @{NSForegroundColorAttributeName:TabBarGray} forState:UIControlStateNormal];
    
//    [self.musicVC.tabBarItem setImage:[UIImage imageNamed:@"tab_song"]];
//    [self.musicVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_song_selected"]];
//    [self.cartoonVC.tabBarItem setImage:[UIImage imageNamed:@"tab_cartoon"]];
//    [self.cartoonVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_cartoon_selected"]];
//    [self.playingVC.tabBarItem setImage:[UIImage imageNamed:@"tab_play1"]];
//    [self.playingVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"tab_play1_selected"]];
//    [self.myVC.tabBarItem setImage:[UIImage imageNamed:@"wode"]];
//    [self.myVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"wode_selected"]];
//    [self.settingVC.tabBarItem setImage:[UIImage imageNamed:@"setting"]];
//    [self.settingVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"setting_selected"]];
    
    self.viewControllers = @[self.musicNAV, self.cartoonNAV, self.playingNAV, self.myNAV, self.settingNAV];
    self.tabBar.backgroundColor = [UIColor yellowColor];
    self.selectedViewController = self.musicNAV;
    self.currentNAV = self.selectedViewController;
    {
        int buttonImageWidth = 60;
        int buttonImageHeight = 60;
        
        _midImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.tabBar.frame.size.width/2-30, [UIScreen mainScreen].bounds.size.height-60, buttonImageWidth, buttonImageHeight)];
        _midImage.contentMode = UIViewContentModeScaleAspectFill;
        _midImage.clipsToBounds = YES;
        _midImage.layer.masksToBounds = YES;
        _midImage.layer.cornerRadius = _midImage.frame.size.width / 2;
        _midImage.layer.borderColor = NavBarYellow.CGColor;
        _midImage.layer.borderWidth = 2;
        
        if ([BSPlayList sharedInstance].arryPlayList && [BSPlayList sharedInstance].arryPlayList.count) {
            NSString* image_url = ((BMCollectionDataModel*)[[BMDataBaseManager sharedInstance] musicCollectionById:[BSPlayList sharedInstance].currentItem.CollectionId]).Url;
            if (image_url && image_url.length) {
                [_midImage sd_setImageWithURL:[NSURL URLWithString:image_url] placeholderImage:[UIImage imageNamed:@"middle_play"]];
            }else {
                [_midImage setImage:[UIImage imageNamed:@"middle_play"]];
            }
            
        }else {
            [_midImage setImage:[UIImage imageNamed:@"middle_play"]];
        }
        
        [self.view addSubview:_midImage];
        
        self.midButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.midButton addTarget:self action:@selector(switchToPlayPage) forControlEvents:UIControlEventTouchUpInside];
        [self.midButton setBackgroundColor:[UIColor clearColor]];
        self.midButton.frame = CGRectMake(self.tabBar.frame.size.width/2-30, [UIScreen mainScreen].bounds.size.height-60, buttonImageWidth, buttonImageHeight);
//        self.midButton.layer.cornerRadius = self.midButton.frame.size.width / 2;
        
        [self.view addSubview:self.midButton];

        
        
        self.returnButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.returnButton addTarget:self action:@selector(returnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.returnButton setImage:[UIImage imageNamed:@"btn-back"] forState:UIControlStateNormal];
        [self.returnButton setBackgroundColor:[UIColor whiteColor]];
        self.returnButton.frame = CGRectMake(15, [UIScreen mainScreen].bounds.size.height-40, 32, 32);
        self.returnButton.layer.cornerRadius = 32 / 2;
        
        [self.view addSubview:self.returnButton];
        self.returnButton.hidden = YES;

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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayStateChanged) name:kCNotificationPlayStateChanged object:nil];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notifyLockScreenInfo) userInfo:nil repeats:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startTimingTimer{
    int n_time_delay = -1;
    switch ([[BSPlayInfo sharedInstance] getTimingType]) {
        case E_TIMING_60:
        {
            n_time_delay = 60 * 60;
            break;
        }
        case E_TIMING_30:
        {
            n_time_delay = 30 * 60;
            break;
        }
        case E_TIMING_20:
        {
            n_time_delay = 20 * 60;
            break;
        }
        case E_TIMING_10:
        {
            n_time_delay = 10 * 60;
            break;
        }
        default:
            break;
    }
    
    if (-1 != n_time_delay) {
        _timingTimer = [NSTimer scheduledTimerWithTimeInterval:n_time_delay target:self selector:@selector(stopAudioPlay) userInfo:nil repeats:NO];
    }
}

- (void)stopAudioPlay{
    [[AudioPlayerAdapter sharedPlayerAdapter] stop];
}

- (void)endTimingTimer{
    if (_timingTimer) {
        [_timingTimer invalidate];
        _timingTimer = nil;
    }
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
    self.currentNAV = nil;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        self.currentNAV = (UINavigationController *) viewController;
    }

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
    vc.midImage = self.midImage;
    self.midButton.hidden = YES;
    self.midImage.hidden = YES;
    [self.selectedViewController pushViewController:vc animated:YES];
    [self.selectedViewController hidesBottomBarWhenPushed];
//    [self.selectedViewController presentViewController:vc animated:YES completion:nil];
}

#pragma mark ----- audio play notification
- (void)AudioPlayFinishedNotification:(NSNotification*)notification{
    switch ([[BSPlayInfo sharedInstance] getPlayMode]) {
        case E_MODE_SEQUENCE:
        {
            if ([BSPlayList sharedInstance].nextItem) {
                [[AudioPlayerAdapter sharedPlayerAdapter] playNext];
            }else {
                [[AudioPlayerAdapter sharedPlayerAdapter] stop];
            }
            break;
        }
        case E_MODE_SINGLE:
        {
            [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:[BSPlayList sharedInstance].currentItem inList:[BSPlayList sharedInstance].listID delegate:nil];
            break;
        }
        case E_MODE_RING:
        {
            if ([BSPlayList sharedInstance].nextItem) {
                [[AudioPlayerAdapter sharedPlayerAdapter] playNext];
            }else {
                [[BSPlayList sharedInstance] setCurIndex:0];
                [[AudioPlayerAdapter sharedPlayerAdapter] playRingtoneItem:[BSPlayList sharedInstance].currentItem inList:[BSPlayList sharedInstance].listID delegate:nil];
            }
            break;
        }
        default:
            break;
    }
}

- (void)onPlayStateChanged{
    if (PlayStatePlaying == [AudioPlayerAdapter sharedPlayerAdapter].playState) {
        if ([BSPlayList sharedInstance].arryPlayList && [BSPlayList sharedInstance].arryPlayList.count) {
            NSString* image_url = ((BMCollectionDataModel*)[[BMDataBaseManager sharedInstance] musicCollectionById:[BSPlayList sharedInstance].currentItem.CollectionId]).Url;
            if (image_url && image_url.length) {
                [_midImage sd_setImageWithURL:[NSURL URLWithString:image_url] placeholderImage:[UIImage imageNamed:@"middle_play"]];
            }else {
                [_midImage setImage:[UIImage imageNamed:@"middle_play"]];
            }
            
        }else {
            [_midImage setImage:[UIImage imageNamed:@"middle_play"]];
        }
        
        [self beginRotate];
        
    }else {
        [self endRotate];
    }
}

- (void)beginRotate{
    if (_rotateTimer) {
        [_rotateTimer invalidate];
        _rotateTimer = nil;
    }
    
    _rotateTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(rotateImage) userInfo:nil repeats:YES];
}

- (void)endRotate{
    if (_rotateTimer) {
        [_rotateTimer invalidate];
        _rotateTimer = nil;
    }
}

- (void)rotateImage{
    imageviewAngle+=3;
    
    _midImage.transform = CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(imageviewAngle));
}


#pragma mark ----- 后台播放
- (void)notifyLockScreenInfo{
    PlayState cur_play_state = [AudioPlayerAdapter sharedPlayerAdapter].playState;
    if (PlayStatePlaying == cur_play_state) {
        BMDataModel* cur_ring = [AudioPlayerAdapter sharedPlayerAdapter].nowPlayingItem;
        if (cur_ring) {
            if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
                NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
                [dict setObject:cur_ring.Name forKey:MPMediaItemPropertyTitle];//歌曲名设置
                if (cur_ring.Artist) {
                    [dict setObject:cur_ring.Artist forKey:MPMediaItemPropertyArtist];//歌手名设置
                }

//                [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:self.artwork.image]  forKey:MPMediaItemPropertyArtwork];//专辑图片设置
                [dict setObject:[NSNumber numberWithDouble:[[AudioPlayerAdapter sharedPlayerAdapter] currentTime]] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime]; //音乐当前已经播放时间
                [dict setObject:[NSNumber numberWithFloat:1.0] forKey:MPNowPlayingInfoPropertyPlaybackRate];//进度光标的速度 （这个随 自己的播放速率调整，我默认是原速播放）
                [dict setObject:[NSNumber numberWithDouble:[AudioPlayerAdapter sharedPlayerAdapter].duration] forKey:MPMediaItemPropertyPlaybackDuration];//歌曲总时间设置
                [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];

            }
        }
    }
}

#pragma mark ---全局返回按钮
- (void)setGlobalReturnBtnHidden:(BOOL)hidden {
    self.returnButton.hidden = hidden;
}

-(void)returnBtnClick:(UIButton *)btn {
    if (self.currentNAV) {
        [self.currentNAV.topViewController.navigationController popViewControllerAnimated:YES];
    }
}

@end
