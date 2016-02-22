/*
 *  misc.h
 *  KWPlayer
 *
 *  Created by YeeLion on 11-3-1.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#ifndef _KUWO_UTIL_H__
#define _KUWO_UTIL_H__

__BEGIN_DECLS

#define CHECK_POINTER(p)     NSCAssert( lpRect != NULL, @"Invalid pointer value!")

    
#define ROUND_UP(x, align) ({ __typeof__(x) __x = (x); __typeof__(align) __align = (align); (__x + (__align - 1)) & ~(__align-1); })
	
#define IsExp2(x) ({ __typeof__(x) __x = (x); !(__x & (__x - 1)); })
	
unsigned int ToExp2(unsigned int x);

#include "itoa.h"
//char* itoa(int value, char* str, int radix);
//char* ltoa (long int value, char* str, int radix);
//char* utoa (unsigned int value, char* str, int radix);
//char* ultoa (unsigned long int value, char* str, int radix);

inline char hex_char_h(char ch);
inline char hex_char_l(char ch);
    
char* strlwr(char* s);
char* strupr(char* s);

int stricmp(const char* str1, const char* str2);
	
int strnicmp(const char* str1, const char* str2, size_t len);

// copy string if src is shorter than size, include '\0'.
int strcpy_if(char* dest, const char* src, int size);

int IsWhitespace(char ch);
const char* SkipWhitespace(const char* str);
int WhitespaceLength(const char* str, int length);
const char* BackwordWhitespace(const char* endstr, int count);
	
char* TrimWhitespace(char* str);
char* TrimLeftWhitespace(char* str);
char* TrimRightWhitespace(char* str);
	
int IsNumber(char ch);
int NumericValue(char ch);

int IsHexNumber(char ch);
int HexNumericValue(char ch);
	
// size of szHex should be at least size * 2 + 1
char* GetHexString(char* szHex, const void* pbData, int size);

char* GetMd5HashString(char szHash[33], const char* pbData, int length);
char* GetMd5HashString16(char szHash[17], const char* pbData, int length);

__END_DECLS

#ifdef __cplusplus
#ifndef SAFE_DELETE
#   define SAFE_DELETE(p) do { delete (p); (p) = NULL; } while (0)
#endif
#endif


#endif  // _KUWO_UTIL_H__