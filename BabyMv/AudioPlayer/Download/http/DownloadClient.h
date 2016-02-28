//
//  DownloadClient.h
//  KWPlayer
//
//  Created by vieri122 on 11-11-25.
//  Copyright (c) 2011年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#ifndef core_downloadclient_h
#define core_downloadclient_h

#include "HttpConnection.h"
#import "BMDataModel.h"

class DownloadClient{
public:
    static DownloadClient* CreateDownloadClient();

private:
    bool _isFirstFrame;
    HttpConnection* _httpDownloadConnection;
    HttpConnection* _httpRealSong;
    FILE* _fp;
    NSMutableData* _realSongData;
    volatile int _refCount;
    //string _format;
    HttpParam _downloadHttpParam;
    string _rawURL;//发起防盗链请求（防盗链之前）的rul
    string _realURL;//歌曲资源的（防盗链之后）url
    
    //重试的次数 默认是0，表示不重试。（在线请求的时候需要重试）
    int _retryCount;
    BOOL _retryFlag;//重试标志，为TRUE表示是重试请求，不发送回调通知。
    DOWNLOADSTATUS _downloadStatus;//下载状态
    
private:
    DownloadClient();
    ~DownloadClient();
    
    inline void upDateFileStep(int contentLength);
    bool MakeRealRequestStr(string& urlStr);
    bool ParserSongRealURL(string str,string& realUrl);
    void UpdateCacheFileItem();
    
    static void DownloadHasBytesAvailableFun(char* buf, int len, uint contentLength,void* userData);
    static void DownloadErrorOccurredFun(HttpConnectionRetCode errorNO,void* userData);
    static void DownloadEndEncounteredFun(void* userData);
    
    static void RealSongOpenCompletedFun(void* userData);
    static void RealSongHasBytesAvailableFun(char* buf, int len, uint contentLength,void* userData);
    static void RealSongErrorOccurredFun(HttpConnectionRetCode errorNO,void* userData);
    static void RealSongEndEncounteredFun(void* userData);
    
    void HandelDownloadHasBytesAvailable(char* buf, int len, uint contentLength);
    void HandleDownloadErrorOccurred(HttpConnectionRetCode errorNO);
    void HandleDownloadEndEncountered();

    void HandelRealSongOpenCompleted();
    void HandelRealSongHasBytesAvailable(char* buf, int len, uint contentLength);
    void HandleRealSongErrorOccurred(HttpConnectionRetCode errorNO);
    void HandleRealSongEndEncountered();
    
    bool HandleWholeFirstFrame();
    bool HandlePartFirstFrame();
    bool HandleReciveData(char* buf, int len);
    
    void notifyDownloadProgress(int step, int total);
    void notifyDownloadStatus(DOWNLOADSTATUS status);
    void notifyDownloadResult(int errorNO);
    
    void TryReconnect();
    BOOL isRightStatus(DOWNLOADSTATUS status);
public://property    
    string _downloadFileName;
    volatile DownloadProgressCallback _progressCB;
    volatile DownloadStatusCallback _statusCB;
    volatile DownloadResultCallback _resultCB;
    volatile uint _reqID;
    //string _cheatURL;
    //string _base64URL;
    void* _userData;
    UInt64 _rid;
    BMDataModel* _toneInfo;
    bool _isDownload;
    uint _contentLength;
    uint _reciveBytes;
    string _serverFormat;
    string _serverBitrate;
    string _cacheFormat;//客户端生成的
    string _cacheBitrate;//客户端生成的
    bool _isOldVersionDownload;
public:
    int AddRef();
    int Release();
    int GetRef();
    
    string GetSongRealURL();
    void SendDownloadRequest();
    void CancelDownload();
    void TruncateFile();
    
    //property
    string GetFileName(bool finalName);
    string GetRawURL();//获取防盗链之前的url
    string GetRealURL();//获取防盗链之后的url
    int GetRetryCount();
    int SetRetryCount(int retryCount);
    int AddRetryCount();
    int SubRetryCount();
    DOWNLOADSTATUS GetDownloadStatus();
    void SetDownloadStatus(DOWNLOADSTATUS status);
};
#endif