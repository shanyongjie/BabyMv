#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <sys/time.h>
#include "misc.h"
#include "logger.h"
#include "utility.h"

#pragma warning(disable:4706)

//#define LINE_CHARS           80

//#if (defined _DEBUG) || (defined DEBUG)
#define LOG_TRACE_OUTPUT
//#endif

//#define AUTO_LINE_BREAK

#ifdef WIN32
#include <windows.h>
typedef CRITICAL_SECTION LOCK_STRUCT;
#define InitLock(lock)  InitializeCriticalSection(&(lock))
#define Lock(lock)      EnterCriticalSection(&(lock))
#define Unlock(lock)    LeaveCriticalSection(&(lock))
#else
#include <pthread.h>
typedef pthread_mutex_t LOCK_STRUCT;
#define InitLock(lock)  do {    \
                                pthread_mutexattr_t attr;  \
                                pthread_mutexattr_init(&attr);  \
                                pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);  \
                                pthread_mutex_init( &(lock), &attr ); \
                            } while (0)
#define Lock(lock)      pthread_mutex_lock(&(lock))
#define Unlock(lock)    pthread_mutex_unlock(&(lock))
#endif

static char g_szDbgLogFilename[256] = "";
static LOCK_STRUCT s_lock;
static int g_bCriticalInited = 0;

int _setdbglogfile(const char* file)
{
	if(!g_bCriticalInited)
	{
		g_bCriticalInited = 1;
		InitLock(s_lock);
	}

	if(!file)
		g_szDbgLogFilename[0] = 0;
	else
	{
		memset(g_szDbgLogFilename, 0, 256 * sizeof(char));
		strncpy(g_szDbgLogFilename, file, MIN(255, strlen(file)));
	}

	return 0;
}

int _dbglog(const char* lpszFormat, ...)
{
	va_list args;
	va_start(args, lpszFormat);
	int nRet = _dbglog_v(lpszFormat, args);
	va_end(args);
	return nRet;
}

int _dbglog_v(const char* lpszFormat, va_list argList)
{
    const int nAlloc = 1024;
    char buffer[nAlloc];
    int nLen;
	nLen = vsnprintf (buffer, nAlloc, lpszFormat, argList);
	assert( nLen <= nAlloc );
    buffer[nAlloc-1] = 0;
	return _dbglog_str(buffer);
}

int _dbglog2(const char* lpszFormat, ...)
{
	va_list args;
	va_start(args, lpszFormat);
	int nRet = _dbglog2_v(lpszFormat, args);
	va_end(args);
	return nRet;
}

int _dbglog2_v(const char* lpszFormat, va_list argList)
{
	//int nAlloc = vscprintf (lpszFormat, argList);
    int nAlloc = 10240;
    char* buffer = (char*)malloc(sizeof(char) * nAlloc);
	int nLen = vsnprintf( buffer, nAlloc, lpszFormat, argList );
	assert( nLen <= nAlloc );
    buffer[nAlloc-1] = 0;
	nLen = _dbglog_str(buffer);
    free(buffer);
    return nLen;
}

int _dbglog_str(const char* lpszString)
{
	Lock(s_lock);

	char szBuff[256];
	GetCurrentTimeString( szBuff, ARRAYSIZE(szBuff) );

	FILE* file = NULL;
	if( g_szDbgLogFilename[0] && 
		(file = fopen(g_szDbgLogFilename, "a+t")) )
	{
		fputs(szBuff, file);
		fputs(lpszString, file);
		fclose(file);
		file = NULL;
	}
#ifdef LOG_TRACE_OUTPUT
	TraceString(szBuff);
	/*const char* pStart = lpszString;
	const char* pEnd = pStart + strlen(lpszString);
	while( pStart < pEnd )
	{
		strncpy( szBuff, pStart, 255 );
		szBuff[255] = 0;
		OutputDebugString(szBuff);
		pStart += 255;
	}*/
#endif	// LOG_TRACE_OUTPUT

	Unlock(s_lock);
	return 0;
}

// 记录二进制数据
int _dbglog_binary( const void* lpBuff, int cbSize )
{
	if( !lpBuff || cbSize < 0 )
		cbSize = 0;

	char szBuff[128];
	int len = GetCurrentTimeString( szBuff, ARRAYSIZE(szBuff) );
	snprintf( szBuff + len, 128-len, "<BINARY DATA>(%d bytes)\r\n", cbSize );

	Lock(s_lock);

	FILE* file = NULL;
	if( g_szDbgLogFilename[0] && 
		(file = fopen(g_szDbgLogFilename, "a+b")) )
	{
		int len = strlen( szBuff );
		fwrite( szBuff, 1, len, file );

		if( cbSize > 0 )
			fwrite(lpBuff, 1, cbSize, file);

		fwrite( "\r\n", 1, 2, file );

		fclose(file);
		file = NULL;
	}
#ifdef LOG_TRACE_OUTPUT
	TraceString(szBuff);
#endif

	Unlock(s_lock);
	return 0;
}

int _dbglog_hex( const void* lpBuff, int cbSize )
{
	if( !lpBuff || cbSize < 0 )
		cbSize = 0;

	char szHexHeader[64];
	int len = snprintf( szHexHeader, 64, "<HEX DATA>(%d bytes)\n", cbSize );

	char* pszHex = (char*)malloc(sizeof(char)*(cbSize * 2 + len + 2));	// add header & add \n\0 space
	if( !pszHex )
		return -1;

	strcpy( pszHex, szHexHeader );
	char* pchDest = pszHex + len;
	const char* pchSrc = (const char*)lpBuff, *pchGuard = (const char*)lpBuff + cbSize;
	while( pchSrc < pchGuard )
	{
		*pchDest++ = hex_char_h(*pchSrc);
		*pchDest++ = hex_char_l(*pchSrc);
		++pchSrc;
	}
	*pchDest++ = '\n';
	*pchDest = '\0';

	int nRet = _dbglog_str( pszHex );
	free(pszHex);

	return nRet;
}


void OutputTraceString(const char* str)
{
    fprintf (stderr, "%s", str);
}

int SetLogFile(const char* lpszFile)
{
	_setdbglogfile( lpszFile );
	return 1;
}

int OutputLog(const char* lpszFormat, ...)
{		
	va_list args;
	va_start(args, lpszFormat);
	int ret = _dbglog2_v(lpszFormat, args);
	va_end(args);
	return ret;
}

int OutputLogBinary(const void* lpBuffer, int cbSize )
{
	return _dbglog_binary(lpBuffer, cbSize);
}

int OutputLogHex(const void* lpBuffer, int cbSize )
{
	return _dbglog_hex(lpBuffer, cbSize);
}

