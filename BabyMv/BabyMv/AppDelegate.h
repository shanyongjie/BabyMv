//
//  AppDelegate.h
//  BabyMv
//
//  Created by 单永杰 on 16/2/5.
//  Copyright © 2016年 chenjingying. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AudioPlayerInterruptionDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) EGMainViewController    *mainViewController;
@property (/*weak,*/ nonatomic, weak) id<AudioPlayerInterruptionDelegate> interruptionHandlerObject;

+ (AppDelegate*)sharedAppDelegate;

+(UINavigationController*) rootNavigationController;
-(UINavigationController*) currentTabNaviatrionController;

- (void)clearAllCaches;

- (bool)isFirstStart;

- (void)shareMusicAlbumToSocialSpace:(NSDictionary*)dic_shared_items;

@end

static inline AppDelegate* GetAppDelegate()
{
    return (AppDelegate*)[AppDelegate sharedAppDelegate];
}

