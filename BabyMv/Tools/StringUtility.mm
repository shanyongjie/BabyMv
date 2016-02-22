//
//  ImageMgr.cpp
//  KwSing
//
//  Created by Qian Hu on 12-7-9.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.

#include <iostream>
#include "StringUtility.h"
#include <algorithm>
#include <stdio.h>
#include "Encoding.h"

namespace StringUtility
{
    using namespace std;

    std::string	Str2Lower(const std::string& str)
    {
        const char* pChar = str.c_str();
        std::string _lower;
        while (*pChar != '\0')
        {
            _lower.push_back(tolower(*pChar));
            pChar++;
        }

        return _lower;
    }

    std::string Str2Upper(const std::string& str)
    {
        const char* pChar = str.c_str();
        std::string _upper;
        while (*pChar != '\0')
        {
            _upper.push_back(toupper(*pChar));
            pChar++;
        }

        return _upper;
    }

    std::string  Format(const char* szFmt, ...)
    {
        va_list argList;
        va_start( argList, szFmt );
        
        NSString* fmt=[NSString stringWithUTF8String:szFmt];
        NSString* str=[[NSString alloc] initWithFormat:fmt arguments:argList];
        
        va_end( argList );

        return [str UTF8String];
    }

    BOOL Tokenize(const std::string& str, const std::string& delims, std::vector<std::string>& tokens)
    {
        tokens.clear();

        std::string::size_type last_pos,pos;	
        pos = last_pos = 0;	

        do{
            last_pos = pos;
            last_pos = str.find_first_not_of(delims,last_pos);
            if(last_pos == std::string::npos)
            {
                break;
            }
            pos = str.find_first_of(delims, last_pos);

            std::string token = str.substr(last_pos, pos-last_pos);
            tokens.push_back(token);
        }while(pos != std::string::npos);

        return TRUE;
    }

    void TokenizeEx(const std::string& str, const std::string& delims, std::vector<std::string>& tokens)
    {
        size_t	iStartPos = 0;
        size_t	iEndPos   = 0;
        size_t  nSplitLength = delims.length();
        while((iEndPos = str.find(delims,iStartPos)) != std::string::npos
              || iStartPos < (iEndPos = str.length()))
        {
            string strOneLine = str.substr(iStartPos,iEndPos-iStartPos);
            iStartPos = iEndPos + nSplitLength;
            if(!strOneLine.empty())
                tokens.push_back(strOneLine);
        }
    }
    
    BOOL __TokenKeyValue(const std::string& str,const std::string& strKeyValueDelimiter,std::string& strKey,std::string& strValue)
    {
        size_t posEqualSign=str.find(strKeyValueDelimiter);
        if (posEqualSign==std::string::npos) {
            return FALSE;
        }
        strKey=str.substr(0,posEqualSign);
        strValue=str.substr(posEqualSign+strKeyValueDelimiter.length());
        return !strKey.empty() && !strValue.empty();
    }
    
    void TokenizeKeyValue(const std::string& str
                          , std::map<std::string,std::string>& tokens
                          , const std::string& itemDelimiters/*=std::string("&")*/
                          , const std::string& keyValueDelimiter/*=std::string("=")*/
                          , BOOL bUrlDecode/*=FALSE*/)
    {
        tokens.clear();
        
        std::string::size_type last_pos,pos;
        pos = last_pos = 0;
        
        do{
            last_pos = pos;
            last_pos = str.find_first_not_of(itemDelimiters,last_pos);
            if(last_pos == std::string::npos)
            {
                break;
            }
            pos = str.find_first_of(itemDelimiters, last_pos);
            
            std::string strKey,strValue;
            if (__TokenKeyValue(str.substr(last_pos, pos-last_pos),keyValueDelimiter,strKey,strValue)) {
                tokens[strKey]=bUrlDecode?Encoding::UrlDecode(strValue):strValue;
            }
        }while(pos != std::string::npos);
    }
    
    void TokenizeKeyValueEx(const std::string& str
                            , std::map<std::string,std::string>& tokens
                            , const std::string& itemDelimiter/*=std::string("&")*/
                            , const std::string& keyValueDelimiter/*=std::string("=")*/
                            , BOOL bUrlDecode/*=FALSE*/)
    {
        size_t	iStartPos = 0;
        size_t	iEndPos   = 0;
        size_t  nSplitLength = itemDelimiter.length();
        while((iEndPos = str.find(itemDelimiter,iStartPos)) != std::string::npos
              || iStartPos < (iEndPos = str.length()))
        {
            string strOneLine = str.substr(iStartPos,iEndPos-iStartPos);
            iStartPos = iEndPos + nSplitLength;
            if(!strOneLine.empty()) {
                std::string strKey,strValue;
                if (__TokenKeyValue(strOneLine,keyValueDelimiter,strKey,strValue)) {
                    tokens[strKey]=bUrlDecode?Encoding::UrlDecode(strValue):strValue;
                }
            }
        }
    }

    std::string TrimStart(const std::string& str)
    {
        std::string strTemp(str);

        size_t pos = strTemp.find_first_not_of("\t \r\n");
        if(pos != std::string::npos)
            strTemp = strTemp.substr(pos);
        else
            strTemp.clear();

        return strTemp;
    }

    std::string TrimEnd(const std::string& str)
    {
        std::string strTemp(str);

        size_t pos = strTemp.find_last_not_of("\t \r\n");
        if(pos != std::string::npos)
            strTemp = strTemp.substr(0, pos + 1);

        return strTemp;
    }

    std::string Trim(const std::string& str)
    {
        std::string strTemp(str);

        strTemp = TrimEnd(str);
        strTemp = TrimStart(strTemp);

        return strTemp;
    }

    BOOL StartWith(const string& str, const string& startStr)
    {
        string::size_type pos = str.find(startStr);
        return pos == 0;
    }

    BOOL  EndWith(const string& str, const string& endStr)
    {
        string::size_type pos = str.find(endStr,str.length() - endStr.length());
        return pos != string::npos;
    }

    std::string Replace(const std::string &str, const std::string& string_to_replace, const std::string& new_string)
    {	
        if(string_to_replace.empty())
            return str;

        std::string strTemp(str);

        int  index = (int)strTemp.find(string_to_replace);   
        while(index != std::string::npos)   
        {    
            strTemp.replace(index, strlen(string_to_replace.c_str()), new_string);   
            index   =   (int)strTemp.find(string_to_replace, index+strlen(new_string.c_str()));   
        }

        return strTemp;
    }

    BOOL	IsValidPath(const std::string& str)
    {
        return str.find_first_of("\\/\"*<>:?&|") == std::string::npos;
    }

    class FunctorIsValidChar
    {
    public:
        FunctorIsValidChar():strValid("\\/\"*<>:?&|"){}
        bool operator()(char ch)
        {
            return strValid.find(ch)!=std::string::npos;
        }
    private:
        std::string strValid;
    };

    void EraseInvalidChar(std::string& strIn)
    {
        strIn.erase(std::remove_if(strIn.begin(),strIn.end(),FunctorIsValidChar()),strIn.end());
    }
}
