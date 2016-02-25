//
//  BSPlayList.m
//  babysong
//
//  Created by 单永杰 on 14-7-10.
//  Copyright (c) 2014年 ShanYongjie. All rights reserved.
//

#import "BSPlayList.h"
#import "BSDir.h"
#import "RTLocalConfig.h"
#import "RTLocalConfigElements.h"

#define FILE_NAME_PLAYLIST              @"playlist.plist"

static BSPlayList* sharedInstance = nil;

@interface BSPlayList ()

@property (nonatomic, assign)int n_cur_index;

@end

@implementation BSPlayList

+(BSPlayList*)sharedInstance{
    @synchronized(self){
        if (nil == sharedInstance) {
            sharedInstance = [[BSPlayList alloc] init];
        }
    }
    
    return sharedInstance;
}

-(id)init{
    self = [super init];
    
    std::string str_plist_path = "";
    Dir::GetPath(Dir::PATH_DUCUMENT, str_plist_path);
    str_plist_path += [[NSString stringWithFormat:@"/%@", FILE_NAME_PLAYLIST] UTF8String];
    if (Dir::IsExistFile(str_plist_path)) {
        _arryPlayList = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSString stringWithFormat:@"%s", str_plist_path.c_str()]];
        _n_cur_index = -1;
        RTLocalConfig::GetConfigureInstance()->GetConfigIntValue(APP_PLAYLIST_GROUP, APP_PLAYLIST_INDEX, _n_cur_index);
        if (_n_cur_index >= _arryPlayList.count) {
            [self setCurIndex:(_arryPlayList.count - 1)];
        }
    }else {
        self.arryPlayList = nil;
        _n_cur_index = -1;
    }
    
    return  self;
}

- (void)setPlayList : (NSArray*)arry_play_list{
    _arryPlayList = [arry_play_list copy];
}
- (BMListDataModel*) currentItem{
    if (_arryPlayList && -1 != _n_cur_index && _n_cur_index < [_arryPlayList count]) {
        return [_arryPlayList objectAtIndex:_n_cur_index];
    }else {
        if (_arryPlayList && _arryPlayList.count) {
            _n_cur_index = 0;
            return [_arryPlayList objectAtIndex:0];
        }
        
        return  nil;
    }
}
- (BMListDataModel*) nextItem{
    if (_arryPlayList && -1 != _n_cur_index && _n_cur_index < ([_arryPlayList count] - 1)) {
        return [_arryPlayList objectAtIndex:(_n_cur_index + 1)];
    }else {
        return  nil;
    }
}
- (BMListDataModel*) prevItem{
    if (_arryPlayList && 0 < _n_cur_index && 0 != [_arryPlayList count]) {
        return [_arryPlayList objectAtIndex:(_n_cur_index - 1)];
    }else {
        return  nil;
    }
}
- (void)setCurIndex : (int)n_index{
    if (0 <= n_index && n_index < [_arryPlayList count]) {
        _n_cur_index = n_index;
        
        RTLocalConfig::GetConfigureInstance()->SetConfigIntValue(APP_PLAYLIST_GROUP, APP_PLAYLIST_INDEX, _n_cur_index);
    }
}

- (int)getCurIndex{
    return _n_cur_index;
}

- (void)savePlaylist{
    std::string str_plist_path = "";
    Dir::GetPath(Dir::PATH_DUCUMENT, str_plist_path);
    str_plist_path += [[NSString stringWithFormat:@"/%@", FILE_NAME_PLAYLIST] UTF8String];
    if (Dir::IsExistFile(str_plist_path)){
        Dir::DeleteFile(str_plist_path);
    }
    
    [NSKeyedArchiver archiveRootObject:_arryPlayList toFile:[NSString stringWithFormat:@"%s", str_plist_path.c_str()]];
}

@end
