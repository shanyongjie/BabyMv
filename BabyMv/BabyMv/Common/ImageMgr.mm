//
//  ImageMgr.cpp
//  KwSing
//
//  Created by Qian Hu on 12-7-9.
//  Copyright (c) 2012年 酷我音乐. All rights reserved.


#include <iostream>
#include "ImageMgr.h"
#import "BSDir.h"
#import "common.h"

IMAGE_MAP CImageMgr::g_mapImage;
std::string CImageMgr::g_strPath;
static CGFloat s_screenHeight(0);

//UIImage* CImageMgr::GetBackGroundImage()
//{
//    return GetImageEx("background.png");
//}

UIColor* CImageMgr::GetBackGroundColor()
{
    int rgbValue = 0xf0eae4;
    return UIColorFromRGB((rgbValue & 0xFF0000) >> 16,
                          (rgbValue & 0x00FF00) >> 8,
                          (rgbValue & 0x0000FF));
}

UIImage* CImageMgr::GetImage(const char* szbitmapname)
{
   	IMAGE_MAP::iterator it = g_mapImage.find(szbitmapname);
	if(it != g_mapImage.end())
	{
		return it->second;
	}
	return NULL;

}

UIImage* CImageMgr::GetImageEx(const char* szbitmapName)
{
	UIImage* data = GetImage(szbitmapName);
	if( !data ) {
		if( AddImage(szbitmapName) ) {
			data = GetImage(szbitmapName);
		}
	}
	return data;
}

UIImage* CImageMgr::AddImage(const char* szbitmapName)
{
    if (s_screenHeight==0) {
        s_screenHeight=[[UIScreen mainScreen] bounds].size.height;
    }
    std::string strimg = szbitmapName;
    UIImage *ptemp = GetImage(strimg.c_str());
    if(ptemp != NULL)
    {
        return ptemp;
    }
    int capw = 0,caph = 0;
    if(strimg.rfind("_") != std::string::npos)
    {   // img_w_h.png; img_w.png; img_0_h.png
        int hpos = strimg.rfind("_");
        std::string strfront = strimg.substr(0,hpos);
        std::string strcaph = strimg.substr(hpos+1,strimg.rfind(".")-hpos-1);
        caph = atoi(strcaph.c_str());
        if(strfront.rfind("_")  != std::string::npos)
        {
            std::string strcapw = strfront.substr(strfront.rfind("_")+1,-1);
            capw = atoi(strcapw.c_str());
        }
        else {
            capw = caph;
            caph = 0;
        }
    }
    
    UIImage * pimage(NULL);
    if (s_screenHeight==568) {//万恶的16:9
        std::string str568Name=Dir::GetFileNameWithoutExt(strimg)+"-568h."+Dir::GetFileExt(strimg);
        NSString* pstr=[NSString stringWithUTF8String:str568Name.c_str()];
        pimage = [[UIImage imageNamed:pstr] stretchableImageWithLeftCapWidth:capw topCapHeight:caph];
    }
    if (!pimage) {
        NSString * pstr = [NSString stringWithUTF8String:strimg.c_str()];
        pimage = [[UIImage imageNamed:pstr] stretchableImageWithLeftCapWidth:capw topCapHeight:caph];
    }

    if(pimage)
    {
        g_mapImage[strimg] = pimage;
    }
    return pimage;
}

bool CImageMgr::RemoveImage(const char* szbitmapName)
{
    UIImage* data = GetImage(szbitmapName);
	if( !data ) return false;

	
	g_mapImage.erase(szbitmapName);
    
	return true;
}

//void CImageMgr::RemoveAllImage()
//{
//    for (IMAGE_MAP::iterator iter = g_mapImage.begin(); iter != g_mapImage.end(); iter++) {
//        [iter->second release];
//    }
//}

bool CImageMgr::LoadAllIamgeFromZip(const char* szZipPath)
{
    return true;
}

void CImageMgr::SetImagePath(std::string strPath)
{
    g_strPath = strPath;
}