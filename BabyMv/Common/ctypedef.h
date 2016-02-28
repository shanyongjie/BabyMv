/*
 *  ctypedef.h
 *  KuwoTingting
 *
 *  Created by YeeLion on 11-3-1.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */
//#include <tchar.h>

#ifndef __C_TYPE_DEFINE_H__
#define __C_TYPE_DEFINE_H__

#if (defined _UNICODE) || (defined UNICODE)
typedef wchar_t TCHAR;
#define TEXT(s) L##s
#else
typedef char TCHAR;
#define TEXT(s) s
#endif

typedef TCHAR *PTSTR, *LPTSTR;
typedef const TCHAR *PCTSTR, *LPCTSTR;

#endif // __C_TYPE_DEFINE_H__