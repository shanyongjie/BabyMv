//
//  common.m
//  common
//
//  Created by Zhang Yuanqing on 12-6-14.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"

void SafePerformSelectorOnMainThread(id obj, SEL sel, id arg, BOOL wait)
{
	if (obj && sel && [obj respondsToSelector:sel])
    {
        [obj performSelectorOnMainThread:sel withObject:arg waitUntilDone:wait];
    }
}

