//
//  MenuItem.m
//  KWPlayer
//
//  Created by 高 彬 on 12-3-22.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import "MenuItem.h"

@implementation MenuItem

- (void) dealloc
{
	[_image release];
	[_title release];
    [_userData release];
    [super dealloc];
}

+ (MenuItem*) menuItemWithImage:(UIImage*)image title:(NSString*)title action:(SEL)action userData:(id)userData{
    MenuItem* item = [[MenuItem alloc] init];
    item.image = image;
    item.title = title;
    item.selector = action;
    item.userData = userData;
    return [item autorelease];
}

@end
