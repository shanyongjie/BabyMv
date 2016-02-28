//
//  DownloadClient.m
//  KWPlayer
//
//  Created by vieri122 on 11-11-25.
//  Copyright (c) 2011年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include <algorithm>
#include <libkern/OSAtomic.h>
#import "DownloadClient.h"
#import "NSString+Util.h"
#import "AppConfigure.h"
#import "DownloadManager.h"

DownloadClient* DownloadClient::CreateDownloadClient(){
    return new DownloadClient();
}

DownloadClient::DownloadClient(){
    _isFirstFrame = true;
    _httpDownloadConnection = 0;
    _httpRealSong = 0;
    _fp = 0;
    _contentLength = 0;
    _reciveBytes = 0;
    _reqID = 0;
    _realSongData = [[NSMutableData alloc] initWithCapacity:1024];
    
    _downloadFileName = "";
    //_cheatURL = " ";
    //_base64URL = " ";
    _progressCB = 0;
    _statusCB = 0;
    _resultCB = 0;
    _userData = 0;
    
    _refCount = 1;
    _rid = 0;
    
    //_musicFormat = MusicUnknow;
    _isDownload = false;
    _isOldVersionDownload = false;
    
    _retryCount = 0;
    _retryFlag = FALSE;
    
    _rawURL = "";
    _realURL = "";
    
   _downloadStatus = DOWNLOADUNKNOWNSTATUS;
}

DownloadClient::~DownloadClient(){
    if (_fp) {
        fclose(_fp);
    }
    _toneInfo = nil;
    if (_httpDownloadConnection) {
        _httpDownloadConnection->Release();
    }
    if (_httpRealSong) {
        _httpRealSong->Release();
    }
    [_realSongData release];
    
}

int DownloadClient::AddRef(){
    return OSAtomicAdd32(1, &_refCount);
}

int DownloadClient::Release(){
    int refTemp = OSAtomicAdd32(-1,&_refCount);
//    assert(refTemp>=0);
    if (0 == refTemp) {
        delete this;
    }
    return refTemp;
}

int DownloadClient::GetRef(){
    return _refCount;
}

void DownloadClient::SendDownloadRequest(){
    char tmp[512] = {0};
    sprintf(tmp, "bytes=%u-",_reciveBytes);
    _downloadHttpParam.SetHeaderFieldValue("RANGE", tmp);
    if (_httpDownloadConnection) {
        _httpDownloadConnection->Release();
    }
    _httpDownloadConnection = HttpConnection::CreateHttpConnection(&_downloadHttpParam);
    _httpDownloadConnection->SetHttpConnectionCallBack(0, DownloadClient::DownloadHasBytesAvailableFun, DownloadClient::DownloadErrorOccurredFun, DownloadClient::DownloadEndEncounteredFun, this);
    _httpDownloadConnection->AsynSendRequest();
}

string DownloadClient::GetSongRealURL(){
    if(_downloadHttpParam.InitParam([_toneInfo.Url UTF8String], "GET")){
        _realURL = [_toneInfo.Url UTF8String];
        DownloadManager::Instance()->DispatchQueue(this, PLAYERREQUEST);//要求管理器来发送下载请求
    }
    
    return " ";
}

void DownloadClient::CancelDownload(){
    if (_httpDownloadConnection) {
         _httpDownloadConnection->CanCelRequest();   
    }if (_httpRealSong) {
        _httpRealSong->CanCelRequest();
    }
}

#pragma mark - Handle NetCallBack
void DownloadClient::HandelDownloadHasBytesAvailable(char* buf, int len, uint contentLength){
    bool isSuccess = false;
    bool isFileSizeNotEqual = false;
    DOWNLOADSTATUS dldErrorStatus = DOWNLOADUNKNOWNSTATUS;
    if (_isFirstFrame) {
        int retCode = _httpDownloadConnection ? _httpDownloadConnection->GetResponseStatusCode() : DOWNLOADFAILEDSTATUS;
        if ( retCode < 200 || retCode > 299 ) {
            //失败 服务器返回的http响应码不正确
            dldErrorStatus = DOWNLOADREQFILEDSTATUS;
            NSLog(@"服务器返回的http响应码不正确！code:%d",retCode);
            goto error;
        }
        
        _isFirstFrame = false;
        
        if (_reciveBytes == 0) {
            _contentLength = contentLength + _reciveBytes;
            if(!HandleWholeFirstFrame()){
                dldErrorStatus = DOWNLOADREQFILEDSTATUS;
                goto error;
            }
        }else{
            //ASSERT(contentLength == _contentLength - _reciveBytes);
            if((contentLength != _contentLength - _reciveBytes) || !HandlePartFirstFrame()){
                remove(_downloadFileName.c_str());
                isFileSizeNotEqual = true;
                dldErrorStatus = DOWNLOADREQFILEDSTATUS;
                goto error;
            }
        }
        if (!_isDownload) {
            UpdateCacheFileItem();//只有缓存的时候才更新cache文件
        }
        if (_reciveBytes == 0 ) {
            notifyDownloadStatus(DOWNLOADREQCOMPLETESTATUS);//请求成功
            notifyDownloadStatus(DOWNLOADINGSTATUS);//正在下载数据
        }//如果_reciveBytes大于0 在防盗链的时候就会通知 请求成功 和正在下载数据 不需要再在这里通知了

    }
    if(!HandleReciveData(buf, len)){
        dldErrorStatus = DOWNLOADFAILEDSTATUS;
        goto error;
    }else{
        isSuccess = true;
        _reciveBytes += len;
        upDateFileStep(_reciveBytes);
        notifyDownloadProgress(_reciveBytes, _contentLength);
    }
error:
    if (!isSuccess) {
        CancelDownload();
        //尝试连接重试
        if (GetRetryCount() > 0) {
            TryReconnect();
            return;
        }

        notifyDownloadStatus(dldErrorStatus);//下载失败 如果发生在此处一般是读写文件错误
        if(isFileSizeNotEqual){
            notifyDownloadResult(DLDFileRemoved);//通知结果
        }else{
            notifyDownloadResult(DLDWriteFileFailed);//通知结果
        }
        return;
    }
}

void DownloadClient::HandleDownloadEndEncountered(){
    if (_isFirstFrame) {
        //服务器没有发送任何数据过来就把连接从容关闭了（当失败处理）
        notifyDownloadStatus(DOWNLOADFAILEDSTATUS);//下载失败
        notifyDownloadResult(DLDReadError);
    }else{
        TruncateFile();
        notifyDownloadStatus(DOWNLOADCOMPLETESTATUS);//下载成功
        notifyDownloadResult(DLDOk);
    }
    if (_isDownload) {
        DownloadManager::Instance()->DispatchQueue(this, DOWNLOADCOMPLETE);
    }
}

void DownloadClient::HandleDownloadErrorOccurred(HttpConnectionRetCode errorNO){
//    assert(errorNO != 0);
    if (GetRetryCount() > 0) {
        this->TryReconnect();
        return;
    }
    
    NSLog(@"下载失败: 错误代码 %d",errorNO);
    notifyDownloadStatus(DOWNLOADFAILEDSTATUS);//下载失败
    DOWNLOADRESULT dldRet = DLDReadError;
    if (errorNO == HttpRetTimeOut) {
        dldRet = DLDTimeOut;
    }
    else if (errorNO == HttpRetNotNet) {
        dldRet = DLDNotNet;//没有网络
    }
    else if(errorNO == HttpRetNotFound){
        dldRet = DLDRequestSongFailed;//404
    }
    else if(errorNO == HttpRetNetError){
        if (_isFirstFrame == YES && _reciveBytes == 0) {
            dldRet = DLDResumeFialed;
        }else{
            dldRet = DLDOpenStreamError;
        }
    }
    else{
        dldRet = DLDReadError;
    }
    notifyDownloadResult(dldRet);//结果通知
    if (_isDownload) {
        DownloadManager::Instance()->DispatchQueue(this, DOWNLOADCOMPLETE);
    }
}

#pragma mark - Handle GetRealSong CallBack
void DownloadClient::HandelRealSongOpenCompleted(){
    notifyDownloadStatus(DOWNLOADREQTINGSTATUS);//正在请求下载
    if (_reciveBytes > 0) {
        notifyDownloadStatus(DOWNLOADREQCOMPLETESTATUS);//请求成功
        notifyDownloadStatus(DOWNLOADINGSTATUS);//正在下载数据
        //已经有部分内容，需要通知进度
        notifyDownloadProgress(_reciveBytes, _contentLength);
    }
}

void DownloadClient::HandelRealSongHasBytesAvailable(char* buf, int len, uint contentLength){
    [_realSongData appendBytes:buf length:len];
}

void DownloadClient::HandleRealSongErrorOccurred(HttpConnectionRetCode errorNO){
    NSLog(@"防盗链失败: 错误代码 %d",errorNO);
    if (_reciveBytes > 0) {
        notifyDownloadStatus(DOWNLOADFAILEDSTATUS);
    }else{
        notifyDownloadStatus(DOWNLOADREQFILEDSTATUS);
    }
    notifyDownloadResult(DLDGetRealSongFailed);
    if (_isDownload) {
        DownloadManager::Instance()->DispatchQueue(this, DOWNLOADCOMPLETE);
    }
}

void DownloadClient::HandleRealSongEndEncountered(){
    //防盗链请求完成 解析结果
    bool isSuccess = false;
    NSString* tmp = [[[NSString alloc] initWithData:_realSongData encoding:Encoding18030] autorelease];
    string realURL="";
    
    int retCode = _httpRealSong ? _httpRealSong->GetResponseStatusCode() : DOWNLOADFAILEDSTATUS;
    if ( retCode < 200 || retCode > 299 ) {
        //失败 服务器返回的http响应码不正确
        NSLog(@"防盗链返回的http响应码不正确！%d",retCode);
        goto error;
    }
    
    if(ParserSongRealURL([tmp cStringUsingEncoding:Encoding18030],realURL)){
        //解析成功 发送真正的下载请求
        //判断baseURL模式还是全路经模式
        if (realURL.find("http") == -1) {//baseUrl模式 
            //新版本应该不会在出现在此 ASSERT（false） 此处加上是为了防止服务器端发生杯具的事情
            //string baseURL = _cheatURL.substr(0, _cheatURL.find("/resource"));
            //realURL = baseURL +"/"+ realURL;
            //ASSERT(false);
            NSLog(@"防盗链服务器返回的格式不正确！");
            goto error;
        }
        if(_downloadHttpParam.InitParam(realURL.c_str(), "GET")){
            isSuccess = true;
            _realURL = realURL;
            DownloadManager::Instance()->DispatchQueue(this, PLAYERREQUEST);//要求管理器来发送下载请求
        }else{
            goto error;
        }
    }else{
        goto error;
    }
error://解析失败 需要删除此请求
    if (!isSuccess) { 
        if (_reciveBytes > 0) {
            notifyDownloadStatus(DOWNLOADFAILEDSTATUS);
        }else{
            notifyDownloadStatus(DOWNLOADREQFILEDSTATUS);   
        }
        notifyDownloadResult(DLDGetRealSongFailed);
        
        if (_isDownload) {
            DownloadManager::Instance()->DispatchQueue(this, DOWNLOADCOMPLETE);
        }
    }      
}

#pragma mark - interna function
void DownloadClient::TryReconnect(){
    SubRetryCount();
    _retryFlag = TRUE;
    //DownloadClient* download4Retry = new DownloadClient();
    //download4Retry->SetDownloadStatus(_downloadStatus);
    //download4Retry->_reqID = this->_reqID;
    if (_isDownload) {
        DownloadManager::Instance()->DispatchQueue(this, DOWNLOADCOMPLETE);//删除之前的请求
    }
    
    DownloadManager::Instance()->DispatchQueue(this, PLAYERREQUEST);//要求管理器来发送下载请求
    return;
}

BOOL DownloadClient::isRightStatus(DOWNLOADSTATUS status){
    /*
     DOWNLOADREQTINGSTATUS,  //请求下载
     DOWNLOADREQFILEDSTATUS, //请求失败
     DOWNLOADREQCOMPLETESTATUS,//请求成功
     DOWNLOADINGSTATUS,        //正在下载
     DOWNLOADCOMPLETESTATUS,   //下载成功
     DOWNLOADFAILEDSTATUS,     //下载失败
     */
    BOOL bRet = TRUE;
    if (!_retryFlag) {//不是重试 直接返回
        return bRet;
    }
//    assert(_retryFlag);
    DOWNLOADSTATUS oldStatus = _downloadStatus;
    //oldStatus status
    switch (oldStatus) {
        case DOWNLOADREQTINGSTATUS:{
            bRet = (status != DOWNLOADREQTINGSTATUS);
        }
            break;
        case DOWNLOADREQFILEDSTATUS:{
            bRet = !(status == DOWNLOADREQTINGSTATUS || status == DOWNLOADREQFILEDSTATUS);
        }
            break;
        case DOWNLOADREQCOMPLETESTATUS:{
            bRet = !(status == DOWNLOADREQTINGSTATUS || status == DOWNLOADREQFILEDSTATUS || status == DOWNLOADREQCOMPLETESTATUS);
        }
            ;break;
        case DOWNLOADINGSTATUS:{
            bRet = !(status == DOWNLOADREQTINGSTATUS || status == DOWNLOADREQFILEDSTATUS || status == DOWNLOADREQCOMPLETESTATUS || status == DOWNLOADINGSTATUS);
        }
            break;
        case DOWNLOADCOMPLETESTATUS:{
            bRet = TRUE;
        }
            break;
        case DOWNLOADFAILEDSTATUS:{
            bRet = TRUE;
        }
            break;
        default:
            break;
    }
    return bRet;
}

void DownloadClient::TruncateFile(){
    int pos = _downloadFileName.rfind("~");
    if (pos == -1) {
        return;
    }
    if (_reciveBytes != _contentLength) {//未完成
        return;
    }
    string strName = _downloadFileName.substr(0,pos);
    rename(_downloadFileName.c_str(), strName.c_str());
    truncate(strName.c_str(),_contentLength);
}

bool DownloadClient::ParserSongRealURL(string str,string& realURL){
//    NSLog(@"realSong:%s",str.c_str());
    //string str = "format=mp3\r\nbitrate=128\r\nurl=http://xxxx.mp3";
    // RingtoneDuoduo 防盗链格式：
    // 96000\tmp3\thttp://bcs.duapp.com/duoduo-ring/%2Ftmp%2Fring_mp396%2F%E6%B5%81%E8%A1%8C%E9%87%91%E6%9B%B2%2F_2488591.mp3?sign=MBO:CA2b99d05e588832a4a0b59baee3ddb4:0exb7gPyzREnAZViOeloqtSjIYI%3D
    string sections[3];
    string& bitrate = sections[0];
    string& format = sections[1];
    string& url = sections[2];
    char* tmp = (char*)alloca(std::max((int)str.length() + 1, 256));
    strcpy(tmp, str.c_str());
    try {
        const char* sep = "\t\r\n";
        char* lasts = tmp;
        int i = 0;
        for (char* section = strtok_r(tmp, sep, &lasts);
             section && i < 3;
             section = strtok_r(NULL, sep, &lasts))
        {
            sections[i++] = section;
        }

        if (url.empty() || format.empty() || bitrate.empty())
            return false;

        realURL = url;
        _serverFormat = format;
        _serverBitrate = bitrate;
        //bitrate = "0";
    } catch (...) {
        return false;
    }
    if (_reciveBytes>0 && (_cacheFormat != format || _cacheBitrate != bitrate)) {
        NSLog(@"断点续传，服务器返回的格式居然变了！杯具！");
//        ASSERT(false);
        remove(_downloadFileName.c_str());//删除原来的文件
        _reciveBytes = 0;//从头开始请求数据
        _contentLength = 0;
        _isOldVersionDownload = false;
        bool isFind = false;
        CacheFileItem cacheItem = DownloadManager::Instance()->FindCacheItem(_rid,isFind);
        if (isFind && !_isDownload) {//只有缓存在更新cache
            DownloadManager::Instance()->RemoveCacheItem(cacheItem);   
        }
        return FALSE;
    }
    
    //_musicFormat = musicFormat;

    sprintf(tmp, "%llu", _rid);
    string fileName = string(tmp) + "." + format + "." + bitrate + "~";
    if (_isDownload) {//下载
//        if (!_isOldVersionDownload) {//新版本 version >=1.2.0.0
            if (_reciveBytes == 0) {
                //只有新下载才生成文件名（续传不用在生成文件名）
                _downloadFileName = [[[AppConfigure sharedAppConfigure].ringtoneDownloadDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName.c_str()]] UTF8String];//cache/download
                //_downloadFileName = [[g_config->downloadMusicDirectoryOld stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName.c_str()]] UTF8String];//document/download
            }
//        }
//        else{//老版本的下载一定是续传 用存在的文件即可
//            //NSLog(@"老版本的下载一定是续传 用存在的文件即可 _reciveBytes>0 此处是为了容错 表示文件被非法删除了 reciveBytes:%d",_reciveBytes);
//        }
    }else{//缓冲
        if (_reciveBytes == 0) {
            //只有新缓存的才生成文件名（续传不用在生成文件名）
            _downloadFileName = [[[AppConfigure sharedAppConfigure].ringtoneCacheDirectory stringByAppendingPathComponent:[NSString stringWithUTF8String:fileName.c_str()]] UTF8String];
        }
    }
    //NSLog(@"%s",_downloadFileName.c_str());
    return true;
}

bool DownloadClient::MakeRealRequestStr(string& urlStr){
//    int pos = _cheatURL.find("/resource");
//    if (pos == -1) {
//        return false;
//    }
//    string pathURL = _cheatURL.substr(pos,_cheatURL.length());
//    string br="";
//    if(_formatAndBitrate.substr(0,1) == "1"){
//        br = "kmp3";
//    }
//    else if(_formatAndBitrate.substr(0,1) == "2"){
//        br = "kaac";
//    }
//    string tmp = _formatAndBitrate.substr(1,3);//048/032/128/320/000
//    if (tmp == "000") {
//        tmp = "128";
//    }
//    if (tmp.substr(0,1)=="0") {
//        tmp = tmp.substr(1,2);//去到第一个0 （48/32）
//    }
//    br = tmp+br;
//    NSLog(@"br:%s",br.c_str());
    /*
    switch (_musicFormat) {
        case MP3128:
            br = "128kmp3";break;
        case MP3192:
            br = "192kmp3";break;
        case MP3224:
            br = "224kmp3";break;
        case MP3320:
            br = "320kmp3";break;
        case AAC48:
            br = "48kaac"; break;
        default:
            br = "128kmp3"; break;
    }
     */
    
//    char ridTmp[32] = {0};
//    sprintf(ridTmp, "%llu",_rid);
//    char bufTmp[2048] = {0};
//    sprintf(bufTmp, "user=%s&devm=%s&uuid=%s&prod=%s&instsrc=%s&corp=%s&type=%s&rawurl=%s&br=%s&rid=%s&format=%s&source=%s",
//            USER_ID, DEVICE_MAC_ADDR, USER_UUID, KWPLAYER_CLIENT_VERSION_STRING,
//            KWPLAYER_INSTALL_SOURCE,"kuwo","convert_url",pathURL.c_str(),br.c_str(),ridTmp,"aac",KWPLAYER_INSTALL_SOURCE);
//    sprintf(bufTmp, "user=%s&devm=%s&uuid=%s&prod=%s&instsrc=%s&corp=%s&type=%s&br=%s&rid=%s&format=%s&source=%s",
//            USER_ID, DEVICE_MAC_ADDR, USER_UUID, KWPLAYER_CLIENT_VERSION_STRING,
//            KWPLAYER_INSTALL_SOURCE,"kuwo","convert_url",br.c_str(),ridTmp,"mp3|aac",KWPLAYER_INSTALL_SOURCE);
//    sprintf(bufTmp,
//            "type=%s&user=%s&prod=%s&isrc=%s&mac=%s&dev=%s"
//            "&rid=%llu&network=%s&fmt=mp3&br=%s&from=%s",
//            "geturlv1", USER_ID, APP_INSTALL_VERSION, APP_INSTALL_SOURCE, DEVICE_MAC_ADDR, DEVICE_TYPE,
//            _rid, NETWORK_NAME, _cacheBitrate.c_str(), "1");
//    sprintf(bufTmp,
//            "type=%s&user=%s&prod=%s&isrc=%s&mac=%s&dev=%s"
//            "&rid=%llu&network=%s&fmt=%s&br=%s&from=%s",
//            "geturlv1", USER_ID, APP_INSTALL_VERSION, APP_INSTALL_SOURCE, DEVICE_MAC_ADDR, DEVICE_TYPE,
//            _rid, NETWORK_NAME, _cacheFormat.c_str(), _cacheBitrate.c_str(), "1");
//    NSLog(@"CheatRequestURL: %s", (string(GetServiceURL(SERVICE_GET_SOURCE_URL).UTF8String) + urlStr).c_str());
//    //des + base64
//    NSString* query = EncodeQuery([NSString stringWithCString:bufTmp encoding:NSUTF8StringEncoding]);
//    if (!query) {
//        return false;
//    }
//    urlStr = string(GetServiceURL(SERVICE_GET_SOURCE_URL).UTF8String) + [query UTF8String];
    return true;
}

bool DownloadClient::HandleReciveData(char* buf, int len){
    int writeBytes = fwrite(buf, 1, len, _fp);
    fflush(_fp);
    if (0 == writeBytes) {
        if (!feof(_fp)) {
            return false;
        }
    }else if(writeBytes < 0){
        return false;
    }else{
//        assert(writeBytes == len);
    }
    return true;
}

bool DownloadClient::HandlePartFirstFrame(){
    if ((_fp = fopen(_downloadFileName.c_str(), "r+b")) == NULL) {
        return false;
    }
    //续传 文件里面已经有_reciveBytes的内容
    if(fseek(_fp, _reciveBytes, SEEK_SET) == EOF){
        return false;
    }
    return true;
}

bool DownloadClient::HandleWholeFirstFrame(){
    if ((_fp = fopen(_downloadFileName.c_str(), "w+b")) == NULL) {
        return false;
    }
    if (fseek(_fp, _contentLength + 8 - 1, SEEK_SET) == EOF) {
        //＋8是为了最后8个字节存储已接收大小和文件总大小（前四个字节）（其中文件总大小不包含此8字节）
        remove(_downloadFileName.c_str());
        return false;
    }
    if (fputc(0, _fp) == EOF) {
        return false;
    }
    fflush(_fp);
    
    long tel = ftell(_fp);//在重新读一次 确保正确
    if( tel != _contentLength + 8){
        remove(_downloadFileName.c_str());
        return false;
    }
    
    fseek(_fp, -8, SEEK_END);//把文件长度写入到文件后八个字节的前四个字节
    fwrite(&_contentLength, 1, 4, _fp);
    
    if(0 != fseek(_fp, 0, SEEK_SET)){//重置文件指针
        return false;
    }
    return true;
}

void DownloadClient::upDateFileStep(int recvBytes){
    long pos = ftell(_fp);
    fseek(_fp, -4, SEEK_END);//
    fwrite(&recvBytes, 1, 4, _fp);
    fseek(_fp, pos, SEEK_SET);//重置文件指针
    fflush(_fp);
}

void DownloadClient::UpdateCacheFileItem(){
    CacheFileItem cacheItem;
    //文件名带路径 带格式 但不带“～”
    strcpy(cacheItem._cacheFileName,(_downloadFileName.substr(0,_downloadFileName.rfind("~"))).c_str());
    cacheItem._lastAccessTime = time(0);
    cacheItem._rid = _rid;
    //cacheItem._musicFormat = _musicFormat;//
    /*
     MusicFormat _serverFormat;
     string _serverBitrate;
     */
    DownloadManager::Instance()->UpdateCacheItems(cacheItem);//update mem and cache.index
}

#pragma mark - property
string DownloadClient::GetFileName(bool finalName){
    if (finalName) {
        int pos = _downloadFileName.rfind("~");
        if (pos != -1) {
            string strName = _downloadFileName.substr(0,pos);
            return strName;
        }else{
            return _downloadFileName;
        }
    }else{
        return _downloadFileName;
    }
}

string DownloadClient::GetRawURL(){
    return _rawURL;
}

string DownloadClient::GetRealURL(){
    return _realURL;
}

int DownloadClient::GetRetryCount(){
    return _retryCount;
}

int DownloadClient::SetRetryCount(int retryCount){
    return _retryCount = retryCount;
}

int DownloadClient::AddRetryCount(){
    return ++_retryCount;
}

int DownloadClient::SubRetryCount(){
    --_retryCount;
    if (_retryCount < 0) {
        _retryCount = 0;
    }
    return _retryCount;
}

DOWNLOADSTATUS DownloadClient::GetDownloadStatus(){
    return _downloadStatus;
}

void DownloadClient::SetDownloadStatus(DOWNLOADSTATUS status){
    DOWNLOADSTATUS oldStatus = _downloadStatus;
    _downloadStatus = status;//new status
#if defined DEBUG || defined _DEBUG
    NSLog(@"oldDownloadStatus:%lu -> newDownloadStatus:%lu",oldStatus,_downloadStatus);
#endif
}

#pragma mark - notify
void DownloadClient::notifyDownloadProgress(int step, int total){
    if (_progressCB) {
        _progressCB(_reqID,step,total,_userData);
    }
}

void DownloadClient::notifyDownloadStatus(DOWNLOADSTATUS status){
    BOOL bRet = isRightStatus(status);
     SetDownloadStatus(status);
    if (_statusCB && bRet) {
        _statusCB(_reqID,status,_userData);
    }
}

void DownloadClient::notifyDownloadResult(int errorNO){
    if (_resultCB) {
        _resultCB(_reqID,errorNO,_userData);
    }
}

#pragma mark - static Download NetCallBack
void DownloadClient::DownloadHasBytesAvailableFun(char* buf, int len, uint contentLength,void* userData){
     ((DownloadClient*)userData)->HandelDownloadHasBytesAvailable(buf,len,contentLength);
}

void DownloadClient::DownloadEndEncounteredFun(void* userData){
    ((DownloadClient*)userData)->HandleDownloadEndEncountered();
}

void DownloadClient::DownloadErrorOccurredFun(HttpConnectionRetCode errorNO,void* userData){
     ((DownloadClient*)userData)->HandleDownloadErrorOccurred(errorNO);
}

#pragma mark -static RealSong NetCallBack
void DownloadClient::RealSongOpenCompletedFun(void* userData){
    ((DownloadClient*)userData)->HandelRealSongOpenCompleted();
}

void DownloadClient::RealSongHasBytesAvailableFun(char* buf, int len, uint contentLength,void* userData){
    ((DownloadClient*)userData)->HandelRealSongHasBytesAvailable(buf,len,contentLength);
}

void DownloadClient::RealSongErrorOccurredFun(HttpConnectionRetCode errorNO,void* userData){
    ((DownloadClient*)userData)->HandleRealSongErrorOccurred(errorNO);
}

void DownloadClient::RealSongEndEncounteredFun(void* userData){
    ((DownloadClient*)userData)->HandleRealSongEndEncountered();
}