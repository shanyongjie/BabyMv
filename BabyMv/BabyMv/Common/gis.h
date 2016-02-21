//
//  gis.h
//  Guanying
//
//  Created by mistyzyq on 12-12-5.
//  Copyright (c) 2012年 HuaYing co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const double EARTH_RADIUS;


double Degree2Radians(double degree);
double Radians2Degree(double radians);

// from location1 to location2

double CalculateDistance(double lat1, double lng1, double lat2, double lng2);

// from location1 to location2, use angle.
double CalculateDirection(double lat1, double lng1, double lat2, double lng2);

NSString* DirectionString(double radian);
