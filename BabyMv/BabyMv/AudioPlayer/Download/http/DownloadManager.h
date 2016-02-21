//
//  DownloadManager.h
//  dowlandKW
//
//  Created by 刘 强 on 11-5-3.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//
#ifndef core_downloadmanager_h
#define core_downloadmanager_h
#include "coreCommDefine.h"
#include "ActiveObj.h"
#include <list>
#include <vector>
#import "BMDataModel.h"
#include <pthread.h>

#import "DownloadClient.h"
using namespace std;

class EnqueueDownloadParam{
public:
    EnqueueDownloadParam(){
        reqType = 0; 
        dldClient = 0;
        reqID = 0;
    }
    REQTYPE reqType;
    DownloadClient* dldClient;
    volatile uint reqID; 
};

class CacheFileItem{
public:
    CacheFileItem(){
        memset(this, 0, sizeof(*this));
    }
    CacheFileItem(const CacheFileItem& obj){
        memcpy(this, &obj, sizeof(*this));
    }

    char _cacheFileName[1024];
    time_t _lastAccessTime;
    UInt64 _rid;
};

class DownloadManager : public ActiveObj{
    //friend class Download4Client;
    friend class DownloadClient;
private:
    DownloadManager();
    ~DownloadManager();
    list<DownloadClient*> _downloadClients;
    CLock _lockDownloadClients;
    CLock _lockMgr;
    CLock _lockCache;
    
    //
    pthread_mutex_t _mtxCancel;  
    pthread_cond_t _condCancel;  
    //
    
    DownloadClient* findDownloadClients(uint downloadClientReqID);
    void addDownloadClient(DownloadClient* downloadClient);
    void removeDownloadClient(DownloadClient* downloadClient);
    void CheckSizeAndClearCache();
public:
    virtual void onThreadStart();//主动对象线程启动回调
    virtual void onRequest(void* reqParam);
    virtual void onThreadEnd();//主动对象线程结束回调
    static DownloadManager* Instance();
    string GetRawURL(uint reqID);
    string GetRealURL(uint reqID);
    string getClientFileName(uint reqID,bool finalName = false);//获取文件名称 true表示下载完成之后的最终文件名
    uint GetDownloadItemFileSize(uint reqID);//获取当前下载的文件大小
    uint GetDownloadItemProgress(uint reqID);//获取当前下载的进度
    //播放器请求，获取到未缓冲完成的歌曲后，需要马上获取当前长度和总长度
    uint GetCurentsize(uint reqID);
    uint GetConetLengthSize(uint reqID);
    string GetMusicFormat(uint reqID);
    UInt32 GetMusicBitRate(uint reqID);
    UInt64 GetMusicRid(uint reqID);
    string findCacheFileNameFromCache(UInt64 rid, bool& isComplete);//查找此rid是否已经在缓存中(new)
private:
    list<CacheFileItem> _cacheFileItems;
    NSMutableArray* _downloadArray;//下载中的（包括正在下载的和等待下载的）
    NSMutableArray* _downloadArrayFinish;//下载完成的
    void onAddRef(DownloadClient* client);
    void onReleaseRef(DownloadClient* client);
    void onGetRealSong(DownloadClient* client);
    void onPlayerRequest(DownloadClient* client);
    void onPlayerStop(DownloadClient* client);
    void onDownloadRequest(DownloadClient* client);
    void onDownloadStop(DownloadClient* client);
    void onDownloadCancel(DownloadClient* client);
    void onDownloadComplete(DownloadClient* client);//new
    
    //下载整个文件到缓存目录（播放器请求）
    void GetRemoteFileCache(BMDataModel* toneInfo, int* pDldSession, DownloadProgressCallback cb,
                                 DownloadStatusCallback dsc,DownloadResultCallback drc,void* userData,string format, string bitrate);
    
    //下载整个文件到下载（下载请求）
    void GetRemoteFileDownload(BMDataModel* tone_info, int* pDldSession, DownloadProgressCallback cb,
                                 DownloadStatusCallback dsc,DownloadResultCallback drc,void* userData,string formatStr, string bitrate, UInt64 rid);
    UInt64 GetDiskFreeSpace();
    string ScanDownloadFile(const char* key,bool& isFind);
    string ScanDownloadFileForNewVersion(const char* key, bool& isFind);//version>=1.2.0.0
    NSString* IsOldVersion(const char* rid,bool& isOld);
    void LoadAllCacheItems();
    void SaveAllCacheItems();
    void CheckCacheItems();
    void UpdateCacheItems(CacheFileItem cacheItem);
    CacheFileItem FindCacheItem(UInt64 rid,bool& isFind);
    void RemoveCacheItem(CacheFileItem cacheItem);
    //int CreateDir(const char *sPathName);
    //string MakeHashFileName(const char* path,const char* url, bool isCacheFile = true);//path and hash!
public:
	string GetDownloadFileItem(BMDataModel* tone_info, MediaFormat format, string bitrate, UInt64 rid, int* pDldSession, DownloadProgressCallback cb,
                                    DownloadStatusCallback dsc, DownloadResultCallback drc, void* userData);
    HANDLE GetDownloadItem(int session);//add ref
    void ReleaseDownloadItem(HANDLE item);//release ref
    BOOL CancelDownloadItemCache(int session);	// 停止下载项（对应在线播放)
    int AddDownloadItem(BMDataModel* tone_info, MediaFormat format, string bitrate, UInt64 rid,
                        const char* file, int progress, int total, string& fileFullName,
                        DownloadProgressCallback cb, DownloadStatusCallback dsc, DownloadResultCallback drc, void* userData);
    BOOL StopDownloadItem(int requestId);//完全停止，断网络数据
    BOOL CancelDownloadItem(int requestId);//在上面的基础上多一个删除文件
public:
    void DispatchQueue(DownloadClient* downloadClient, REQTYPE reqType);
    void ReleaseAllCacheItem();
};
#endif



