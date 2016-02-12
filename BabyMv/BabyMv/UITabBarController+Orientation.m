//
//  UITabBarController+Orientation.m
//  GuDong
//
//

#import "UITabBarController+Orientation.h"

@implementation UITabBarController (Orientation)

- (BOOL)shouldAutorotate
{
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.selectedViewController supportedInterfaceOrientations];
}

@end
