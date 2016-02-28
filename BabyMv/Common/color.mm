//
//  globalm.mm
//  KWPlayer
//
//  Created by YeeLion on 11-1-10.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <sys/time.h>
#import "color.h"


CGColorRef CreateDeviceGrayColor(CGFloat w, CGFloat a)
{
	CGColorSpaceRef gray = CGColorSpaceCreateDeviceGray();
	CGFloat comps[] = {w, a};
	CGColorRef color = CGColorCreate(gray, comps);
	CGColorSpaceRelease(gray);
	return color;
}

CGColorRef CreateDeviceRGBColor(CGFloat r, CGFloat g, CGFloat b, CGFloat a)
{
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGFloat comps[] = {r, g, b, a};
	CGColorRef color = CGColorCreate(rgb, comps);
	CGColorSpaceRelease(rgb);
	return color;
}

UIColor* UIColorFromRGBA(unsigned char red, unsigned char green, unsigned char blue, unsigned char alpha) {
    return [UIColor colorWithRed:(float)red/255.0
                           green:(float)green/255.0
                            blue:(float)blue/255.0
                           alpha:(float)alpha/255.0];
}

UIColor* UIColorFromRGB(unsigned char red, unsigned char green, unsigned char blue) {
    return [UIColor colorWithRed:(float)red/255.0
                           green:(float)green/255.0
                            blue:(float)blue/255.0
                           alpha:1.0];
}

UIColor* UIColorFromRGBValue(NSUInteger rgbValue) {
    return UIColorFromRGB((rgbValue & 0xFF0000) >> 16, 
                          (rgbValue & 0x00FF00) >> 8, 
                          (rgbValue & 0x0000FF)); 
}

UIColor* UIColorFromRGBAValue(NSUInteger rgbValue, int alpha) {
    return UIColorFromRGBA((rgbValue & 0xFF0000) >> 16, 
                           (rgbValue & 0x00FF00) >> 8, 
                           (rgbValue & 0x0000FF),
                           alpha);
}

//
CGFloat GetRValue(CGColorRef color) {
    //NSCAssert( 1 < CGColorGetNumberOfComponents(color) );
    return CGColorGetComponents(color)[0];
}

CGFloat GetGValue(CGColorRef color) {
    NSCAssert( 1 < CGColorGetNumberOfComponents(color), @"Unexpected CGColor value!" );
    return CGColorGetComponents(color)[1];
}

CGFloat GetBValue(CGColorRef color) {
    NSCAssert( 1 < CGColorGetNumberOfComponents(color), @"Unexpected CGColor value!" );
    return CGColorGetComponents(color)[2];
}

CGFloat GetAValue(CGColorRef color) {
    return CGColorGetAlpha(color);
}

UIColor* GetGradentColor(UIColor* color1, UIColor* color2, unsigned int step, unsigned int total)
{
	assert(total > 0 && step <= total);
	float scale2 = (float)step / total;
	float scale1 = 1 - scale2;
    CGColorRef clr1 = color1.CGColor;
    CGColorRef clr2 = color2.CGColor;
    UIColor* color = [UIColor colorWithRed:GetRValue(clr1) * scale1 + GetRValue(clr2) * scale2
                                     green:GetGValue(clr1) * scale1 + GetGValue(clr2) * scale2
                                      blue:GetBValue(clr1) * scale1 + GetBValue(clr2) * scale2
                                     alpha:GetAValue(clr1) * scale1 + GetAValue(clr2) * scale2];
	return color;
}


