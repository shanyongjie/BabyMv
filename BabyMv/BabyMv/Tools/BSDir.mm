//
//  BSDir.cpp
//  babysong
//
//  Created by 单永杰 on 14-7-1.
//  Copyright (c) 2014年 ShanYongjie. All rights reserved.
//

#include "BSDir.h"
#include "StringUtility.h"
#import <sys/xattr.h>
#import <UIKit/UIKit.h>

namespace Dir
{
    NSString * GetPath(Path_Type type)
    {
        NSString * strpath;
        switch (type) {
            case PATH_HOME:
                strpath = NSHomeDirectory();
                break;
            case PATH_APP:
                strpath = [[NSBundle mainBundle] resourcePath];
                break;
            case PATH_LIBRARY:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                strpath = [paths objectAtIndex:0];
            }
                break;
            case PATH_DUCUMENT:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [paths objectAtIndex:0];
            }
                break;
            case PATH_CASHE:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                strpath = [paths objectAtIndex:0];
            }
                break;
            case PATH_LOG:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Log"];
                std::string strlog = [strpath UTF8String];
                if(!MakeDir(strlog))
                {
                    strpath = nil;
                }
            }
                break;
            case PATH_LOCALMUSIC:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalMusic"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
                Dir::SkipBackupDirectory(strpath);
                
            }
                break;
            case PATH_LOCALGAME:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LocalGame"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
                Dir::SkipBackupDirectory(strpath);
                
            }
                break;
            case PATH_VIDEO_CACHE:{
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"VideoCache"];
                std::string strVideo = [strpath UTF8String];
                if(!MakeDir(strVideo))
                {
                    strpath = nil;
                }
                Dir::SkipBackupDirectory(strpath);
                
                break;
            }
            case PATH_DATABASE:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"database"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
                Dir::SkipBackupDirectory(strpath);
            }
                break;
            case PATH_LYRIC:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Lyric"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
                
                Dir::SkipBackupDirectory(strpath);
            }
                break;
            case PATH_BKIMAGE:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"BKResource"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
                Dir::SkipBackupDirectory(strpath);
            }
                break;
            case PATH_OPUS:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MyOpus"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
                
                Dir::SkipBackupDirectory(strpath);
            }
                break;
            case PATH_MYIMAGE:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"MyImage"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
            }
                break;
            case PATH_USER:
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                strpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"User"];
                std::string strLocal = [strpath UTF8String];
                if(!MakeDir(strLocal))
                {
                    strpath = nil;
                }
            }
                break;
            default:
                break;
        }
        return  strpath;
    }
    
    BOOL GetPath(Path_Type type, std::string &strPath)
    {
        std::string strResult;
        
        NSString * path = GetPath(type);
        if(path != nil)
            strResult = [path UTF8String];
        
        if(!strResult.empty())
            strPath = strResult;
        
        return !strResult.empty();
    }
    
    BOOL CopyDir(const std::string& strSrcPath,const std::string& strDstPath)
    {
        return CopyDir([NSString stringWithUTF8String:strSrcPath.c_str()], [NSString stringWithUTF8String:strDstPath.c_str()]);
    }
    
    BOOL CopyDir(NSString * srcPath,NSString *dstPath)
    {
        if (!srcPath || !dstPath || [srcPath length]==0 || [dstPath length]==0) {
            return FALSE;
        }
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        NSError * err;
        BOOL bret = false;
        NSArray *filearr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:srcPath error:&err];
        if(filearr != nil)
        {
            if(!IsExistFile(dstPath))
                MakeDir(dstPath);
            for(NSString * strname in filearr)
            {
                NSString *srcfilepath = [srcPath stringByAppendingPathComponent:strname];
                NSString * dstfilepath = [dstPath stringByAppendingPathComponent:strname];
                bret = [fileMgr copyItemAtPath:srcfilepath toPath:dstfilepath error:&err];
                if(!bret)
                    break;
            }
        }
        return bret;
    }
    
    
    UInt32 GetFileSize(NSString* file)
    {
        if (!file || [file length]==0) {
            return 0;
        }
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        BOOL isDirectory;
        if (![fileMgr fileExistsAtPath:file isDirectory:&isDirectory]
            || isDirectory)
            return 0;
        NSDictionary* attrs = [fileMgr attributesOfItemAtPath:file error:nil];
        if (!attrs)
            return 0;
        NSNumber* size = [attrs objectForKey:NSFileSize];
        if (!size)
            return 0;
        return [size intValue];
    }
    
    UInt32 GetFileSize(const std::string& strFile)
    {
        return GetFileSize([NSString stringWithUTF8String:strFile.c_str()]);
    }
    
    BOOL DeleteFile(const std::string& strFile)
    {
        return DeleteFile([NSString stringWithUTF8String:strFile.c_str()]);
    }
    
    BOOL IsExistFile(const std::string& strfile)
    {
        if (strfile.empty()) {
            return FALSE;
        }
        NSString *path = [[NSString alloc]initWithUTF8String:strfile.c_str()];
        BOOL bret = [[NSFileManager defaultManager] fileExistsAtPath:path];
        return bret;
        
    }
    
    BOOL IsExistFile(NSString *filepath)
    {
        if (!filepath || [filepath length]==0) {
            return FALSE;
        }
        return ([[NSFileManager defaultManager] fileExistsAtPath:filepath]);
    }
    
    BOOL MakeDir(const std::string& strDir)
    {
        if(strDir.empty())
            return FALSE;
        
        if((int)strDir.size() <= 1)
            return FALSE;
        
        if(IsExistFile(strDir))
            return TRUE;
        
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        return [fileMgr createDirectoryAtPath:[NSString stringWithUTF8String:strDir.c_str()] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    BOOL DeleteDir(const std::string& strDirPath)
    {
        return DeleteDir([NSString stringWithUTF8String:strDirPath.c_str()]);
    }
    
    BOOL MakeDir(NSString* strDir)
    {
        return MakeDir([strDir UTF8String]);
    }
    
    BOOL DeleteDir(NSString* strDirPath)
    {
        if (!strDirPath || [strDirPath length]==0) {
            return FALSE;
        }
        if (!IsExistFile(strDirPath)) {
            return TRUE;
        }
        NSError* err;
        return [[NSFileManager defaultManager] removeItemAtPath:strDirPath error:&err];
    }
    
    BOOL DeleteFile(NSString * filepath)
    {
        if (!filepath || [filepath length]==0) {
            return FALSE;
        }
        if (!IsExistFile(filepath)) {
            return TRUE;
        }
        NSError* err;
        return ([[NSFileManager defaultManager] removeItemAtPath:filepath error:&err]);
    }
    
    std::string GetFileName(const std::string& strFilePath)
    {
        size_t pos=strFilePath.rfind('/');
        if (pos==std::string::npos) {
            return strFilePath;
        }
        return strFilePath.substr(pos+1);
    }
    
    NSString* GetFileName(NSString* filepath)
    {
        if (!filepath || [filepath length]==0) {
            return nil;
        }
        return [filepath lastPathComponent];
    }
    
    NSString* GetFileNameWithoutExt(NSString* filepath)
    {
        if (!filepath || [filepath length]==0) {
            return nil;
        }
        return [filepath stringByDeletingPathExtension];
    }
    
    std::string GetFileNameWithoutExt(const std::string& strFile)
    {
        std::string str=GetFileName(strFile);
        size_t pos=str.rfind('.');
        if (pos==std::string::npos) {
            return str;
        }
        return str.substr(0,pos);
    }
    
    std::string GetFilePath(const std::string& strFileFullPathName)
    {
        size_t pos=strFileFullPathName.rfind('.');
        if (pos==std::string::npos) {
            return strFileFullPathName;
        }
        return strFileFullPathName.substr(0,pos);
    }
    
    std::string GetFileExt(const std::string& strFileFullPathName)
    {
        size_t pos=strFileFullPathName.rfind('.');
        if (pos==std::string::npos) {
            return "";
        }
        return strFileFullPathName.substr(pos+1);
    }
    
    NSString* GetFilePath(NSString* filefullpathname)
    {
        if (!filefullpathname || [filefullpathname length]==0) {
            return nil;
        }
        return [filefullpathname stringByDeletingLastPathComponent];
    }
    
    NSString* GetFileExt(NSString* filefullpathname)
    {
        if (!filefullpathname || [filefullpathname length]==0) {
            return nil;
        }
        return [filefullpathname pathExtension];
    }
    
    BOOL FindFiles(NSString* strDir,NSString* strExt,NSMutableArray* arrayFiles)
    {
        [arrayFiles removeAllObjects];
        if (!IsExistFile(strDir)) {
            return FALSE;
        }
        NSFileManager* pMgr=[NSFileManager defaultManager];
        NSArray* array=[pMgr contentsOfDirectoryAtPath:strDir error:nil];
        
        @autoreleasepool {
            int n(0);
            for (NSString* file in array) {
                if ([[file pathExtension] isEqualToString:strExt]) {
                    [arrayFiles addObject:[strDir stringByAppendingPathComponent:file]];
                    ++n;
                    if (n>30) {
                        n=0;
                    }
                }
            }
        }
        return [arrayFiles count];
    }
    
    BOOL FindFiles(const std::string& strDir,const std::string& strExt,std::vector<std::string>& vecFiles)
    {
        vecFiles.clear();
        NSMutableArray* array=[NSMutableArray array];
        if (!FindFiles([NSString stringWithUTF8String:strDir.c_str()], [NSString stringWithUTF8String:strExt.c_str()], array)) {
            return FALSE;
        }
        for (NSString* file in array) {
            vecFiles.push_back([file UTF8String]);
        }
        return TRUE;
    }
    
    int GetFileCount(const std::string & strDir)
    {
        NSString * strpath = [NSString stringWithUTF8String:strDir.c_str()];
        if (!IsExistFile(strpath)) {
            return 0;
        }
        NSFileManager* pMgr=[NSFileManager defaultManager];
        NSArray* array=[pMgr contentsOfDirectoryAtPath:strpath error:nil];
        return [array count];
    }
    BOOL MoveFile(const std::string& strSrc,const std::string& strDst)
    {
        if (strSrc.empty() || strDst.empty()) {
            return FALSE;
        }
        return MoveFile([NSString stringWithUTF8String:strSrc.c_str()], [NSString stringWithUTF8String:strDst.c_str()]);
    }
    BOOL MoveFile(NSString* strSrc,NSString* strDst)
    {
        if (!strSrc || !strDst || [strSrc length]==0 || [strDst length]==0) {
            return FALSE;
        }
        return [[NSFileManager defaultManager] moveItemAtPath:strSrc toPath:strDst error:nil];
    }
    
    bool SkipBackupDirectory(NSString* str_path){
        bool b_ret = false;
        
        NSURL* url = [NSURL fileURLWithPath:str_path];
        BOOL b_is_dir = NO;
        bool b_is_exist = [[NSFileManager defaultManager] fileExistsAtPath:str_path isDirectory:&b_is_dir];
        
        if (!b_is_exist) {
            return false;
        }
        
        NSString* str_os_version = [[UIDevice currentDevice] systemVersion];
        if (0 <= strcmp([str_os_version UTF8String], "5.1")) {
            b_ret = [url setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil];
        }else if (0 == strcmp([str_os_version UTF8String], "5.0.1")) {
            const char* str_file_path = [[url path] fileSystemRepresentation];
            const char* str_attr_name = "com.apple.MobileBackup";
            u_int8_t un_attr_value = 1;
            
            int n_result = setxattr(str_file_path, str_attr_name, &un_attr_value, sizeof(un_attr_value), 0, 0);
            b_ret = (0 == n_result);
        }
        
        return b_ret;
    }
}