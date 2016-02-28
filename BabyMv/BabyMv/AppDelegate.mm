//
//  AppDelegate.m
//  BabyMv
//
//  Created by 单永杰 on 16/2/5.
//  Copyright © 2016年 chenjingying. All rights reserved.
//

#import "AppDelegate.h"

#import "BMDataBaseManager.h"
#import "BMRequestManager.h"
#import "BMDataCacheManager.h"
#import "BMDataModel.h"
#import "MacroDefinition.h"
#import "AudioPlayer/AudioPlayerAdapter.h"
#import "BMMusicListVC.h"
#import "UIImage+Helper.h"

#import <AVFoundation/AVFoundation.h>
#import "AudioPlayerInterruptionDelegate.h"
#import "DownloadManager.h"
#import "RequestManager.h"
#import <MobClick.h>
#import "UMessage.h"

#define SECONDS_PER_DAY (24*60*60)



@interface AppDelegate ()

@end

@implementation AppDelegate

static AppDelegate *s_sharedApplication;
//UINavigationController *rootNavigationController;

static void audioSessionInterruptionListenerCallback(void* inUserData, UInt32 inInterruptionState);

//+ (UINavigationController *)rootNavigationController
//{
//    return rootNavigationController;
//}

+ (AppDelegate*)sharedAppDelegate{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (bool)isFirstStart{
    return false;
}

- (void)clearAllCaches{
//    BSAlertView* alert_view = [[BSAlertView alloc] initWithTitle:@"确定要清空所有缓存的资源吗？" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定" clickButton:^(NSInteger indexClick) {
//        if (1 == indexClick) {
//            Dir::DeleteDir(Dir::GetPath(Dir::PATH_VIDEO_CACHE));
//            //            Dir::DeleteDir(Dir::GetPath(Dir::PATH_BKIMAGE));
//            
//            DownloadManager::Instance()->ReleaseAllCacheItem();
//            
//            //        DeleteFile(NSString *path)
//            [[NSFileManager defaultManager] removeItemAtPath:[AppConfigure sharedAppConfigure].ringtoneCacheDirectory error:nil];
//            [[NSFileManager defaultManager] createDirectoryAtPath:[AppConfigure sharedAppConfigure].ringtoneCacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
//        }
//    }];
//    [alert_view show];
}

- (void)handleAudioSessionInterruption:(UInt32)interruptionState
{
    if (self.interruptionHandlerObject && [self.interruptionHandlerObject respondsToSelector:@selector(handleAudioSessionInterruption:)])
    {
        [self.interruptionHandlerObject handleAudioSessionInterruption:interruptionState];
    }
}

static void audioSessionInterruptionListenerCallback(void* inUserData, UInt32 inInterruptionState)
{
    AppDelegate* _self = (__bridge AppDelegate*)inUserData;
    [_self handleAudioSessionInterruption:inInterruptionState];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [MobClick startWithAppkey:@"54be6f7cfd98c51f9e00008f"];
    [UMessage startWithAppkey:@"54be6f7cfd98c51f9e00008f" launchOptions:launchOptions];
    [UMessage setLogEnabled:YES];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    if(BIGTHANIOS8)
    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
    } else{
        //register remoteNotification types (iOS 8.0以下)
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
#else
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
    //for log
    [UMessage setLogEnabled:YES];

    
    [self loadCacheData];
    self.mainTabBarController = [[BMMainTabBarController alloc] init];
    [self setDefaultAppearance];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    RequestManager::instance()->start();
    DownloadManager::Instance()->start();
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.mainTabBarController;
    [self.window makeKeyAndVisible];
    
    //处理推送的时机，页面有了以后，再处理push
    [self dealPushNotification:application pushedNotification:launchOptions];
    
    
    return YES;
}

-(void)dealPushNotification:(UIApplication *)application launchOptions:(NSDictionary *)launchOptions {
    NSString* str = [NSString stringWithFormat:@"推送消息的launchOptions内容：%@", launchOptions];
    UIBlockAlertView* blockView = [[UIBlockAlertView alloc]initWithTitle:str cancelButtonTitle:@"取消" otherButtons:[NSArray arrayWithObjects:@"确定", nil] andDeal:^(UIBlockAlertView *alert, NSInteger clickIndex) {
    }];
    [blockView show];
    if (launchOptions) {
        NSDictionary *pushNotificationDic=[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        [self dealPushNotification:application pushedNotification:pushNotificationDic];
    }
}

-(void)dealPushNotification:(UIApplication *)application pushedNotification:(NSDictionary *)pushNotificationDic {
//    NSString* str = [NSString stringWithFormat:@"推送消息的内容：%@", pushNotificationDic];
//    UIBlockAlertView* blockView = [[UIBlockAlertView alloc]initWithTitle:str cancelButtonTitle:@"取消" otherButtons:[NSArray arrayWithObjects:@"确定", nil] andDeal:^(UIBlockAlertView *alert, NSInteger clickIndex) {
//    }];
//    [blockView show];
//    return;
    
    NSString* type = nil;
    if (pushNotificationDic) {
        long n_badge = application.applicationIconBadgeNumber;
        if (0 < n_badge) {
            application.applicationIconBadgeNumber = --n_badge;
            [application cancelAllLocalNotifications];
        }
        
        type=[pushNotificationDic objectForKey:@"type"];
        
        if ([type isEqualToString:@"video"]) {
            BMCartoonCollectionDataModel* cate_info = [[BMCartoonCollectionDataModel alloc] init];
            cate_info.Rid = [pushNotificationDic objectForKey:@"id"];
            cate_info.Name = [pushNotificationDic objectForKey:@"name"];
            self.mainTabBarController.selectedViewController = self.mainTabBarController.cartoonNAV;
            BMMusicListVC* mvlistview = [BMMusicListVC new];
            mvlistview.vcType = MyListVCTypeCartoon;
            mvlistview.currentCartoonCollectionData = cate_info;
            [self.mainTabBarController.cartoonNAV.navigationController pushViewController:mvlistview animated:YES];
        }else if([type isEqualToString:@"audio"]){
            BMCollectionDataModel* cate_info = [[BMCollectionDataModel alloc] init];
            cate_info.Rid = [pushNotificationDic objectForKey:@"id"];
            cate_info.Name = [pushNotificationDic objectForKey:@"name"];
            self.mainTabBarController.selectedViewController = self.mainTabBarController.musicNAV;
            BMMusicListVC* mvlistview = [BMMusicListVC new];
            mvlistview.vcType = MyListVCTypeMusic;
            mvlistview.currentCollectionData = cate_info;
            [self.mainTabBarController.musicNAV.navigationController pushViewController:mvlistview animated:YES];
        }else if([type isEqualToString:@"upgrade"]){
            //                NSString* str_title = [pushNotificationDic objectForKey:@"title"];
            //                NSString* str_content = [pushNotificationDic objectForKey:@"content"];
            //                BSAlertView* alert_view = [[BSAlertView alloc] initWithTitle:str_title message:str_content cancelButtonTitle:@"取消" otherButtonTitles:@"马上升级" clickButton:^(NSInteger indexButton) {
            //                    if (1 == indexButton) {
            //                        if (NSOrderedAscending == [[UIDevice currentDevice].systemVersion compare:@"7.0"]) {
            //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=894495836"]];
            //                        }else {
            //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id894495836"]];
            //                        }
            //                    }
            //                }];
            //                [alert_view show];
        }else if([type isEqualToString:@"reco"]){
            //                NSString* str_title = [pushNotificationDic objectForKey:@"title"];
            //                NSString* str_content = [pushNotificationDic objectForKey:@"content"];
            //                NSString* str_app_id = [pushNotificationDic objectForKey:@"id"];
            //                BSAlertView* alert_view = [[BSAlertView alloc] initWithTitle:str_title message:str_content cancelButtonTitle:@"取消" otherButtonTitles:@"马上安装" clickButton:^(NSInteger indexButton) {
            //                    if (1 == indexButton) {
            //                        if (NSOrderedAscending == [[UIDevice currentDevice].systemVersion compare:@"7.0"]) {
            //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", str_app_id]]];
            //                        }else {
            //                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", str_app_id]]];
            //                        }
            //                    }
            //                }];
            //                [alert_view show];
        }else if([type isEqualToString:@"broad"]){
            NSString* str_title = [pushNotificationDic objectForKey:@"title"];
            NSString* str_content = [pushNotificationDic objectForKey:@"content"];
            UIAlertView* alert_view = [[UIAlertView alloc] initWithTitle:str_title message:str_content delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert_view show];
        }else if([type isEqualToString:@"m_album"]){
            //                BSCateItem* cate_info = [[BSCateItem alloc] init];
            //                NSString* str_title = [pushNotificationDic objectForKey:@"title"];
            //                NSString* str_url = [pushNotificationDic objectForKey:@"url"];
            //
            //                CGRect rect_song_list = _mainViewController.view.bounds;
            //                BSWebViewController* album_view = [[BSWebViewController alloc] initWithTitle:str_title URLString:[NSString stringWithFormat:@"%@&ddsrc=erge_ip&dddid=%@", str_url, [BSKeyChain getUserId]]];
            //
            //                [rootNavigationController pushViewController:album_view animated:YES];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"%@",[[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                  stringByReplacingOccurrencesOfString: @">" withString: @""]
                 stringByReplacingOccurrencesOfString: @" " withString: @""]);
    [UMessage registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMessage didReceiveRemoteNotification:userInfo];
    [self dealPushNotification:application pushedNotification:userInfo];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [[AudioPlayerAdapter sharedPlayerAdapter] play];//暂停
                break;
                
            case UIEventSubtypeRemoteControlPause:
                [[AudioPlayerAdapter sharedPlayerAdapter] pause];//暂停
                break;
                
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[AudioPlayerAdapter sharedPlayerAdapter] playPrev]; // 播放上一曲按钮
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [[AudioPlayerAdapter sharedPlayerAdapter] playNext]; // 播放下一曲按钮
                break;
                
            default:
                break;
        }
    }
}


-(void) loadCacheData {
    //数据库初始化
    [BMDataBaseManager sharedInstance];
    //加载音频缓存
    NSArray* musicCateArr       = [[BMDataBaseManager sharedInstance] getAllMusicCate];
    NSArray* musicCollections   = [[BMDataBaseManager sharedInstance] getAllMusicCollection];
    NSArray* musicLists         = [[BMDataBaseManager sharedInstance] getAllMusicList];
    
    BOOL needRequestNewData = NO;
    if (musicCateArr.count) {
        //数据库数据时效性设置，超时，获取最新数据替换原有数据
#if DEBUG
        needRequestNewData = ([((BMDataModel *)musicCateArr[0]).Time longLongValue] + 60 < [[NSDate date] timeIntervalSince1970])?YES:NO;
#else
        needRequestNewData = ([((BMDataModel *)musicCateArr[0]).Time longLongValue] + SECONDS_PER_DAY < [[NSDate date] timeIntervalSince1970])?YES:NO;
#endif
    }
    if (musicLists.count && !needRequestNewData) {
        for (BMListDataModel* listData in musicLists) {
            [BMDataCacheManager setMusicList:@[listData] collectionId:listData.CollectionId];
        }
    }
    if (musicCollections.count && !needRequestNewData) {
        for (BMCollectionDataModel* collectionData in musicCollections) {
            [BMDataCacheManager setMusicCollection:@[collectionData] cateId:collectionData.CateId];
        }
    }
    if (!musicCateArr.count || needRequestNewData) {
        [BMRequestManager loadCategoryData:MyRequestTypeMusic];
    } else {
        [BMDataCacheManager setMusicCate:musicCateArr];
        for (BMDataModel* musicCategory in musicCateArr) {
            if (![musicCategory.BindingCollectionId isEqualToNumber:[NSNumber numberWithInt:0]]) {
                [BMDataCacheManager setMusicCollectionId:musicCategory.BindingCollectionId cateId:musicCategory.Rid];
            }
        }
    }
    //加载视频缓存
    NSArray* cartoonCateArr       = [[BMDataBaseManager sharedInstance] getAllCartoonCate];
    NSArray* cartoonCollections   = [[BMDataBaseManager sharedInstance] getAllCartoonCollection];
    NSArray* cartoonLists         = [[BMDataBaseManager sharedInstance] getAllCartoonList];
    if (cartoonLists.count && !needRequestNewData) {
        for (BMCartoonListDataModel* listData in cartoonLists) {
            [BMDataCacheManager setCartoonList:@[listData] collectionId:listData.CollectionId];
        }
    }
    if (cartoonCollections.count && !needRequestNewData) {
        for (BMCartoonCollectionDataModel* collectionData in cartoonCollections) {
            [BMDataCacheManager setCartoonCollection:@[collectionData] cateId:collectionData.CateId];
        }
    }
    if (!cartoonCateArr.count || needRequestNewData) {
        [BMRequestManager loadCategoryData:MyRequestTypeCartoon];
    } else {
        [BMDataCacheManager setCartoonCate:cartoonCateArr];
        for (BMDataModel* cartoonCategory in cartoonCateArr) {
            if (![cartoonCategory.BindingCollectionId isEqualToNumber:[NSNumber numberWithInt:0]]) {
                [BMDataCacheManager setCartoonCollectionId:cartoonCategory.BindingCollectionId cateId:cartoonCategory.Rid];
            }
        }
    }
    
    //新建下载目录
    BOOL dirExist = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:DOWNLOAD_DIR isDirectory:&dirExist]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DOWNLOAD_DIR withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

-(void) setDefaultAppearance
{
    //ios7
    if (NSProtocolFromString(@"UIAppearance") != nil) {
        id navAppearance = [UINavigationBar appearanceWhenContainedIn:[UINavigationController class],nil];
        id barButtonAppearance = [UIBarButtonItem appearanceWhenContainedIn:[BMMainTabBarController class],nil];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7) {
            [navAppearance setBarTintColor:NavBarYellow];
            [navAppearance setTintColor:[UIColor whiteColor]];
//            [navAppearance setBarStyle:UIBarStyleBlack];
            [navAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
            [barButtonAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         [UIFont systemFontOfSize:15],UITextAttributeFont,nil]
                                               forState:UIControlStateNormal];
            [[UIImageView appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
            [[UISegmentedControl appearance] setTintColor:RGB(0x476294,1)];
            
#endif
            
            if ([UITableView instancesRespondToSelector:@selector(sectionIndexBackgroundColor)]) {
                id tableAppearance = [UITableView appearance];
                [tableAppearance setSectionIndexMinimumDisplayRowCount:3];
                [tableAppearance setSectionIndexBackgroundColor:[UIColor clearColor]];
                [tableAppearance setSectionIndexTrackingBackgroundColor:[UIColor colorWithWhite:0 alpha:0.1f]];
            }
        }
        else {
            [navAppearance setTintColor:NavBarYellow];
            [navAppearance setBackgroundImage:[UIImage imageNamed:@"Top_Bg"] forBarMetrics:UIBarMetricsDefault];
            [navAppearance setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor],UITextAttributeTextColor,
                                                   [UIFont boldSystemFontOfSize:19],UITextAttributeFont,
                                                   nil]];
            [barButtonAppearance setTitleTextAttributes:
             @{UITextAttributeTextColor:[UIColor whiteColor],
               UITextAttributeFont:[UIFont systemFontOfSize:15],
               UITextAttributeTextShadowColor:[UIColor clearColor]}
                                               forState:UIControlStateNormal];
            [barButtonAppearance setTitleTextAttributes:
             @{UITextAttributeTextColor:[UIColor grayColor],
               UITextAttributeTextShadowColor:[UIColor clearColor]}
                                               forState:UIControlStateHighlighted];
            [barButtonAppearance setBackgroundImage:[UIImage createImageWithColor:[UIColor clearColor]] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            
            
        }
        if ([UIDevice currentDevice].systemVersion.intValue != 7) {
            [barButtonAppearance setBackButtonBackgroundImage:[[UIImage imageNamed:@"btn_backarrow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 0) resizingMode:UIImageResizingModeStretch]forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
            [barButtonAppearance setBackButtonBackgroundImage:[[[UIImage imageNamed:@"btn_backarrow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 0) resizingMode:UIImageResizingModeStretch] imageWithAlignmentRectInsets:UIEdgeInsetsMake(-2, 0, -2, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        }
        
        [barButtonAppearance setBackButtonTitlePositionAdjustment:UIOffsetMake(3, 0) forBarMetrics:UIBarMetricsDefault];
    }
}

@end
