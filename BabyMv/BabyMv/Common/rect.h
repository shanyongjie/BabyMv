//
//  globalm.h
//  KWPlayer
//
//  Created by YeeLion on 11-1-10.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

__BEGIN_DECLS
//#ifdef __cplusplus
//extern "C" {
//#endif


// CGRect helper
CGRect MakeRect(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom);

void OffsetRectToPoint(CGRect* lpRect, CGPoint point);
void OffsetRectToXY(CGRect* lpRect, float x, float y);
void OffsetRectX(CGRect* lpRect, float x);
void OffsetRectY(CGRect* lpRect, float y);
void OffsetRect(CGRect* lpRect, float x, float y);
void InflateRect(CGRect* lpRect, float left, float top, float right, float bottom);
void DeflateRect(CGRect* lpRect, float left, float top, float right, float bottom);
void InflateRectXY(CGRect* lpRect, float x, float y);
void DeflateRectXY(CGRect* lpRect, float x, float y);
void DeflateRectInset(CGRect* lpRect, UIEdgeInsets insets);

CGRect CGRectOffsetToPoint(CGRect rect, CGPoint point);
CGRect CGRectOffsetToXY(CGRect rect, float x, float y);
CGRect CGRectOffsetX(CGRect rect, float x);
CGRect CGRectOffsetY(CGRect rect, float y);
//CGRect CGRectOffset(CGRect rect, float x, float y);
CGRect CGRectInflate(CGRect rect, float left, float top, float right, float bottom);
CGRect CGRectDeflate(CGRect rect, float left, float top, float right, float bottom);
CGRect CGRectInflateXY(CGRect rect, float x, float y);
CGRect CGRectDeflateXY(CGRect rect, float x, float y);
CGRect CGRectDeflateInset(CGRect rect, UIEdgeInsets insets);

CGPoint CenterPoint(CGRect rect);
CGPoint LeftTopPoint(CGRect rect);
CGPoint LeftButtomPoint(CGRect rect);
CGPoint RightTopPoint(CGRect rect);
CGPoint RightBottomPoint(CGRect rect);

CGRect CenterRect(CGRect rect, float width, float height);
CGRect CenterRectForBounds(CGRect rect, CGRect bounds);
CGRect LeftRect(CGRect rect, float width, float offset);
CGRect RightRect(CGRect rect, float width, float offset);
CGRect TopRect(CGRect rect, float height, float offset);
CGRect BottomRect(CGRect rect, float height, float offset);

CGRect LeftTopRect(CGRect rect, float width, float height);
CGRect LeftBottomRect(CGRect rect, float width, float height);
CGRect RightTopRect(CGRect rect, float width, float height);
CGRect RightBottomRect(CGRect rect, float width, float height);

CGRect LeftCenterRect(CGRect rect, float width, float height, float offset);
CGRect RightCenterRect(CGRect rect, float width, float height, float offset);
CGRect TopCenterRect(CGRect rect, float width, float height, float offset);
CGRect BottomCenterRect(CGRect rect, float width, float height, float offset);

CGRect ScaleRectFromRect(CGRect rect, CGFloat scale);
CGRect RectFromScaleRect(CGRect rect, CGFloat scale);

//#ifdef __cplusplus
//}
//#endif
__END_DECLS
