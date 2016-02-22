//
//  Encoding.mm
//  KwSing
//
//  Created by Zhai HaiPIng on 12-10-11.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "Encoding.h"
#include "StringUtility.h"

namespace Encoding {
    NSStringEncoding GetGbkEncoding()
    {
        static NSStringEncoding sGbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        return sGbkEncoding;
    }
    
    NSString* Gbk2Utf8(const char* szGbkStr)
    {
        return [NSString stringWithCString:szGbkStr encoding:GetGbkEncoding()];
    }
    
    NSString* Utf82Gbk(const char* szUtf8Str)
    {
        return [NSString stringWithCString:szUtf8Str encoding:NSUTF8StringEncoding];
    }
    
    
    std::string UrlEncode(const std::string& strUrl)
    {
        return [UrlEncode([NSString stringWithUTF8String:strUrl.c_str()]) UTF8String];
    }
    
    NSString* UrlEncode(NSString* pStrUrl)
    {
        return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)pStrUrl, NULL, (CFStringRef)@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`", kCFStringEncodingUTF8));
    }
    
    std::string UrlDecode(const std::string& strUrl)
    {
        NSString* strDecode=UrlDecode([NSString stringWithUTF8String:strUrl.c_str()]);
        std::string strOut=[strDecode UTF8String];
        return strOut;
    }
    
    NSString* UrlDecode(NSString* pStrUrl)
    {
        NSString* outStr=(NSString*)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(CFStringRef)pStrUrl, CFSTR(""),kCFStringEncodingUTF8));
        return outStr;
    }
    
    std::string QueryEncode(const std::string& strUrl)
    {
        std::string strQuery(strUrl);
        std::string strPre;
        size_t pos=strUrl.find('?');
        if (pos!=std::string::npos) {
            strPre=strUrl.substr(0,pos+1);
            strQuery=strUrl.substr(pos+1);
        }
        std::map<std::string,std::string> mapKeyValue;
        StringUtility::TokenizeKeyValue(strQuery,mapKeyValue);
        std::string strEncodeQuery;
        for (std::map<std::string,std::string>::iterator ite=mapKeyValue.begin(); ite!=mapKeyValue.end(); ++ite) {
            if (ite!=mapKeyValue.begin()) {
                strEncodeQuery+="&";
            }
            strEncodeQuery+=ite->first;
            strEncodeQuery+="=";
            strEncodeQuery+=UrlEncode(ite->second);
        }
        return strPre+strEncodeQuery;
    }
    
    NSString* QueryEncode(NSString* pStrUrl)
    {
        return [NSString stringWithUTF8String:QueryEncode([pStrUrl UTF8String]).c_str()];
    }
}

