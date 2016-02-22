//
//  globalm.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-10.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include <stdio.h>
#ifdef __OBJC__
#import <Foundation/Foundation.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif
	
#define MAX_PATH            255
#define MAX_PATH_CAPACITY   (MAX_PATH + 1)
    
unsigned int get_file_size(FILE* fp);
    
#ifdef __OBJC__
    BOOL CreateDirectory(NSString *dir);
	
    BOOL IsValidFilePath(NSString* path, BOOL* isDir);
    BOOL IsFileExists(NSString* path, BOOL isDir);
    BOOL CopyFile(NSString *srcPath, NSString *dstPath);
    BOOL MoveFile(NSString *srcPath, NSString *dstPath);
    BOOL DeleteFile(NSString* path);
    
    UInt32 GetFileSize(NSString* file);
    NSDate* GetFileModificationDate(NSString* path, BOOL isDir);
    BOOL SetFileModificationDate(NSDate* date, NSString* path, BOOL isDir);

    // return serialed filename
    NSString* SerialNSFilename(NSString* strDir, NSString* strFilename);

#endif

    const char* GetFilePath(const char* lpszFilePath, char szPath[MAX_PATH_CAPACITY]);
    const char* GetFilename(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY]);
    const char* GetFilenameEx(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY]);
    const char* GetFileExtension(const char* lpszFilePath, char szFileExtension[MAX_PATH_CAPACITY]);
	    
    /*
     BOOL ClearDirectory(const char* lpszDir);
     BOOL DeleteDirectory(const char* lpszDir);
     
     // 创建路径，包括所有父级目录
     BOOL CreatePath(const char* lpszPathName);
     
     BOOL CreatePathRelative(const char* lpszPathName, char* lpszFullPath);
     
     // 判断目录是否存在
     BOOL DirectoryExists(const char* lpszDirName);
     // 判断文件是否存在
     BOOL FileExists(const char* lpszFileName);
     
     size_t GetFileSize(const char* lpszFilePath);
     
     // 根据文件是否存在，并将文件名序列化。若文件已存在，则在文件名后添加数字，如 filename.ext 修改为 filename(1).ext
     BOOL SerialFilename(OUT const char* strDir, IN OUT char* strFilename);
     */
    

#ifdef __cplusplus
}
#endif

