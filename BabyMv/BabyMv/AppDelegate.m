//
//  AppDelegate.m
//  BabyMv
//
//  Created by 单永杰 on 16/2/5.
//  Copyright © 2016年 chenjingying. All rights reserved.
//

#import "AppDelegate.h"
#import "BMMainTabBarController.h"
#import "BMDataBaseManager.h"
#import "MacroDefinition.h"

#import "BMRequestManager.h"


#import "UIImage+Helper.h"


@interface AppDelegate ()
@property (nonatomic, strong) BMMainTabBarController* mainTabBarController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [BMDataBaseManager sharedInstance];
    NSArray* musicCateArr = [[BMDataBaseManager sharedInstance] getAllMusicCate];
//    if (!musicCateArr.count) {
        [BMRequestManager loadCategoryData];
//    } else {
//    }
    self.mainTabBarController = [[BMMainTabBarController alloc] init];
    [self setDefaultAppearance];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = self.mainTabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
            [navAppearance setBarStyle:UIBarStyleBlack];
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
            [navAppearance setBackgroundImage:[UIImage imageNamed:@"lxTop_Bg"] forBarMetrics:UIBarMetricsDefault];
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
