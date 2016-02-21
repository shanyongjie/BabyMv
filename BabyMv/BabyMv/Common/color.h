//
//  globalm.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-10.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef _COLOR_H__
#define _COLOR_H__

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a);    
    CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a);
    
    // alpha: 0~255

#ifndef RGBCOLOR
#define RGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a) * 255]
#define RGBCOLORVALUE(rgb)      UIColorFromRGBValue((rgb))
#define RGBACOLORVALUE(rgb, a)  UIColorFromRGBAValue((rgb), (a) * 255)
#define CLEAR_COLOR [UIColor clearColor]
#endif
    
    UIColor* UIColorFromRGBA(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha);
    
    UIColor* UIColorFromRGB(unsigned char red, unsigned char green, unsigned char blue);
    
    UIColor* UIColorFromRGBValue(NSUInteger rgbValue);
    UIColor* UIColorFromRGBAValue(NSUInteger rgbValue, int alpha);
    
    //
    CGFloat GetRValue(CGColorRef color);
    CGFloat GetGValue(CGColorRef color);
    CGFloat GetBValue(CGColorRef color);
    CGFloat GetAValue(CGColorRef color);
    
    UIColor* GetGradentColor(UIColor* color1, UIColor* color2, unsigned int step, unsigned int total);
	

#ifdef __cplusplus
}
#endif

#endif // _COLOR_H__

