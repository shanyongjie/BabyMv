//
//  ToDouble.cpp
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#include "ToDouble.h"

namespace Convert
{

    double ConvertToDouble(char* val)
    {
        return strtod(val, NULL);
    }

    double ConvertToDouble(const char* val)
    {
        return strtod(val, NULL);
    }

    double ConvertToDouble(const bool& val)
    {
        if (val)
            return 1;
        else
            return 0;
    }
    double ConvertToDouble(const unsigned char& val)
    {
        return val;
    }

    double ConvertToDouble(const char& val)
    {
        return val;
    }

    double ConvertToDouble(const short& val)
    {
        return val;
    }

    double ConvertToDouble(const unsigned short& val)
    {
        return val;
    }

    double ConvertToDouble(const unsigned int& val)
    {
        return val;
    }

    double ConvertToDouble(const int& val)
    {
        return val;
    }

    double ConvertToDouble(const long& val)
    {
        return val;
    }

    double ConvertToDouble(const unsigned long& val)
    {
        return val;
    }

    double ConvertToDouble(const double& val)
    {
        return val;
    }

    double ConvertToDouble(const float& val)
    {
        return val;
    }

    double ConvertToDouble(const unsigned long long& val)
    {
        return (double)val;
    }

    double ConvertToDouble(const long long& val)
    {
        return (double)val;
    }

    double ConvertToDouble(const std::string& val)
    {
        return strtod(val.c_str(), NULL);
    }

}//namespace Convert


