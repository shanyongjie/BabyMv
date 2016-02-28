/*
 *  Notification.h
 *  KWPlayer
 *
 *  Created by mistyzyq on 11-5-27.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#ifndef _NOTIFICATION_H__
#define _NOTIFICATION_H__

#import <Foundation/Foundation.h>

extern NSString* kCNotificationServiceConfigure;
extern NSString* kCNotificationUpgrade;

extern NSString* kCNotificationNetworkStatusChanged;
extern NSString* kCNotificationMyNetworkStatusChanged;

extern NSString* kCNotificationPlayingItemChanged;

extern NSString* kCNotificationPlayStateChanged;
extern NSString* kCNotificationPlayItemStarted;
extern NSString* kCNotificationPlayItemFinished;
extern NSString* kCNotificationScheduleChanged;

extern NSString* kCNotificationPlaylistItemAdded;
extern NSString* kCNotificationPlaylistItemRemoved;
extern NSString* kCNotificationPlaylistItemCleared;

extern NSString* kCNotificationUIActivate;

extern NSString* kCNotificationAutoPlayNext;

extern NSString* kCNotificationDownloadAddTask;
extern NSString* kCNotificationDownloadDeleteTask;

extern NSString* kCNotificationDownloadTaskStart;
extern NSString* kCNotificationDownloadTaskFinish;
extern NSString* kCNotificationDownloadTaskFail;
extern NSString* kCNotificationDownloadTaskProgress;

extern NSString* kCNotificationBabyAgeChanged;

extern NSString* kCNotificationFavorChanged;

extern NSString* kCNotificationSongDelete;

extern NSString* kCNotificationHistoryDelete;

extern NSString* NOTI_QUIT_GAME;

extern NSString* kCNotificationBaiduAdArrayLoadFinish;
extern NSString* kCNotificationBaiduAdFinish;
extern NSString* kCNotificationBaiduAdLoadFinish;

extern NSString* kCNotificationDuoduoAdLoadFinish;

#endif
