//
//  UITabBar+Custom.m
//  BabyMv
//
//  Created by ma on 2/24/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import "UITabBar+Custom.h"

@implementation UITabBar (Custom)
-(void)setTabBarBackground:(UIImage *)backgroundImage  {
    if([self respondsToSelector:@selector(setBackgroundImage:)]) {
        // ios 5+
        [self setBackgroundImage:backgroundImage];
    }  else  {
        // ios 3.x / 4.x
        self.layer.contents = (id)backgroundImage.CGImage;
    }
}
@end

@implementation CustomTabBarItem

- (id)initWithTitle:(NSString *)title
        normalImage:(UIImage *)normalImage
   highlightedImage:(UIImage *)highlightedImage
                tag:(NSInteger)tag{
    
    self = [super initWithTitle:title
                          image:nil
                            tag:tag];
    if(self) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
        if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)]) {
            [self setCustomNormalImage:[normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
            [self setCustomHighlightedImage:[highlightedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        }
        else {
            [self setCustomNormalImage:normalImage];
            [self setCustomHighlightedImage:highlightedImage];
        }
#else
        [self setCustomNormalImage:normalImage];
        [self setCustomHighlightedImage:highlightedImage];
#endif
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_5_0
        if ([self respondsToSelector:@selector(setTitlePositionAdjustment:)]) {
            [self setTitlePositionAdjustment:UIOffsetMake(0, -2)];
        }
#endif
    }
    return self;
}


-(UIImage *) selectedImage
{
    if (!self.customHighlightedImage) {
        return self.customNormalImage;
    }
    return self.customHighlightedImage;
}

-(UIImage *) unselectedImage
{
    return self.customNormalImage;
}

@end
