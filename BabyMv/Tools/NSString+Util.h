//
//  NSString+Util.h
//  KWPlayer
//
//  Created by Zhang Yuanqing on 12-7-5.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

__BEGIN_DECLS

NSString* SafeString(NSString* string);

BOOL IsEmptyString(NSString* string);

// @encoding: GB2312, BIG5, UTF-8, etc. default UTF-8
NSString* ConvertBytesToUTF8String(const char* bytes, int length, const char* encoding, NSString* illegalPlaceHolder);

__END_DECLS

@interface NSString (Util)

//+ (BOOL) isEmpty:(NSString*)str;

- (NSInteger) hexIntegerValue;

+ (NSString*)stringWithBytes:(const char*)bytes length:(int)length encoding:(const char*)encoding illegalPlaceHolder:(NSString*)illegalPlaceHolder;

@end
