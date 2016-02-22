//
//  ImageMgr.h
//  KwSing
//
//  Created by Qian Hu on 12-7-9.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_StringUtility_h
#define KwSing_StringUtility_h

#include <vector>
#include <string>
#include <map>
#import <Foundation/Foundation.h>

namespace StringUtility
{
    //转换为小写字符
    std::string	Str2Lower(const std::string& str);
    
    //转换为大写字符
    std::string  Str2Upper(const std::string& str);
           
    //格式化字符串，这种内部申请释放临时空间、输出到标准输出来计算长度的，尽量不要在嵌套循环内部用
    std::string  Format(const char* szFmt, ...);
    
    //去掉字符串头部的空白字符包括 空格 制表符 换行符
    std::string  TrimStart(const std::string& str);
    
    //去掉字符串尾部的空白字符包括 空格 制表符 换行符
    std::string  TrimEnd(const std::string& str);
    
    //去掉字符串头部和尾部的空白字符包括 空格 制表符 换行符
    std::string  Trim(const std::string& str);
    
    //判断字符串是否以指定的字符串开始
    BOOL StartWith(const std::string& str, const std::string& startStr);
    
    //判断字符串是否以指定的字符串结束
    BOOL EndWith(const std::string& str, const std::string& endStr);
    
    //字符串以指定的字符拆分，delims里的每个独立的字符都是分隔符
    BOOL Tokenize(const std::string& str, const std::string& delims, std::vector<std::string>& tokens);
    
    //字符串以指定的字符拆分，delims做为完整的一个字符串分割符
    void TokenizeEx(const std::string& str, const std::string& delims, std::vector<std::string>& tokens);
    
    //拆分形如a=122&b=faf&c=23格式的字符串，itemDelimiters里的每个独立的字符都是分隔符
    void TokenizeKeyValue(const std::string& str
                          , std::map<std::string,std::string>& tokens
                          , const std::string& itemDelimiters=std::string("&")      //这个是字段分隔符，不允许在内容中出现
                          , const std::string& keyValueDelimiter=std::string("=")   //这个是key和value之间的分隔符，不允许在key中出现，但value中可以出现
                          , BOOL bUrlDecode =FALSE);
    
    //拆分形如a=122&b=faf&c=23格式的字符串，itemDelimiters做为完整的一个字符串分割符
    void TokenizeKeyValueEx(const std::string& str
                            , std::map<std::string,std::string>& tokens
                            , const std::string& itemDelimiter=std::string("&")
                            , const std::string& keyValueDelimiter=std::string("=")
                            , BOOL bUrlDecode=FALSE);
    
    //字符串替换
    std::string Replace(const std::string &str, const std::string& string_to_replace, const std::string& new_string);
    
    //检查是否有不符合文件名规则的字符
    BOOL IsValidPath(const std::string& str);
    
    //删除不符合文件名规则的字符
    void EraseInvalidChar(std::string& strIn);  
}



#endif
