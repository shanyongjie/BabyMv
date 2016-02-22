//
//  DownloadManager.mm
//  dowlandKW
//
//  Created by 刘 强 on 11-5-3.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include "DownloadManager.h"
#include "bsbase64.h"
#include <sys/stat.h>
#include <sys/types.h>
#include <dirent.h>
#include <CommonCrypto/CommonDigest.h>
#include <sys/param.h>
#include <sys/mount.h>
#import "AppConfigure.h"
#import "BSDir.h"
//#import "CheckIfUseNetStat.h"
//#import "KuwoMessageBox.h"
//#import "KuwoLog.h"
//#import "KuwoConfig.h"

static volatile uint g_reqID = 1;

DownloadManager::DownloadManager(){
    pthread_mutex_init(&_mtxCancel,NULL);
    pthread_cond_init(&_condCancel, NULL);
    //_mtxCancel = PTHREAD_MUTEX_INITIALIZER;  
    //_condCancel = PTHREAD_COND_INITIALIZER;
}

DownloadManager::~DownloadManager(){

}

DownloadManager* DownloadManager::Instance(){
    static DownloadManager downLoadMgr;
    return &downLoadMgr;
}

void DownloadManager::onThreadStart(){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    LoadAllCacheItems();
    [pool release];
}

#pragma mark - 1128
void DownloadManager::DispatchQueue(DownloadClient* downloadClient, REQTYPE reqType){
    EnqueueDownloadParam* edp = new EnqueueDownloadParam;
    edp->reqType = reqType;
    edp->dldClient = downloadClient;
    edp->reqID = downloadClient->_reqID;
    this->dispatch(edp);
}
#pragma mark -

void DownloadManager::onRequest(void *reqParam){
    if(!reqParam)
        return;
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    EnqueueDownloadParam* ep = (EnqueueDownloadParam*)reqParam;
    DownloadClient* downloadClient = findDownloadClients(ep->reqID);
    if(!downloadClient){
        //NSLog(@"已经取消 reqID=%d reqType=%d",(int)ep->downloadclient, (int)ep->reqType);
        delete ep;
        ep = NULL;
        [pool release];
        return;
    }
    switch (ep->reqType) {
        case ADDREF:
            onAddRef(downloadClient);
            break;
        case RELEASEREF:
            onReleaseRef(downloadClient);
            break;
        case GETREALSONG:
            onGetRealSong(downloadClient);
            break;
        case PLAYERREQUEST:
            onPlayerRequest(downloadClient);
            break;
        case PLAYERSTOP:
            onPlayerStop(downloadClient);
            break;
        case DOWNLOADREQUEST:
            onDownloadRequest(downloadClient);
            break;
        case DOWNLOADSTOP:
            onDownloadStop(downloadClient);
            break;
        case DOWNLOADCANCEL:
            onDownloadCancel(downloadClient);
            break;
        case DOWNLOADCOMPLETE:
            onDownloadComplete(downloadClient);
            break;
        default:
            assert(false);
            break;
    }
    
    delete ep;
    ep = NULL;
    [pool release];
}

void DownloadManager::onThreadEnd(){
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    SaveAllCacheItems();
    ReleaseAllCacheItem();
    [pool release];
}

//添加下载项目（下载请求）
int DownloadManager::AddDownloadItem(BMDataModel* tone_info, MediaFormat format, string bitrate, UInt64 rid,
                                     const char* file, int progress, int total,  
                                     string& fileFullName, DownloadProgressCallback cb, DownloadStatusCallback dsc, DownloadResultCallback drc, 
                                     void* userData) {
    CAutoLock autoLock(_lockMgr);
    int ret0 = -1;
    /*
    if(![CheckIfUseNetStat check])//允许试用运营商网络？
        return -3;
    */
    //BOOL bRet = [CheckIfUseNetStat check];
    BOOL bRet = YES;
    if(!bRet){//允许试用运营商网络？
        //不允许（否）
        //g_config->SetAllowUseMobileNet(bRet);
        //[[NSNotificationCenter defaultCenter] postNotificationName:KWNotificationChangeUseMobileNet object:nil];//change for v126
        return -3;
    }
    else{
        //允许（是）
    }
    CheckSizeAndClearCache();
    GetRemoteFileDownload(tone_info,/*url,*/&ret0 ,cb, dsc, drc, userData, GetFormatString(format), bitrate, rid);
    return ret0;
}

//在线播放请求(播放器请求)
// 缓存优先，如果存在缓存文件，则format & bitrate参数被忽略
string DownloadManager::GetDownloadFileItem(BMDataModel* tone_info, MediaFormat format, string bitrate, UInt64 rid, int* pDldSession,
                                            DownloadProgressCallback cb, DownloadStatusCallback dsc, DownloadResultCallback drc, void* userData) {
    CAutoLock autoLock(_lockMgr);
    CheckSizeAndClearCache();

    bool isComplete = false;
    string fileName = "";
    //新版本中可以不用url了
    string formatStr = GetFormatString(format);
    if((fileName = findCacheFileNameFromCache(/*url,*/rid, isComplete)) != ""){
        if (isComplete) {
            if (pDldSession) {
                *pDldSession = 0;
            }
            return fileName;//找到已缓存完的文件,可以直接返回
        }
    }
    /*
    if(![CheckIfUseNetStat check]){//允许试用运营商网络？
        if (pDldSession) {
            *pDldSession = 0;
        }
        return "";
    }*/
    //BOOL bRet = [CheckIfUseNetStat check];
    BOOL bRet = YES;
    if(!bRet){//允许试用运营商网络？
        //不允许（否）
        if (pDldSession) {
            *pDldSession = 0;
        }
        //g_config->SetAllowUseMobileNet(bRet);
        //[[NSNotificationCenter defaultCenter] postNotificationName:KWNotificationChangeUseMobileNet object:nil];//change for v126
        return "";
    }
    else{
        //允许（是）
    }
    CheckSizeAndClearCache();
    GetRemoteFileCache(tone_info, pDldSession, cb, dsc, drc, userData, GetFormatString(format), bitrate);
    return "";
}

//取消在线播放请求(播放器请求)
BOOL DownloadManager::CancelDownloadItemCache(int session){
    //NSLog(@"Cancel(播放器请求) this = %0x", (int)session);
    pthread_mutex_lock(&_mtxCancel);
    EnqueueDownloadParam* param = new EnqueueDownloadParam;
    param->reqType = PLAYERSTOP;
    param->reqID = session;
    this->dispatch(param);
    pthread_cond_wait(&_condCancel, &_mtxCancel);
    pthread_mutex_unlock(&_mtxCancel);
    return true;
}

//增加引用计数(播放器请求)
HANDLE DownloadManager::GetDownloadItem(int session){
    //NSLog(@"AddRef(播放器请求) this = %0x", (int)session);
    EnqueueDownloadParam* param = new EnqueueDownloadParam;
    param->reqType = ADDREF;
    param->reqID = session;
    this->dispatch(param);
    return (HANDLE)session;
}

//减少引用计数最终删除(播放器请求)
void DownloadManager::ReleaseDownloadItem(HANDLE item){
    //NSLog(@"Release(播放器请求) this = %0x", (int)item);
    EnqueueDownloadParam* param = new EnqueueDownloadParam;
    param->reqType = RELEASEREF;
    param->reqID = (long)item;
    this->dispatch(param);
}

//完全停止，断网络数据
BOOL DownloadManager::StopDownloadItem(int requestId){
    pthread_mutex_lock(&_mtxCancel);
    EnqueueDownloadParam* param = new EnqueueDownloadParam;
    param->reqType = DOWNLOADSTOP;
    param->reqID = requestId;
    this->dispatch(param);
    pthread_cond_wait(&_condCancel, &_mtxCancel);
    pthread_mutex_unlock(&_mtxCancel);
    return true;
}

//在上面的基础上多一个删除文件
BOOL DownloadManager::CancelDownloadItem(int requestId){
    pthread_mutex_lock(&_mtxCancel);
    EnqueueDownloadParam* param = new EnqueueDownloadParam;
    param->reqType = DOWNLOADCANCEL;
    param->reqID = requestId;
    this->dispatch(param);
    pthread_cond_wait(&_condCancel, &_mtxCancel);
    pthread_mutex_unlock(&_mtxCancel);
    return true;
}

//下载整个文件（下载请求）
void DownloadManager::GetRemoteFileDownload(BMDataModel* tone_info, int *pDldSession, DownloadProgressCallback cb,
                                                 DownloadStatusCallback dsc, DownloadResultCallback drc, void *userData, string format, string bitrate, UInt64 rid){
     DownloadClient* client = DownloadClient::CreateDownloadClient();
    //char tempStr[1024]={0};
    //DecodeBase64URL(url,tempStr,1024);
    //client->_cheatURL = tempStr;
    client->_toneInfo = tone_info;
    client->_progressCB = cb;
    client->_statusCB = dsc;
    client->_resultCB = drc;
    //client->_musicFormat = format;//maybe change
    client->_rid = rid;
    client->_userData = userData;
    client->_reqID = g_reqID++;
    client->_isDownload = true;
    if (pDldSession) {
        *pDldSession = client->_reqID;
    }
    
    char tmp[64]={0};
    sprintf(tmp, "%llu",client->_rid);

    //全新的下载
    //client->_musicFormat = format;
    client->_cacheFormat = format;
    client->_cacheBitrate = bitrate;
    string fileName = string(tmp) + "."+client->_cacheFormat+"~";
    client->_downloadFileName = [[[AppConfigure sharedAppConfigure].ringtoneDownloadDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName.c_str()]] UTF8String];

    //NSLog(@"%s",client->_downloadFileName.c_str());
    addDownloadClient(client);
    return this->DispatchQueue(client, GETREALSONG);
}

//下载整个文件到缓存目录（播放器请求）
void DownloadManager::GetRemoteFileCache(BMDataModel* toneInfo, int *pDldSession, DownloadProgressCallback cb,
                                              DownloadStatusCallback dsc, DownloadResultCallback drc, void *userData, string format, string bitrate){
    DownloadClient* client = DownloadClient::CreateDownloadClient();
    //char tempStr[1024]={0};
    //DecodeBase64URL(url,tempStr,1024);
    //client->_cheatURL = tempStr;
    client->_toneInfo = [toneInfo retain];
    client->_progressCB = cb;
    client->_statusCB = dsc;
    client->_resultCB = drc;
    client->_userData = userData;
    client->_rid = [toneInfo.Rid intValue];
    //client->_musicFormat = format;
    client->_cacheFormat = format;
    client->_cacheBitrate = bitrate;
    client->SetRetryCount(1);
    
    char filename[128]={0};
    snprintf(filename, 127, "%llu~",client->_rid);
    client->_downloadFileName = [[Dir::GetPath(Dir::PATH_CASHE) stringByAppendingPathComponent:
                                  [NSString stringWithUTF8String:filename]] UTF8String];//此文件名有可能被修改
    
    client->_reqID = g_reqID++;
    if (pDldSession) {
        *pDldSession = client->_reqID;
    }
    addDownloadClient(client);
    this->DispatchQueue(client, GETREALSONG);
}

string DownloadManager::findCacheFileNameFromCache(UInt64 rid, bool& isComplete){
    string retStr = "";
    bool isFind = false;
    CacheFileItem cacheItem = FindCacheItem(rid,isFind);
    if (!isFind) {
        return retStr;
    }
    //format = cacheItem._musicFormat;
    retStr = cacheItem._cacheFileName;

    NSString* filename = [NSString stringWithFormat:@"%llu", cacheItem._rid];
    retStr = [Dir::GetPath(Dir::PATH_CASHE) stringByAppendingPathComponent:filename].UTF8String;

    if(access(retStr.c_str(), F_OK) == 0){
        isComplete = true;
        cacheItem._lastAccessTime = time(0);
        UpdateCacheItems(cacheItem);
    }else{
        isComplete = false;
        retStr += "~";
        if(access(retStr.c_str(), F_OK) != 0){
            //本地的音乐文件被非法删除了（因为缓存队列会被即时清除）
            NSLog(@"缓存文件被删除了ˆ_ˆ ");
            RemoveCacheItem(cacheItem);
        }
    }
    return retStr;
}

//请求处理@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
void DownloadManager::onAddRef(DownloadClient *client){
    client->AddRef();
}

void DownloadManager::onReleaseRef(DownloadClient *client){
    client->CancelDownload();
    client->Release();
    if (client->GetRef() == 1) {
        removeDownloadClient(client);//从列表中清除且删除对象
    }
}

void DownloadManager::onPlayerStop(DownloadClient *client){
    pthread_mutex_lock(&_mtxCancel);
    client->_progressCB = 0;
    client->_statusCB = 0;
    client->_resultCB = 0;
    pthread_cond_signal(&_condCancel);
    pthread_mutex_unlock(&_mtxCancel);
    client->CancelDownload();
    if(client->GetRef() == 1){
        removeDownloadClient(client);
    }
}

void DownloadManager::onGetRealSong(DownloadClient* client){
    CheckCacheItems();
    client->GetSongRealURL();
}

void DownloadManager::onPlayerRequest(DownloadClient *client){
    client->SendDownloadRequest();
}


void DownloadManager::onDownloadRequest(DownloadClient *client){
    client->SendDownloadRequest();
}

void DownloadManager::onDownloadStop(DownloadClient *client){
    pthread_mutex_lock(&_mtxCancel);
    client->_progressCB = 0;
    client->_statusCB = 0;
    client->_resultCB = 0;
    pthread_cond_signal(&_condCancel);
    pthread_mutex_unlock(&_mtxCancel);
    client->CancelDownload();
    removeDownloadClient(client);
}

void DownloadManager::onDownloadCancel(DownloadClient *client){//和stop相比 多了一个删除文件
    pthread_mutex_lock(&_mtxCancel);
    client->_progressCB = 0;
    client->_statusCB = 0;
    client->_resultCB = 0;
    pthread_cond_signal(&_condCancel);
    pthread_mutex_unlock(&_mtxCancel);
    client->CancelDownload();
    remove(client->_downloadFileName.c_str());
    removeDownloadClient(client);
}

void DownloadManager::onDownloadComplete(DownloadClient *client){
    removeDownloadClient(client);
}
//end请求处理@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

UInt64 DownloadManager::GetDiskFreeSpace(){
    struct statfs buf;
    UInt64 freeSpace = -1;
    //float totalspace1 = -1;
    //NSLog(@"directory:%@",NSHomeDirectory());
    if (statfs([NSHomeDirectory() UTF8String],&buf)>=0)
    {
        freeSpace = (UInt64)buf.f_bsize*buf.f_bfree;//可用磁盘
        //totalspace1 = (float)buf.f_bsize * buf.f_blocks;//总大小
        //NSLog(@"freeSpace=%llu",freeSpace);
    }
    return freeSpace;//可用字节
}

string DownloadManager::ScanDownloadFileForNewVersion(const char* key, bool& isFind){
    isFind = false;
    struct dirent* ent = NULL;
    
    //从downloadMusicDirectory找
    DIR* pDir = opendir([[AppConfigure sharedAppConfigure].ringtoneDownloadDirectory UTF8String]);
    if (!pDir) {
        return "";
    }
    while ( NULL != (ent=readdir(pDir)) ) {
        if (ent->d_type == 8) {
            string exsitFileName = ent->d_name;
            string keyTmp = exsitFileName.substr(0, exsitFileName.find(".")); 
            if (keyTmp == key) {
                isFind = true;
                return [[[AppConfigure sharedAppConfigure].ringtoneDownloadDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:exsitFileName.c_str()]] UTF8String];
            }
        }
    }
    closedir(pDir);
    return "";
}

string DownloadManager::ScanDownloadFile(const char* key, bool& isFind){//暂时未用到
    isFind = false;
    struct dirent* ent = NULL;
    
    //某一个老版本（1.1.0.6）和新版本(>1.2.0.0)用同一个目录(downloadMusicDirectory)，但1.1.0.6还是用url生成的文件名
    string retStr = ScanDownloadFileForNewVersion(key, isFind);
    if (isFind) {
        return retStr;
    }

    //downloadMusicDirectoryOld找老版本(<1.1.0.6)的下载文件 
    DIR* pDir1 = opendir([[AppConfigure sharedAppConfigure].ringtoneDownloadDirectory UTF8String]);
    if (!pDir1) {
        return "";
    }
    while ( NULL != (ent=readdir(pDir1)) ) {
        if (ent->d_type == 8) {
            string exsitFileName = ent->d_name;
            string keyTmp = exsitFileName.substr(0, exsitFileName.find(".")); 
            if (keyTmp == key) {
                isFind = true;
                return [[[AppConfigure sharedAppConfigure].ringtoneDownloadDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:exsitFileName.c_str()]] UTF8String];
            }
        }
    }
    closedir(pDir1);
    return "";
}

void DownloadManager::LoadAllCacheItems(){
    CAutoLock autoLock(_lockCache);
    FILE* fp = NULL;
    if((fp = fopen([[Dir::GetPath(Dir::PATH_CASHE) stringByAppendingPathComponent:@"cache.index"] UTF8String], "r+b")) == NULL){
        return;
    }
    CacheFileItem item0;
    int readBytes = fread(&(item0), 1, sizeof(CacheFileItem), fp);
    if (readBytes == sizeof(CacheFileItem)) {
        _cacheFileItems.push_back(item0);
    }
    
    while (!feof(fp)) {
        CacheFileItem item;
        readBytes = fread(&(item), 1, sizeof(CacheFileItem), fp);
        if (readBytes == sizeof(CacheFileItem)) {
            //排序
            list<CacheFileItem>::iterator itor = --_cacheFileItems.end();
            if( item._lastAccessTime > (*itor)._lastAccessTime ){
                _cacheFileItems.insert(itor, item);
            }else{
                _cacheFileItems.push_back(item);
            }
        }else{
            //读写失败 正好读到文件末尾再读取一次会到执行此 just mark nothing to do
        }
    }
    fclose(fp);

#if defined (DEBUG) || defined (_DEBUG)
//    NSLog(@"LoadCachefile and count= %lu",_cacheFileItems.size());
//    list<CacheFileItem>::iterator itor1;
//    for (itor1 = _cacheFileItems.begin(); itor1 != _cacheFileItems.end(); ++itor1) {
//        NSLog(@"rid:%llu  lastAccessTime:%s",(*itor1)._rid,ctime(&((*itor1)._lastAccessTime)));
//    }
#endif
}

void DownloadManager::CheckCacheItems(){
    CAutoLock autoLock(_lockCache);
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    if (_cacheFileItems.size() >= /*g_config->GetCacheFileCount()*/200 || GetDiskFreeSpace() < 1024*1024*200) {
        //检查缓存 超过200个按时间最早删除 或者系统硬盘快不够(小于200MB)时删除最早的
        list<CacheFileItem>::reverse_iterator ritor;
        int deleteCount = 3;
        //反向迭代
        for (ritor = _cacheFileItems.rbegin(); ritor != _cacheFileItems.rend(); /*ritor++*/) {
            string tempFileName = (*ritor)._cacheFileName;
            if(access(tempFileName.c_str(), 0) == 0)
                remove(tempFileName.c_str());
            else{
                remove((tempFileName+"~").c_str());
            }
            ritor = list<CacheFileItem>::reverse_iterator(_cacheFileItems.erase((++ritor).base()));//反向迭代删除
            NSLog(@"delete cache file %s size=%ld freespace=%llu",tempFileName.c_str(),_cacheFileItems.size(),GetDiskFreeSpace());
            if (--deleteCount == 0) {
                break;
            }
        }
    }
    [pool release];
}

void DownloadManager::SaveAllCacheItems(){
    CAutoLock autoLock(_lockCache);
    FILE* fp = NULL;
    if((fp = fopen([[Dir::GetPath(Dir::PATH_CASHE) stringByAppendingPathComponent:@"cache.index"] UTF8String], "w+b")) == NULL){
        return;
    }
    list<CacheFileItem>::iterator itor;
    for (itor = _cacheFileItems.begin(); itor != _cacheFileItems.end(); itor++) {
        fwrite(&(*itor), 1, sizeof(CacheFileItem), fp);
    }
    
#if (defined DEBUG) || (defined _DEBUG)
//    int itemCount = (int)_cacheFileItems.size();
//    fseek(fp, 0, SEEK_SET);
//    for (int i = 0; i<itemCount; i++) {
//        CacheFileItem item;
//        fread(&item, 1, sizeof(CacheFileItem), fp);
//        NSLog(@"fileName:%s     lastAccessTime:%s",item._cacheFileName, ctime(&(item._lastAccessTime)));
//    }
#endif
    fclose(fp);
}

void DownloadManager::UpdateCacheItems(CacheFileItem cacheItem){
    //update or add and update memory and cache.index
    CAutoLock autoLock(_lockCache);
    list<CacheFileItem>::iterator itor;
    for (itor = _cacheFileItems.begin(); itor != _cacheFileItems.end(); itor++) {
        if (cacheItem._rid == (*itor)._rid ) {
            _cacheFileItems.erase(itor);
            break;
        }
    }
    _cacheFileItems.insert(_cacheFileItems.begin(), cacheItem);//最新更新的放在最前面
    SaveAllCacheItems();//更新cache.index文件
}

void DownloadManager::RemoveCacheItem(CacheFileItem cacheItem){//删除某一项目
    CAutoLock autoLock(_lockCache);
    list<CacheFileItem>::iterator itor;
    for (itor = _cacheFileItems.begin(); itor != _cacheFileItems.end(); itor++) {
        if (cacheItem._rid == (*itor)._rid ) {
            _cacheFileItems.erase(itor);
            break;
        }
    }
    SaveAllCacheItems();//更新cache.index文件
}

CacheFileItem DownloadManager::FindCacheItem(UInt64 rid, bool& isFind){
    CAutoLock autoLock(_lockCache);
    isFind = false;
    CacheFileItem ret;
    list<CacheFileItem>::iterator itor;
    for (itor = _cacheFileItems.begin(); itor != _cacheFileItems.end(); itor++) {
        if (rid == (*itor)._rid ) {
            isFind = true;
            ret = *itor;
            break;
        }
    }
    return ret;
}

void DownloadManager::ReleaseAllCacheItem(){
    CAutoLock autoLock(_lockCache);
    _cacheFileItems.clear();
}

void DownloadManager::CheckSizeAndClearCache(){
    if(GetDiskFreeSpace() < 1024*1024*200){
//        BOOL bRet = [KuwoMessageBox msgBoxWithTitle:@"提示"
//                                                msg:@"设备空间不足，是否清除缓存?" 
//                                       leftBtnTitle:@"是" 
//                                     secondBtnTitle:@"否" 
//                                           sipState:NO];
        BOOL bRet = YES;
        if (bRet) {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            [[NSFileManager defaultManager] removeItemAtPath:Dir::GetPath(Dir::PATH_CASHE) error:nil];
            [[NSFileManager defaultManager] createDirectoryAtPath:Dir::GetPath(Dir::PATH_CASHE) withIntermediateDirectories:YES attributes:nil error:nil];
            [pool release];
        }
    }
}

string DownloadManager::GetRawURL(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if(!client){
        return "";
    }
    return client->GetRawURL();
}

string DownloadManager::GetRealURL(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if(!client){
        return "";
    }
    return client->GetRealURL(); 
}

string DownloadManager::getClientFileName(uint reqID,bool finalName/*=false*/){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if(!client){
        return "";
    }
    return client->GetFileName(finalName);
}

UInt32 DownloadManager::GetMusicBitRate(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if (!client) {
        return 0;
    }
    unsigned int br = 0;
    sscanf(client->_serverBitrate.c_str(), "%u",&br);
    return br;
}

string DownloadManager::GetMusicFormat(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if (!client) {
        return "";
    }
    return client->_serverFormat;
}

UInt64 DownloadManager::GetMusicRid(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if (!client) {
        return 0;
    }
    return client->_rid;
}

//播放器请求，获取到未缓冲完成的歌曲后，需要马上获取当前长度和总长度
uint DownloadManager::GetCurentsize(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if (!client) {
        return 0;
    }
    return client->_reciveBytes;
}

uint DownloadManager::GetConetLengthSize(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if (!client) {
        return 0;
    }
    return client->_contentLength;
}

uint DownloadManager::GetDownloadItemFileSize(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if (!client) {
        return 0;
    }
    return client->_contentLength;
}

uint DownloadManager::GetDownloadItemProgress(uint reqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = findDownloadClients(reqID);
    if(!client){
        return 0;
    }
    return client->_reciveBytes;
}

DownloadClient* DownloadManager::findDownloadClients(uint downloadClientReqID){
    CAutoLock autoLock(_lockDownloadClients);
    DownloadClient* client = 0;
    list<DownloadClient*>::iterator itor;
    for (itor = _downloadClients.begin(); itor != _downloadClients.end(); ++itor) {
        if ((uint)downloadClientReqID == (*itor)->_reqID) {
            client = *itor;
            break;
        }
    }
    return client;
}

void  DownloadManager::addDownloadClient(DownloadClient* downloadClient){
    CAutoLock autoLock(_lockDownloadClients);
    _downloadClients.push_back(downloadClient);
}

void DownloadManager::removeDownloadClient(DownloadClient* downloadClient){
    CAutoLock autoLock(_lockDownloadClients);
    list<DownloadClient*>::iterator itor;
    for (itor = _downloadClients.begin(); itor != _downloadClients.end(); ++itor) {
        if (downloadClient == *itor) {
            (*itor)->Release();
            _downloadClients.erase(itor);
            break;
        }
    }
}