//
//  Encoding.h
//  KwSing
//
//  Created by Zhai HaiPIng on 12-10-11.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef __KwSing__Encoding__
#define __KwSing__Encoding__

#include <string>
#import <Foundation/Foundation.h>

namespace Encoding {
    
    NSStringEncoding GetGbkEncoding();
    
    NSString* Gbk2Utf8(const char* szGbkStr);
    NSString* Utf82Gbk(const char* szUtf8Str);
    
    //url encode
    std::string UrlEncode(const std::string& strUrl);
    NSString*   UrlEncode(NSString* pStrUrl);
    
    std::string UrlDecode(const std::string& strUrl);
    NSString*   UrlDecode(NSString* pStrUrl);
    
    //url query encode
    std::string QueryEncode(const std::string& strUrl);
    NSString*   QueryEncode(NSString* pStrUrl);
    
}

#endif
