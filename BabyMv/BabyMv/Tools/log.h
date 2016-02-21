#ifndef _LOG_H__
#define _LOG_H__

#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif  // __OBJC__
#import <TargetConditionals.h>

#include "logger.h"

#define LOGLEVEL_INFO     5
#define LOGLEVEL_WARNING  3
#define LOGLEVEL_ERROR    1

#define MAXLOGLEVEL     LOGLEVEL_INFO

#ifdef __OBJC__
    #ifdef __cplusplus
    extern "C"{
    #endif
        void PrintHexData(NSData* data);
    #ifdef __cplusplus
    }
    #endif
#endif // __OBJC__


#ifdef DEBUG
    #define LOG(xx, ...)  do { NSLog(@"%s(%d): \n\n" xx "\n", __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__); } while (0)
#else
    #define LOG(xx, ...)  ((void)0)
#endif // #ifdef DEBUG

#ifdef DEBUG
    #define LOG_IF(condition, xx, ...)   \
        do { if ((condition)) { \
                MY_LOG(xx, ##__VA_ARGS__); \
            } \
        } while (0)
#else
    #define NSLOGIF(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG


#define LOG_METHOD() LOG(@"%s", __PRETTY_FUNCTION__)

#if LOGLEVEL_ERROR <= MAXLOGLEVEL
    #define LOG_ERROR(xx, ...)  LOG(@"ERROR: " ##xx, ##__VA_ARGS__)
#else
    #define LOG_ERROR(xx, ...)  ((void)0)
#endif // #if LOGLEVEL_ERROR <= MAXLOGLEVEL

#if LOGLEVEL_WARNING <= MAXLOGLEVEL
    #define LOG_WARNING(xx, ...)  LOG(@"WARNING: " ##xx, ##__VA_ARGS__)
#else
    #define LOG_WARNING(xx, ...)  ((void)0)
#endif // #if LOGLEVEL_WARNING <= MAXLOGLEVEL

#if LOGLEVEL_INFO <= MAXLOGLEVEL
    #define LOG_INFO(xx, ...)  LOG(@"INFO: " ##xx, ##__VA_ARGS__)
#else
    #define LOG_INFO(xx, ...)  ((void)0)
#endif // #if LOGLEVEL_INFO <= MAXLOGLEVEL

#endif // _LOG_H__
