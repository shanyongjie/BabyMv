//
//  RTLocalConfig.cpp
//  RingtoneDuoduo
//
//  Created by 单永杰 on 14-5-12.
//  Copyright (c) 2014年 www.ShoujiDuoduo.com. All rights reserved.
//

#include "RTLocalConfig.h"

#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#import "FileHelper.h"
//#include "KwConfigElements.h"


RTLocalConfig* RTLocalConfig::GetConfigureInstance()
{
    static RTLocalConfig g_KwConfig;
    return &g_KwConfig;
}

BOOL RTLocalConfig::InitConfig()
{
    @autoreleasepool {
        
        LoadConfigInfo();
        
        mbChangeConf = false;
    }
    
    return TRUE;
}

BOOL RTLocalConfig::LoadConfigInfo()
{
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *userconf = [[paths objectAtIndex:0] stringByAppendingPathComponent:@ USER_CONFIG_FILE];
        
        mUserReader.loadIniInfo([userconf UTF8String]);
    }
    
    return TRUE;
}

bool RTLocalConfig::GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue)
{
    if(!mUserReader.findStringValueInSectionByKey(strValue, pKey, pSection))
        return false;
    
    return true;
}

bool RTLocalConfig::GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue,const std::string & strDefault)
{
    bool bret = GetConfigStringValue(pSection, pKey, strValue);
    if(!bret)
    {
        strValue = strDefault;
    }
    return  bret;
}

bool RTLocalConfig::SetConfigStringValue(const char* pSection, const char* pKey,const std::string & strValue)
{
    mbChangeConf = true;
    bool bret = (mUserReader.writeStrValueInSectionByKey(strValue, pKey, pSection));
    SaveConfig();
    return bret;
}

bool RTLocalConfig::GetConfigIntValue(const char* pSection, const char* pKey,int & nValue)
{
    if(!mUserReader.findIntValueInSectionByKey(nValue, pKey, pSection)){
        return false;
    }
    
    return true;
}

bool RTLocalConfig::GetConfigIntValue(const char* pSection, const char* pKey,int & nValue,const int nDefault)
{
    bool bret = GetConfigIntValue(pSection, pKey, nValue);
    if(!bret)
    {
        nValue = nDefault;
    }
    return  bret;
}

bool RTLocalConfig::SetConfigIntValue(const char* pSection, const char* pKey,int  nValue)
{
    char sz[MAX_PATH];
    sprintf(sz,"%d",nValue);
    string strtemp = sz;
    mbChangeConf = true;
    bool bret =  (mUserReader.writeStrValueInSectionByKey(strtemp, pKey, pSection));
    SaveConfig();
    return bret;
    
}

bool RTLocalConfig::GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue)
{
    if(!mUserReader.findBoolValueInSectionByKey(bValue, pKey, pSection)){
            return false;
    }
    
    return true;
}

bool RTLocalConfig::GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue,const bool bDefault)
{
    bool bret = GetConfigBoolValue(pSection, pKey, bValue);
    if(!bret)
    {
        bValue = bDefault;
    }
    return  bret;
}

bool RTLocalConfig::SetConfigBoolValue(const char* pSection, const char* pKey,bool  bValue)
{
    mbChangeConf = true;
    bool bret = (mUserReader.writeStrValueInSectionByKey((bValue?"1":"0"), pKey, pSection));
    SaveConfig();
    return bret;
}

bool RTLocalConfig::SaveConfig()
{
    if(mbChangeConf)
    {
        NSString * strconf = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@ USER_CONFIG_FILE];
        mbChangeConf = false;
        return mUserReader.writeIni([strconf UTF8String]);
    }
    return false;
}