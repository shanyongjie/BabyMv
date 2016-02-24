//
//  UINavigationBar+Custom.m
//  BabyMv
//
//  Created by ma on 2/24/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "UINavigationBar+Custom.h"

@implementation UINavigationBar (Custom)

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    if([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    } else {
        // ios 3.x / 4.x
        self.layer.contents = (id)backgroundImage.CGImage;
    }
}

@end
