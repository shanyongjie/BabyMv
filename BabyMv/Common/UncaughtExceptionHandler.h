//
//  UncaughtExceptionHandler.h
//  RingtoneDuoduo
//
//  Created by mistyzyq on 13-3-17.
//  Copyright (c) 2013年 CRI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject
{
    BOOL dismissed;
}

//+ (void) setDefaultHandler;
//
//+ (NSUncaughtExceptionHandler*) getHandler;

@end

__BEGIN_DECLS

void InstallUncaughtExceptionHandler();

__END_DECLS
