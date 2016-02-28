//
//  UINavigationController+Orientation.m
//  BabyMv
//
//  Created by ma on 2/15/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "UINavigationController+Orientation.h"

@implementation UINavigationController (Orientation)
- (BOOL)shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    return [self.topViewController supportedInterfaceOrientations];
}
@end
