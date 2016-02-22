//
//  gis.m
//  Guanying
//
//  Created by mistyzyq on 12-12-5.
//  Copyright (c) 2012年 HuaYing co., Ltd. All rights reserved.
//

#include <math.h>
#import "gis.h"

const double EARTH_RADIUS = 6378137; // for Google maps

double Degree2Radians(double degree)
{
    return degree * M_PI / 180.0;
}

double Radians2Degree(double radians)
{
    return radians * 180.0 / M_PI;
}

double CalculateDistance(double lat1, double lng1, double lat2, double lng2)
{
    double radLat1 = Degree2Radians(lat1);
    double radLat2 = Degree2Radians(lat2);
    double a = radLat1 - radLat2;
    double b = Degree2Radians(lng1) - Degree2Radians(lng2);
    double s = 2 * asin(sqrt(pow(sin(a/2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b/2),2)));
    s = s * EARTH_RADIUS;
    return s;
}

double CalculateDirection(double lat1, double lng1, double lat2, double lng2)
{
    double rad = atan2(lng2 - lng1, lat2 - lat1);
    return rad;
}

NSString* DirectionString(double radian)
{
    NSString* dirStr = nil;
    if (radian >= -M_PI/6 && (radian <= M_PI/6))
    {
        dirStr = @"正东";
    }
    if (radian >= M_PI/6 && (radian <= M_PI/3))
    {
        dirStr = @"东北";
    }
    if (radian >= M_PI/3 && (radian <= M_PI*2/3))
    {
        dirStr = @"正北";
    }
    if (radian >= M_PI*2/3 && (radian <= M_PI*5/6))
    {
        dirStr = @"西北";
    }
    if (radian >= M_PI*5/6 || (radian <=- M_PI*5/6) )
    {
        dirStr = @"正西";
    }
    if (radian >= -M_PI*5/6 && (radian <= -M_PI*2/3))
    {
        dirStr = @"西南";
    }
    if (radian >= -M_PI*2/3 && (radian <= -M_PI*2/3))
    {
        dirStr = @"正南";
    }
    if (radian >= -M_PI*2/3 && (radian <= -M_PI/3) )
    {
        dirStr = @"东南";
    }
    return dirStr;
}
