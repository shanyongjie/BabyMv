/////////////////////////////////////////////////////////////////////
// log utility
// Kevin Hua, 2005/12/30
/////////////////////////////////////////////////////////////////////

#include <stdarg.h>

#ifndef _KUWO_LOGGER_H__
#define _KUWO_LOGGER_H__

//#ifdef __cpluplus
//extern "C" {
//#endif
__BEGIN_DECLS

//#if defined(_DEBUG) || defined(DEBUG)
#if ENABLE_LOG
#define SETDBGLOGFILE  _setdbglogfile
#define DBGLOG         _dbglog
#define DBGLOGSTRING   _dbglog_str
#define DBGLOGBINARY   _dbglog_binary
#define DBGLOGHEX      _dbglog_hex
#else
#define SETDBGLOGFILE  1 ? 0 : _setdbglogfile   
#define DBGLOG         1 ? 0 : _dbglog
#define DBGLOGSTRING   1 ? 0 : _dbglog_str
#define DBGLOGBINARY   1 ? 0 : _dbglog_binary
#define DBGLOGHEX      1 ? 0 : _dbglog_hex
#endif

int _setdbglogfile(const char* file);

// 注意：vsprintf限制格式化结果字符串最大长度为1024，_dbglog及_dbglog_v也受此限制
int _dbglog(const char* lpszFormat, ...);
int _dbglog_v(const char* lpszFormat, va_list argList);

// _dbglog2及_dbglog2_v无字符串长度限制
int _dbglog2(const char* lpszFormat, ...);
int _dbglog2_v(const char* lpszFormat, va_list argList);

// 无长度限制
int _dbglog_str(const char* lpszString);

// 记录二进制数据
int _dbglog_binary( const void* lpBuff, int cbSize );

// 将二进制数据记录为十六进制格式
int _dbglog_hex( const void* lpBuff, int cbSize );

extern void OutputTraceString(const char* str);
#define TraceString(str) OutputTraceString(str);

int SetLogFile(const char* lpszFile);

int OutputLog(const char* lpszFormat, ...);

int OutputLogBinary(const void* lpBuffer, int cbSize );

int OutputLogHex(const void* lpBuffer, int cbSize );


//#ifdef __cpluplus
//}
//#endif
__END_DECLS

#endif // _KUWO_LOGGER_H__