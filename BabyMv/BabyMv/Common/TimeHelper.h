/*
 *  TimeHelper.h
 *  KWPlayer
 *
 *  Created by YeeLion on 11-2-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */
#include <stdlib.h>
#include <string.h>

#include "common.h"


#ifndef _KUWO_TIME_HELPER_H__
#define _KUWO_TIME_HELPER_H__

__BEGIN_DECLS

#define DATE_TIME_FORMAT (@"yyyy-MM-dd HH:mm:ss")


int TimevalToString(const struct timeval* lptmv, char* buffer, int size);

// GMT/UTC time interval, since 1970
int64_t GetCurrentTimeIntervalSince1970(void);

int GetCurrentTimeString(char* buffer, int size);

int64_t GetTimeElapsed(const struct timeval* lptmv1, struct timeval* lptmv2);

#ifdef __OBJC__
// time: time in millisecond, upRound: round up or down if less than 1 second
// mm:ss
NSString* TimeToString(NSInteger time, BOOL upRound);
// HH:mm:ss
NSString* TimeToString2(NSInteger time, BOOL upRound);

// mm:ss.fff
NSString* TimeToStringEx(NSInteger time);
// HH:mm:ss.fff
NSString* TimeToStringEx2(NSInteger time);

//yy-MM-dd HH:mm:ss
NSDate* CStringToDate(const char* szTime);
NSDate* StringToDate(NSString* tmString);
NSString* DateToString(NSDate* date);
//const char* DateToCString(NSDate* date, char* szTime[64]);

//time1-time2, by seconds
NSTimeInterval TimeDiff(NSDate* time1, NSDate* time2);

//cur time string
NSString* GetCurTimeToString();
#endif

__END_DECLS

#endif // _KUWO_TIME_HELPER_H__