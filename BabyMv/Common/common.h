//
//  common.h
//  common
//
//  Created by Zhang Yuanqing on 12-6-14.
//  Copyright (c) 2012年 Kuwo Beijing Co., Ltd. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#include <time.h>
#include <sys/time.h>

#import "ctypedef.h"
#import "misc.h"
#import "itoa.h"
#import "util.h"

#ifdef __OBJC__
    #import <UIKit/UIKit.h>
    #import <Foundation/Foundation.h>

    #import "rect.h"
    #import "color.h"

//    #import "Categories.h"
#endif

#import "TimeHelper.h"
#import "FileHelper.h"


#ifdef __OBJC__
/*
 * To avoid the unrecognized selector exception: 
 * use this macro to fix a linker bug when define category in static libaray.
 * this can force the linker to load only category code with out any class.
 * look at this page for more information: 
 * http://www.dreamingwish.com/dream-2012/the-create-the-static-the-library-containing-the-category.html
 * use NS_ROOT_CLASS to disable the root class warning.
 */
    #define TT_FIX_CATEGORY_BUG(name) NS_ROOT_CLASS @interface TT_FIX_CATEGORY_BUG_##name @end \
                                      @implementation TT_FIX_CATEGORY_BUG_##name @end


#define decode_property_bool(property)      self.property = [aDecoder decodeBoolForKey:     @#property]
#define decode_property_int(property)       self.property = [aDecoder decodeIntForKey:      @#property]
#define decode_property_int32(property)     self.property = [aDecoder decodeInt32ForKey:    @#property]
#define decode_property_int64(property)     self.property = [aDecoder decodeInt64ForKey:    @#property]
#define decode_property_Integer(property)   self.property = [aDecoder decodeIntegerForKey:  @#property]
#define decode_property_float(property)     self.property = [aDecoder decodeFloatForKey:    @#property]
#define decode_property_double(property)    self.property = [aDecoder decodeDoubleForKey:   @#property]
#define decode_property_object(property)    self.property = [aDecoder decodeObjectForKey:   @#property]

#define encode_property_bool(property)      [aCoder encodeBool:     self.property forKey:@#property]
#define encode_property_int(property)       [aCoder encodeInt:      self.property forKey:@#property]
#define encode_property_int32(property)     [aCoder encodeInt32:    self.property forKey:@#property]
#define encode_property_int64(property)     [aCoder encodeInt64:    self.property forKey:@#property]
#define encode_property_Integer(property)   [aCoder encodeInteger:  self.property forKey:@#property]
#define encode_property_float(property)     [aCoder encodeFloat:    self.property forKey:@#property]
#define encode_property_double(property)    [aCoder encodeDouble:   self.property forKey:@#property]
#define encode_property_object(property)    [aCoder encodeObject:   self.property forKey:@#property]

#ifdef __cplusplus
extern "C"
#endif
void SafePerformSelectorOnMainThread(id obj, SEL sel, id arg, BOOL wait);

#endif  // __OBJC__
