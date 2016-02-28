//
//  global.m
//  TaoYing
//
//  Created by mistyzyq on 13-1-9.
//  Copyright (c) 2013年 HuaYing Co., Ltd. All rights reserved.
//

#import "global.h"

SEL fuzz(NSString* format, ...)
{
    va_list args;
    va_start(args, format);
    NSString* selName = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    SEL sel = NSSelectorFromString(selName);
    [selName release];
    return sel;
}

Class fuzzClass(NSString* format, ...)
{
    va_list args;
    va_start(args, format);
    NSString* className = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    Class class = NSClassFromString(className);
    [className release];
    return class;
}