//
//  coreComDefine.h
//  dowlandKW
//
//  Created by 刘 强 on 11-4-21.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#ifndef core_corecommdefine_h
#define core_corecommdefine_h

#import <Foundation/Foundation.h>

static long Encoding18030 = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);

typedef void* HANDLE;
enum {
    UNKNOWN = 0,        //默认状态（未知）
    REQUESTING,         //发起请求
    REQUESTCOMPLETE,    //请求成功
    REQUESTFAILED,      //请求失败
    READINGDATA,        //正在接收数据
    WRITINGDATA,        //正在发送数据
    READCOMPLETE,       //接收完成
    WRITECOMPLETE       //发送完成
};
typedef CFOptionFlags STATUS;

enum {
    DOWNLOADUNKNOWNSTATUS = 0, //默认状态（未知）
    DOWNLOADREQTINGSTATUS,  //请求下载
    DOWNLOADREQFILEDSTATUS, //请求失败
    DOWNLOADREQCOMPLETESTATUS,//请求成功
    DOWNLOADINGSTATUS,        //正在下载
    DOWNLOADCOMPLETESTATUS,   //下载成功
    DOWNLOADFAILEDSTATUS,     //下载失败
    DOWNLOADPAUSESTATUS,      //下载暂停（暂未使用）
    DOWNLOADRESUMESTATUS,     //下载恢复(继续下载 暂未使用)
    DOWNLOADGETREALLINKFAILED,//防盗链失败（result 暂未使用）
};
typedef CFOptionFlags DOWNLOADSTATUS;

enum{
    HTTPOK = 0,//成功
    HTTPCONFAILD = 6,//conn失败
    HTTPREADFAILD = 7,//raed失败
    HTTPNONETWORK = 8,//无网络可用
    HTTPNETRESOURECEFAILD = 404,//网络资源失败404
};
typedef CFOptionFlags HTTPERRORNO;

enum {
    REQUNkNOW = 0,
    REQUEST = 1,
    CANCEL,
    PAUSEDOWNLOAD,
    RESUMEDOWNLOAD,
    DESTROY,
    POSTDATA,
    POSTFILE,
    
    REQTEST,
    
    GETREALSONG,
    PLAYERREQUEST,
    PLAYERREQUESTPART,
    PLAYERSTOP,
    DOWNLOADREQUEST,
    DOWNLOADSTOP,
    DOWNLOADCANCEL,
    DOWNLOADCOMPLETE,
    DOWNLOADPAUSE,
    DOWNLOADRESUME,
    CACHECOMPLETEFORDLD,
    DATACOMPLETE,
    GETREALSONGFILED,
    DOWNLOADADDOBSERVER,
    PLAYERADDOBSERVER,
    ADDREF,
    RELEASEREF
};
typedef CFOptionFlags REQTYPE;

typedef enum{
    DLDOk = 0,//成功
    DLDOpenStreamError = 1,//打开流失败
    DLDResumeFialed = 2,//续传失败
    DLDReadError = 3,//读失败（recive 失败）
    DLDTimeOut = 4,//超时
    DLDWriteFileFailed = 5,//写文件失败
    DLDRequestSongFailed = 6,//请求歌曲时服务器返回失败（一般是404）
    DLDGetRealSongFailed = 7,//防盗链失败
    DLDNotNet = 8,//用户没有网络
    DLDFileRemoved = 9,//文件大小不一致，删除文件
}DOWNLOADRESULT;

typedef CFOptionFlags DISPATCHTYPE;

typedef void(*entireDataCallBackFun)(const char* buf, int bufLen, int contentLen,int type, void* userData);

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
typedef enum {
    NetRequestNotifyTypeStart = 1,//网络请求开始
    NetRequestNotifyTypeOK,//网络请求成功
    NetRequestNotifyTypeError,//网络请求失败
}NetRequestNotifyType;
typedef void (*DownloadProgressCallback)(int session, int step, int total, void* userData);//下载过程

typedef void (*DownloadStatusCallback)(int session, DOWNLOADSTATUS status, void* userData);//下载状态

typedef void (*DownloadResultCallback)(int session ,int errorNO, void* userData);//下载结果通知

typedef void (*NetRequestNotify)(int status, void* userData);//网络请求通知 1开始请求 2此次请求成功 3此次请求失败
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

typedef enum {
    HttpRetOK = 0,
    HttpRetCancel,
    HttpRetTimeOut,
    HttpRetNotNet,
    HttpRetSysError = 6,
    HttpRetNetError = 8,
    HttpRetNotFound=404,
}HttpConnectionRetCode;

typedef void (*HttpConnectionOpenCompleted)(void* userData);

typedef void (*HttpConnectionHasBytesAvailable)(char* buf, int len, uint contentLength,void* userData);

typedef void (*HttpConnectionErrorOccurred)(HttpConnectionRetCode errorNO,void* userData);

typedef void (*HttpConnectionEndEncountered)(void* userData);

//状态
typedef void(*StatusCBFun)(STATUS status, void* userData);//正在连接 连接完成 发起请求 请求成功 正在接收(发送) 接收(发送)完成 

//进度
typedef void(*ProgressCBFun)(const char* buf, int len, int contentLen, void* userData);

//结果
typedef void(*ResultCBFun)(int errorNO, void* userData);

//下载进度
typedef void (*DownloadProgressCBFun)(int currentLen, int contentLength, void* userData);

#endif
