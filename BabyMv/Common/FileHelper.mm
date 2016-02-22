//
//  globalm.mm
//  KWPlayer
//
//  Created by YeeLion on 11-1-10.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <sys/time.h>
#import "FileHelper.h"

unsigned int get_file_size(FILE* fp)
{
    long size = -1;
    if (fp)
    {
        long cursor = ftell(fp);
        if (0 == fseek(fp, 0, SEEK_END))
            size = ftell(fp);
        fseek(fp, cursor, SEEK_SET);
    }
    return size;
}


BOOL CreateDirectory(NSString *dir)
{
    BOOL isDirectory = FALSE;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
	if (![fileMgr fileExistsAtPath:dir isDirectory:&isDirectory])
    {
		return [fileMgr createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
	}
    return isDirectory;
}

BOOL IsValidFilePath(NSString* path, BOOL* isDir)
{
	BOOL isDirectory;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory])
		return FALSE;
    if (isDir) *isDir = isDirectory;
	return TRUE;
}

BOOL IsFileExists(NSString* path, BOOL isDir)
{
	BOOL isDirectory;
	if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory])
		return FALSE;
	return !isDir == !isDirectory;
}

BOOL CopyFile(NSString *srcPath, NSString *dstPath)
{
	BOOL isDirectory = FALSE;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
	if ([fileMgr fileExistsAtPath:srcPath isDirectory:&isDirectory])
    {
		return [fileMgr copyItemAtPath:srcPath toPath:dstPath error:NULL];
	}
    return FALSE;
}

BOOL MoveFile(NSString* srcPath, NSString* dstPath)
{
	BOOL isDirectory = FALSE;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
	if ([fileMgr fileExistsAtPath:srcPath isDirectory:&isDirectory])
    {
		return [fileMgr moveItemAtPath:srcPath toPath:dstPath error:NULL];
	}
    return FALSE;
}

BOOL DeleteFile(NSString* path)
{
	NSError* err;
	BOOL result = [[NSFileManager defaultManager] removeItemAtPath:path error:&err];
	return result;
}

UInt32 GetFileSize(NSString* file)
{
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

NSDate* GetFileModificationDate(NSString* path, BOOL isDir)
{
    if (!IsFileExists(path, isDir))
        return nil;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSDictionary* dictionary = [fileMgr attributesOfItemAtPath:path error:nil];
    if (dictionary == nil)
        return nil;
    NSDate* date = (NSDate*)[dictionary objectForKey:NSFileModificationDate];
    return date;
}

BOOL SetFileModificationDate(NSDate* date, NSString* path, BOOL isDir)
{
    if (!IsFileExists(path, isDir))
        return NO;
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    NSDictionary* dictionary = [NSDictionary dictionaryWithObject:date forKey:NSFileModificationDate];
    [fileMgr setAttributes:dictionary ofItemAtPath:path error:nil];
    return YES;
}

// return serialed filename
NSString* SerialNSFilename(NSString* strDir, NSString* strFilename)
{
    if (!strDir || !strFilename)
        return nil;
    
    NSString* strPath = [NSMutableString stringWithFormat:@"%@/%@", strDir, strFilename];
    if (IsValidFilePath(strPath, NULL))
    {
        // 切分文件名与扩展名
        NSString* strFile = [strFilename stringByDeletingPathExtension];
        NSString* strFileEx = [strFilename pathExtension];
        if (!strFileEx) strFileEx = @"";
        if ([strFileEx length] > 0) strFileEx = [NSString stringWithFormat:@".%@", strFileEx];
        
        for (int i = 1; ; i++) {
            strFilename = [NSString stringWithFormat:@"%@(%d)%@", strFile, i, strFileEx];
            strPath = [strDir stringByAppendingPathComponent:strFilename];
            if (!IsValidFilePath(strPath, NULL))
                break;
        }
    }
    
    return strFilename;
}

const char* GetFilePath(const char* lpszFilePath, char szPath[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;
    
    int len = p - lpszFilePath;
    if (len > MAX_PATH)
        len = MAX_PATH;
    
    strncpy(szPath, lpszFilePath, len);
    szPath[len] = 0;
    
    return szPath;
}

const char* GetFilename(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;
    
    p++;
    int len = MAX_PATH;
    const char* p2 = strrchr(p, '.');
    if (p2) {
        len = p2 - p;
        if (len > MAX_PATH) 
            len = MAX_PATH;
    }
    
    strncpy(szFilename, p, len);
    szFilename[len] = 0;
    
    return szFilename;
}

const char* GetFilenameEx(const char* lpszFilePath, char szFilename[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;
    
    ++p;
	int len = strlen(p);
	len = MIN(len, MAX_PATH);
    strncpy(szFilename, p, len);
    szFilename[len] = 0;
    
    return szFilename;
}

const char* GetFileExtension(const char* lpszFilePath, char szFileExtension[MAX_PATH_CAPACITY])
{
    if (!lpszFilePath)
        return NULL;
    
    const char* p = strrchr(lpszFilePath, '/');
    if (!p)
        return NULL;
    
    p++;
    const char* p2 = strrchr(p + 1, '.');
    if (!p2 || !*(++p2))
        return NULL;
    
	int len = strlen(p2);
	len = MIN(len, MAX_PATH);
    strncpy(szFileExtension, p2, len);
    szFileExtension[len] = 0;
    
    return szFileExtension;
}

/*
BOOL ClearDirectory(const char* lpszDir)
{
    if(!lpszDir)
        return FALSE;
    if(!_tcslen(lpszDir))
        return FALSE;

    TCHAR strFilename[MAX_PATH];
    _stprintf( strFilename, _T("%s\\*.*"), lpszDir );
    WIN32_FIND_DATA wfd;
    int count = 0;
    HANDLE hFind = FindFirstFile( strFilename, &wfd );
    if (INVALID_HANDLE_VALUE != hFind) {
        do {
            if(_tcscmp(wfd.cFileName, _T(".")) == 0 || _tcscmp(wfd.cFileName, _T("..")) == 0)
                continue;

            _stprintf( strFilename, _T("%s\\%s"), lpszDir, wfd.cFileName);
            if(wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                count += DeleteDirectory(strFilename);
            } else {
                if( ::DeleteFile( strFilename) )
                    ++count;
            }
        } while (FindNextFile(hFind, &wfd) != 0);
        FindClose(hFind);
    }
    return (BOOL)count;
}

BOOL DeleteDirectory(const wchar_t* pDir)
{
    if( pDir ) {
        int count = ClearDirectory(pDir);
        if( ::RemoveDirectory(pDir) )
            ++count;
        return count;
    }
    return FALSE;
}

// 创建路径，包括所有父级目录
BOOL CreatePath(const char* lpszPathName)
{
    ASSERT(lpszPathName);
    if(::CreateDirectory(lpszPathName, lpSecurityAttributes))
        return TRUE;

    DWORD err = GetLastError();
    if(ERROR_ALREADY_EXISTS == err)
        return TRUE;

    //if(ERROR_PATH_NOT_FOUND == err)
    TCHAR* pSlash = _tcsrchr(lpszPathName, _T('\\'));
    if(!pSlash || pSlash == lpszPathName)
        return FALSE;	// 顶级目录

    TCHAR lpParentPath[MAX_PATH];
    int len = pSlash - lpszPathName;
    _tcsncpy(lpParentPath, lpszPathName, len);

    if(lpParentPath[len - 1] == _T('\\'))	// 末尾是'\\', 跳过
        lpParentPath[len - 1] = _T('\0');
    else
        lpParentPath[len] = _T('\0');

    if(!CreatePath(lpParentPath, lpSecurityAttributes))
        return FALSE;

    return ::CreateDirectory(lpszPathName, lpSecurityAttributes);
}

BOOL CreatePathRelative(const char* lpszPathName, char* lpszFullPath)
{
    ASSERT(lpszPathName);
    TCHAR szPath[MAX_PATH] = { 0 };
    _sntprintf( szPath, MAX_PATH - 1, _T("%s\\%s"), ::GetModuleDirectory(), lpszPathName );
    if( !CreatePath( szPath, lpSecurityAttributes ) )
        return FALSE;
    if( lpszFullPath )
        _tcscpy( lpszFullPath, szPath );
    return TRUE;
}

// 判断目录是否存在
BOOL DirectoryExists(const char* lpszDirName)
{
    DWORD attr = ::GetFileAttributes( lpszDirName );
    return ( ( (DWORD)-1 != attr )
            && ( attr & FILE_ATTRIBUTE_DIRECTORY ) );
}

// 判断文件是否存在
BOOL FileExists(const char* lpszFileName)
{
    DWORD attr = ::GetFileAttributes( lpszFileName );
    return ( ( (DWORD)-1 != attr )
            && !( attr & FILE_ATTRIBUTE_DIRECTORY ) );
    //if(lpszFilename) {
    //	HANDLE				hFind;					// File handle
    //	WIN32_FIND_DATA		fd;						// The file structure description
    //	hFind = FindFirstFile(lpszFilename, &fd);
    //	if (INVALID_HANDLE_VALUE != hFind) {
    //		FindClose(hFind);
    //		return !(fd & FILE_ATTRIBUTE_DIRECTORY);
    //	}
    //}
    //return FALSE;
}

DWORD GetFileSize(const char* lpszFilePath)
{
    if(!lpszFilePath)
        return 0;
    DWORD dwSize = 0;
    HANDLE hFile = CreateFile(lpszFilePath, GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL );
    if(hFile != INVALID_HANDLE_VALUE) {
        dwSize = GetFileSize(hFile, NULL);
        CloseHandle(hFile);
    }
    return dwSize;
}

// 根据文件是否存在，并将文件名序列化。若文件已存在，则在文件名后添加数字，如 filename.ext 修改为 filename(1).ext
BOOL SerialFilename(OUT const char* strDir, IN OUT char* strFilename)
{
    if(!strDir || !strFilename)
        return FALSE;

    TCHAR strPath[MAX_PATH];
    _stprintf( strPath, _T("%s\\%s"), strDir, strFilename );
    if( !FileExists(strPath) )
        return TRUE;
    
    // 切分文件名与扩展名
    TCHAR strFile[64];
    TCHAR strFileEx[8] = {0};
    _tcscpy(strFile, strFilename);
    TCHAR* pDot = _tcschr(strFile, _T('.'));
    if(pDot) {
        _tcscpy(strFileEx, pDot);
        *pDot = _T('\0');
    }
    int i = 0;
    do {
        _stprintf( strPath, _T("%s\\%s(%d)%s"), strDir, strFile, ++i, strFileEx );
    } while( FileExists(strPath) );
    _stprintf( strFilename, _T("%s(%d)%s"), strFile, i, strFileEx );
    
    return TRUE;
}
*/
