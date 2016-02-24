//
//  UITabBar+Custom.h
//  BabyMv
//
//  Created by ma on 2/24/16.
//  Copyright © 2016 chenjingying. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (Custom)

-(void)setTabBarBackground:(UIImage *)backgroundImage;

@end

@interface CustomTabBarItem : UITabBarItem {
    UIImage *_customHighlightedImage;
    UIImage *_customNormalImage;
}

@property (nonatomic, strong) UIImage *customHighlightedImage;
@property (nonatomic, strong) UIImage *customNormalImage;

- (id)initWithTitle:(NSString *)title
        normalImage:(UIImage *)normalImage
   highlightedImage:(UIImage *)highlightedImage
                tag:(NSInteger)tag;
@end
