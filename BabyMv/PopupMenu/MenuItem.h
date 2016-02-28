//
//  MenuItem.h
//  KWPlayer
//
//  Created by 高 彬 on 12-3-22.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MenuItem : NSObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIColor* highColor;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, retain) id userData;

+ (MenuItem*) menuItemWithImage:(UIImage*)image title:(NSString*)title action:(SEL)action userData:(id)userData;

@end
