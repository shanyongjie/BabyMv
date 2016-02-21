//
//  NSString+Util.m
//  KWPlayer
//
//  Created by Zhang Yuanqing on 12-7-5.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <iconv.h>
#import "NSString+Util.h"

NSString* SafeString(NSString* string)
{
    return string ? string : @"";
}

BOOL IsEmptyString(NSString* string)
{
    return /*nil == string ||*/ [string length] == 0;
}

// @encoding: GB2312, BIG5, UTF-8, etc. default UTF-8
NSString* ConvertBytesToUTF8String(const char* bytes, int length, const char* encoding, NSString* illegalPlaceHolder)
{
    if (!bytes || length <= 0)
        return nil;
    if (!encoding)
        encoding = "UTF-8";
    
    iconv_t icv = iconv_open(encoding, "UTF-8");
    if(icv == 0)
    {
        printf("can't initalize iconv routine!\n");
        return nil;
    }
    
    int nSize = (length + 1) * 3;
    char* pBuffer = (char*)malloc(nSize);
    if (!pBuffer)
    {
        iconv_close(icv);
        return nil;
    }
    
    //enable "illegal sequence discard and continue" feature, so that if met illeagal sequence,
    //conversion will continue instead of being terminated
    if ([illegalPlaceHolder length] == 0)
    {
        int argument = [illegalPlaceHolder length] == 0 ? 0 : 1;
        if (iconvctl(icv ,ICONV_SET_DISCARD_ILSEQ, &argument) != 0)
        {
            printf("can't enable \"illegal sequence discard and continue\" feature!\n");
            iconv_close(icv);
            free(pBuffer);
            return nil;
        }
    }
    
    const char* pSrc = bytes;
    size_t nSrc = length;
    char* pDst = pBuffer;
    size_t nDst = nSize;
    
    while (nSrc > 0)
    {
        //perform conversion
        int nRet = iconv(icv, (char**)&pSrc, &nSrc, &pDst,&nDst);
        
        if(nRet == -1)
        {
            // include all case of errno: E2BIG, EILSEQ, EINVAL
            //     E2BIG: There is not sufficient room at *outbuf.
            //     EILSEQ: An invalid multibyte sequence has been encountered in the input.
            //     EINVAL: An incomplete multibyte sequence has been encountered in the input
            // move the left data to the head of szSrcBuf in other to link it with the next data block
            const char* token = illegalPlaceHolder.UTF8String;
            int len = strlen(token);
            memcpy(pDst, token, len);
            pDst += len;
            nDst -= len;
            pSrc++;
            nSrc--;
        }
    }
    
    iconv_close(icv);
    
    NSString* string = [[NSString alloc] initWithBytes:pBuffer length:nSize-nDst encoding:NSUTF8StringEncoding];
    free(pBuffer);
    
    return [string autorelease];
}

@implementation NSString (Util)

- (NSInteger) hexIntegerValue
{
    if ([self length] <= 2)
        return 0;

    NSInteger value = 0;
    const char* buff = [self UTF8String];
    if (!buff)
        return 0;

    sscanf(buff, "%x", &value);
    return value;
}

+ (NSString*)stringWithBytes:(const char*)bytes length:(int)length encoding:(const char*)encoding illegalPlaceHolder:(NSString*)illegalPlaceHolder
{
    NSString* string = [[[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding] autorelease];
    if (!string)
    {
        string = ConvertBytesToUTF8String(bytes, length, "utf-8", @"�");
    }
    return string;
}

@end
