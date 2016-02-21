//
//  RTLocalConfig.h
//  RingtoneDuoduo
//
//  Created by 单永杰 on 14-5-12.
//  Copyright (c) 2014年 www.ShoujiDuoduo.com. All rights reserved.
//

#ifndef __RingtoneDuoduo__RTLocalConfig__
#define __RingtoneDuoduo__RTLocalConfig__

#include <iostream>

#include <string>
#import <Foundation/Foundation.h>
#include "iniReader.h"

#define USER_CONFIG_FILE         "local_config.ini"

class RTLocalConfig
{
private:
    RTLocalConfig(){}
    virtual ~RTLocalConfig(){}
    
public:
    static RTLocalConfig* GetConfigureInstance();
    //   static void ReleaseConfigureInstance();
    
    BOOL InitConfig();
    
public:
    bool GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue);
    bool GetConfigStringValue(const char* pSection, const char* pKey,std::string & strValue,const std::string & strDefault);
    bool SetConfigStringValue(const char* pSection, const char* pKey,const std::string & strValue);
    
    bool GetConfigIntValue(const char* pSection, const char* pKey,int & nValue);
    bool GetConfigIntValue(const char* pSection, const char* pKey,int & nValue,const int nDefault);
    bool SetConfigIntValue(const char* pSection, const char* pKey,int  nValue);
    
    bool GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue);
    bool GetConfigBoolValue(const char* pSection, const char* pKey,bool & bValue,const bool bDefault);
    bool SetConfigBoolValue(const char* pSection, const char* pKey,bool  bValue);
    
    bool SaveConfig();
    
private:
    BOOL LoadConfigInfo();
    
private:
    iniReader mUserReader;
    
    bool mbChangeConf;
    
    
};


#endif /* defined(__RingtoneDuoduo__RTLocalConfig__) */
