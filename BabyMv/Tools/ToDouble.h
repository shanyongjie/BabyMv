//
//  ToDouble.h
//  KwSing
//
//  Created by 海平 翟 on 12-7-5.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ToDouble_h
#define KwSing_ToDouble_h
#include <string>

namespace Convert
{
            
    template<typename T>
    double ConvertToDouble(const T& val)
    {
        return 0;
    }

    double ConvertToDouble(char* val);

    double ConvertToDouble(const char* val);

    double ConvertToDouble(const bool& val);

    double ConvertToDouble(const unsigned char& val);

    double ConvertToDouble(const char& val);

    double ConvertToDouble(const short& val);

    double ConvertToDouble(const unsigned short& val);

    double ConvertToDouble(const unsigned int& val);

    double ConvertToDouble(const int& val);

    double ConvertToDouble(const long& val);

    double ConvertToDouble(const unsigned long& val);

    double ConvertToDouble(const double& val);

    double ConvertToDouble(const float& val);

    double ConvertToDouble(const unsigned long long& val);

    double ConvertToDouble(const long long& val);

    double ConvertToDouble(const std::string& val);

}//namespace Convert


#endif
