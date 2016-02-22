/*
 *  TimeHelper.mm
 *  KWPlayer
 *
 *  Created by YeeLion on 11-2-25.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <CommonCrypto/CommonDigest.h>
#include "utility.h"


int TimevalToString(const struct timeval* lptmv, char* buffer, int size)
{
    if (!lptmv || !buffer || size <= 0) {
        assert(0);
        return 0;
    }
    
    struct tm tms = *localtime(&lptmv->tv_sec);
	int length = snprintf(buffer, size-1, "[%04d-%02d-%02d %02d:%02d:%02d.%03d] ", tms.tm_year, tms.tm_mon+1, tms.tm_mday, tms.tm_hour, tms.tm_min, tms.tm_sec, lptmv->tv_usec);
	if (length > size-1) {
		length = size-1;
	}
    buffer[size-1] = 0;
    return length;
}

// GMT/UTC time interval, since 1970
int64_t GetCurrentTimeIntervalSince1970(void)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
 	int64_t interval = (int64_t)tv.tv_sec * 1000 + tv.tv_usec / 1000;
	return interval;

//    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
//    return (int64_t)(interval * 1000);
}

int GetCurrentTimeString(char* buffer, int size)
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return TimevalToString(&tv, buffer, size);
}

int64_t GetTimeElapsed(const struct timeval* lptmv1, struct timeval* lptmv2)
{
    uint64_t elapsed = 1000*(lptmv2->tv_sec - lptmv1->tv_sec);
	//elapsed += lptmv2->tv_usec - lptmv1->tv_usec;
	return elapsed;
    /*vieriplayer
	int64_t elapsed = 1000000 * (lptmv2->tv_sec - lptmv1->tv_sec);
	elapsed += lptmv2->tv_usec - lptmv1->tv_usec;
	return elapsed;
     */
}


// time: time in millisecond, upRound: round up or down if less than 1 second
// mm:ss
NSString* TimeToString(NSInteger time, BOOL upRound)
{
    NSMutableString* string = [NSMutableString stringWithCapacity:10];
    if (time < 0) {
        [string appendString:@"-"];
        time = -time;
    }
    if (upRound) {
        time += 999;
    }
    int tmp = time / 1000;
    int sec = tmp % 60;
    int min = tmp /= 60;
    [string appendFormat:@"%02d:%02d", min, sec];
    return string;
}

// HH:mm:ss
NSString* TimeToString2(NSInteger time, BOOL upRound) {
    NSMutableString* string = [NSMutableString stringWithCapacity:10];
    if (time < 00) {
        [string appendString:@"-"];
        time = -time;
    }
    if (upRound) {
        time += 999;
    }
    int tmp = time / 1000;
    int sec = tmp % 60;
    tmp /= 60;
    int min = tmp % 60;
    tmp /= 60;
    int hour = tmp;
    [string appendFormat:@"%d:%02d:%02d", hour, min, sec];
    return string;
}

// mm:ss.fff
NSString* TimeToStringEx(NSInteger time) {
    NSMutableString* string = [NSMutableString stringWithCapacity:10];
    if (time < 0) {
        [string appendString:@"-"];
        time = -time;
    }
    int msec = time % 1000;
    int tmp = time / 1000;
    int sec = tmp % 60;
    int min = tmp /= 60;
    [string appendFormat:@"%02d:%02d.%03d", min, sec, msec];
    return string;
}

// HH:mm:ss.fff
NSString* TimeToStringEx2(NSInteger time) {
    NSMutableString* string = [NSMutableString stringWithCapacity:10];
    if (time < 0) {
        [string appendString:@"-"];
        time = -time;
    }
    int msec = time % 1000;
    int tmp = time / 1000;
    int sec = tmp % 60;
    tmp /= 60;
    int min = tmp % 60;
    tmp /= 60;
    int hour = tmp;
    [string appendFormat:@"%d:%02d:%02d.%03d", hour, min, sec, msec];
    return string;
}

// yy-MM-dd HH:mm:ss
NSDate* CStringToDate(const char* szTime)
{
	if (szTime == nil || *szTime == 0)
		return nil;
    
	NSString* tmString = [NSString stringWithCString:szTime encoding:NSUTF8StringEncoding];
    
	return StringToDate(tmString);
}

NSDate* StringToDate(NSString* tmString)
{
	if (tmString == nil || [tmString length] == 0)
		return nil;
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:DATE_TIME_FORMAT];	
	NSDate* date = [dateFormatter dateFromString:tmString];
	[dateFormatter release];
	return date;
	
}

NSString* DateToString(NSDate* date)
{
    if (!date)
        return nil;

	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:DATE_TIME_FORMAT];
	NSString* tmString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return tmString;    
}

//const char* DateToCString(NSDate* date, char* szTime[64])
//{
//}

//time1-time2, by seconds
NSTimeInterval TimeDiff(NSDate* time1, NSDate* time2) {
	return [time1 timeIntervalSinceDate:time2];
}

//cur time string
NSString* GetCurTimeToString() {
	NSDate* date = [NSDate date];
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:DATE_TIME_FORMAT];
	NSString* tmString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	return tmString;
}
