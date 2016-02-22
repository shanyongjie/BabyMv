//
//  ImageMgr.h
//  KwSing
//
//  Created by Qian Hu on 12-7-9.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.
//

#ifndef KwSing_ImageMgr_h
#define KwSing_ImageMgr_h
#include <string>
#include <map>
#import <UIKit/UIKit.h>

typedef std::map<std::string,UIImage *> IMAGE_MAP;
class CImageMgr 
{
public:
    static UIColor* GetBackGroundColor();
    //static UIImage* GetBackGroundImage();
    // 获取一张图片，若不存在返回空
    static UIImage* GetImage(const char* szbitmapname);
    // 获取一张图片，若不存在加载这张图片
    static UIImage* GetImageEx(const char* szbitmapName);
    // 添加一张图片
    static UIImage* AddImage(const char* szbitmapName);
    // 移除一张图片
    static bool RemoveImage(const char* szbitmapName);
    // 移除所有图片
    static void RemoveAllImage();
    // 从zip包中加载所有图片
    static bool LoadAllIamgeFromZip(const char* szZipPath);   
    // 设置图片路径
    static void SetImagePath(std::string strPath);
private:
    static IMAGE_MAP g_mapImage;
    static std::string g_strPath;
};


#endif
