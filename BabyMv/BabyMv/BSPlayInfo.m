//
//  BSPlayInfo.m
//  BabyMv
//
//  Created by 单永杰 on 16/2/24.
//  Copyright © 2016年 chenjingying. All rights reserved.
//

#import "BSPlayInfo.h"

static BSPlayInfo* s_shared_instance = nil;

@interface BSPlayInfo ()

@property(nonatomic, assign)TIMING_TYPE eTimingType;
@property(nonatomic, assign)PLAY_MODE_TYPE ePlayMode;

@end

@implementation BSPlayInfo

+(BSPlayInfo*)sharedInstance{
    @synchronized(self){
        if (nil == s_shared_instance) {
            s_shared_instance = [[BSPlayInfo alloc] init];
        }
    }
    
    return s_shared_instance;
}

-(id)init{
    self = [super init];
    
    if (self) {
        _ePlayMode = E_MODE_SEQUENCE;
        _eTimingType = E_TIMING_NO;
    }
    
    return  self;
}

-(TIMING_TYPE)getTimingType{
    return _eTimingType;
}

-(PLAY_MODE_TYPE)getPlayMode{
    return _ePlayMode;
}

@end
