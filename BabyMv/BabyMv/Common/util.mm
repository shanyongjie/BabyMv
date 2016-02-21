/*
 *  util.mm
 *  KWPlayer
 *
 *  Created by YeeLion on 11-3-1.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */

#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <CommonCrypto/CommonDigest.h>
#include "misc.h"
#include "util.h"


unsigned int ToExp2(unsigned int x)
{
	x=x-1;
	x= x|(x>>1);
	x= x|(x>>2);
	x= x|(x>>4);
	x= x|(x>>8);
	x= x|(x>>16);
	return x+1; 
}

static char szHexNums[] = { "0123456789abcdef" };

char hex_char_h(char ch)
{
    return szHexNums[(((unsigned char)ch) & 0xF0) >> 4];
}

char hex_char_l(char ch)
{
    return szHexNums[(((unsigned char)ch) & 0x0F) >> 0];
}

char* strlwr(char* s)
{
    char* p = s;
    while (*p != '\0') {
        if (isupper(*p)) {
            *p = tolower(*p);
        }
        ++p;
    }
    return s;
}

char* strupr(char* s)
{
    char* p = s;
    while (*p != '\0') {
        if (islower(*p)) {
            *p = toupper(*p);
        }
        ++p;
    }
    return s;
}

int stricmp(const char* str1, const char* str2)
{
	assert(str1 && str2);
	int ret = 0;
	char c1, c2;
	while (!ret) {
		c1 = *str1++;
		c2 = *str2++;
		if (!c1 || !c2)
			return (unsigned char)c1 - (unsigned char)c2;
		
		if (c1 >='A' && c1 <= 'Z')
			c1 += 'a' - 'A';
		if (c2 >='A' && c2 <= 'Z')
			c2 += 'a' - 'A';
		ret = (unsigned char)c1 - (unsigned char)c2;
	}
	return ret;
}

int strnicmp(const char* str1, const char* str2, size_t len)
{
	assert(str1 && str2);
	int ret = 0;
	size_t count = 0;
	char c1, c2;
	while (count < len && !ret) {
		c1 = *str1++;
		c2 = *str2++;
		if (!c1 || !c2)
			return (unsigned char)c1 - (unsigned char)c2;
		
		if (c1 >='A' && c1 <= 'Z')
			c1 += 'a' - 'A';
		if (c2 >='A' && c2 <= 'Z')
			c2 += 'a' - 'A';
		ret = (unsigned char)c1 - (unsigned char)c2;
		++count;
	}
	return ret;	
}

// copy string if src is shorter than size, include '\0'.
int strcpy_if(char* dest, const char* src, int size)
{
	assert(NULL != dest && NULL != src && size > 0);
	int count = 0;
	while (count < size)
	{
		if (!(*dest++ = *src++))
			return count;
		++count;
	}
	return -1;
}

int IsWhitespace(char ch)
{
	return (ch == ' ' || ch == '\t');
}

const char* SkipWhitespace(const char* str)
{
	assert (str != NULL);
	while (IsWhitespace(*str))
		++str;
	return str;
}

int WhitespaceLength(const char* str, int length)
{
	assert (str != NULL);
	int count = 0;
	if (length >= 0)
	{
		while (count < length
			   && IsWhitespace(*str))
			++count;
	}
	return count;
}

const char* BackwordWhitespace(const char* endstr, int count)
{
	assert(endstr != NULL);
	int cnt = 0;
	while (cnt < count)
	{
		if (!IsWhitespace(*(--endstr)))
		{
			++endstr;
			break;
		}
	}
	return endstr;
}

char* TrimWhitespace(char* str);
char* TrimLeftWhitespace(char* str);
char* TrimRightWhitespace(char* str);


int IsNumber(char ch)
{
	return ch >= '0' && ch <= '9';
}

int NumericValue(char ch)
{
	if (ch >= '0' && ch <= '9')
		return ch - '0';
	return -1;
}

int IsHexNumber(char ch)
{
	return (ch >= '0' && ch <= '9') 
	|| (ch >= 'A' && ch <= 'F')
	|| (ch >= 'a' && ch <= 'f');
}

int HexNumericValue(char ch)
{
	if (ch >= '0' && ch <= '9')
		return ch - '0';
	else if (ch >= 'A' && ch <= 'F')
		return ch - 'A' + 10;
	else if (ch >= 'a' && ch <= 'f')
		return ch - 'a' + 10;
	return -1;
}


// size of szHex should be at least size * 2 + 1
char* GetHexString(char* szHex, const void* pbData, int size)
{
    assert(szHex != NULL && pbData != NULL);
    char* pchDest = szHex;
    const char* pchSrc = (const char*)pbData;
    const char* pchGuard = (const char*)pbData + size;
    while( pchSrc < pchGuard )
    {
        *pchDest++ = hex_char_h(*pchSrc);
        *pchDest++ = hex_char_l(*pchSrc);
        ++pchSrc;
    }
    //*pchDest++ ='\0';
    *pchDest = '\0';
    
    return szHex;
}

char* GetMd5HashString(char szHash[33], const char* pbData, int length)
{
    assert(szHash != NULL);
    if (!pbData)
        pbData = "";
    if (length < 0)
        length = strlen(pbData);
    unsigned char hash[16];
    CC_MD5(pbData, length, hash);
    return GetHexString(szHash, hash, 16);
}

char* GetMd5HashString16(char szHash[17], const char* pbData, int length)
{
    assert(szHash != NULL);
    if (!pbData)
        pbData = "";
    if (length < 0)
        length = strlen(pbData);
    unsigned char hash[16];
    CC_MD5(pbData, length, hash);
    return GetHexString(szHash, hash + 4, 8);
}
