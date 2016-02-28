//
//  globalm.mm
//  KWPlayer
//
//  Created by YeeLion on 11-1-10.
//  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
//

#import "misc.h"
#import "util.h"
#import "rect.h"


// CGRect helper
CGRect MakeRect(CGFloat left, CGFloat top, CGFloat right, CGFloat bottom)
{
    return CGRectMake(left, top, right - left, bottom - top);
}

void OffsetRectToPoint(CGRect* lpRect, CGPoint point) {
    CHECK_POINTER(lpRect);
    lpRect->origin.x = point.x;
    lpRect->origin.y = point.y;
}

void OffsetRectToXY(CGRect* lpRect, float x, float y) {
    CHECK_POINTER(lpRect);
    lpRect->origin.x = x;
    lpRect->origin.y = y;
}

void OffsetRectX(CGRect* lpRect, float x) {
    CHECK_POINTER(lpRect);
    lpRect->origin.x += x;
}

void OffsetRectY(CGRect* lpRect, float y) {
    CHECK_POINTER(lpRect);
    lpRect->origin.y += y;
}

void OffsetRect(CGRect* lpRect, float x, float y) {
    CHECK_POINTER(lpRect);
    lpRect->origin.x += x;
    lpRect->origin.y += y;
}

void InflateRect(CGRect* lpRect, float left, float top, float right, float bottom) {
    CHECK_POINTER(lpRect);
    lpRect->origin.x -= left;
    lpRect->origin.y -= top;
    lpRect->size.width += left + right;
    lpRect->size.height += top + bottom;
}

void DeflateRect(CGRect* lpRect, float left, float top, float right, float bottom) {
    CHECK_POINTER(lpRect);
    lpRect->origin.x += left;
    lpRect->origin.y += top;
    lpRect->size.width -= left + right;
    lpRect->size.height -= top + bottom;
}

void InflateRectXY(CGRect* lpRect, float x, float y)
{
    CHECK_POINTER(lpRect);
    lpRect->origin.x -= x;
    lpRect->origin.y -= y;
    lpRect->size.width += x + x;
    lpRect->size.height += y + y;
}

void DeflateRectXY(CGRect* lpRect, float x, float y)
{
    CHECK_POINTER(lpRect);
    lpRect->origin.x += x;
    lpRect->origin.y += y;
    lpRect->size.width -= x + x;
    lpRect->size.height -= y + y;    
}

void DeflateRectInset(CGRect* lpRect, UIEdgeInsets insets)
{
    CHECK_POINTER(lpRect);
    lpRect->origin.x += insets.left;
    lpRect->origin.y += insets.top;
    lpRect->size.width -= insets.left + insets.right;
    lpRect->size.height -= insets.top + insets.bottom;
}

CGRect CGRectOffsetToPoint(CGRect rect, CGPoint point) {
    rect.origin.x = point.x;
    rect.origin.y = point.y;
    return rect;
}

CGRect CGRectOffsetToXY(CGRect rect, float x, float y) {
    rect.origin.x = x;
    rect.origin.y = y;
    return rect;
}

CGRect CGRectOffsetX(CGRect rect, float x) {
    rect.origin.x += x;
    return rect;
}

CGRect CGRectOffsetY(CGRect rect, float y) {
    rect.origin.y += y;
    return rect;
}

//CGRect CGRectOffset(CGRect rect, float x, float y) {
//    rect.origin.x += x;
//    rect.origin.y += y;
//    return rect;
//}

CGRect CGRectInflate(CGRect rect, float left, float top, float right, float bottom) {
    rect.origin.x -= left;
    rect.origin.y -= top;
    rect.size.width += left + right;
    rect.size.height += top + bottom;
    return rect;
}

CGRect CGRectDeflate(CGRect rect, float left, float top, float right, float bottom) {
    rect.origin.x += left;
    rect.origin.y += top;
    rect.size.width -= left + right;
    rect.size.height -= top + bottom;
    return rect;
}

CGRect CGRectInflateXY(CGRect rect, float x, float y)
{
    rect.origin.x -= x;
    rect.origin.y -= y;
    rect.size.width += x + x;
    rect.size.height += y + y;
    return rect;
}

CGRect CGRectDeflateXY(CGRect rect, float x, float y)
{
    rect.origin.x += x;
    rect.origin.y += y;
    rect.size.width -= x + x;
    rect.size.height -= y + y;
    return rect;
}

CGRect CGRectDeflateInset(CGRect rect, UIEdgeInsets insets)
{
    rect.origin.x += insets.left;
    rect.origin.y += insets.top;
    rect.size.width -= insets.left + insets.right;
    rect.size.height -= insets.top + insets.bottom;
    return rect;
}

CGPoint CenterPoint(CGRect rect) {
    CGPoint point = {static_cast<CGFloat>(rect.origin.x + rect.size.width / 2.0),
        static_cast<CGFloat>(rect.origin.y + rect.size.height / 2.0)};
    return point;
}

CGPoint LeftTopPoint(CGRect rect) {
    return rect.origin;
}

CGPoint LeftButtomPoint(CGRect rect) {
    CGPoint pt = rect.origin;
    pt.y += rect.size.height;
    return pt;
}

CGPoint RightTopPoint(CGRect rect) {
    CGPoint pt = rect.origin;
    pt.x += (rect.size.width * 5.0 / 6);
    return pt;
}

CGPoint RightBottomPoint(CGRect rect) {
    CGPoint pt = rect.origin;
    pt.x += rect.size.width;
    pt.y += rect.size.height;
    return pt;
}

CGRect CenterRect(CGRect rect, float width, float height) {
    CGPoint pt = CenterPoint(rect);
    return CGRectMake(pt.x - width/2.0,
                      pt.y - height/2.0,
                      width,
                      height);
}

CGRect CenterRectForBounds(CGRect rect, CGRect bounds) {
    return CenterRect(bounds, rect.size.width, rect.size.height);
}

CGRect LeftRect(CGRect rect, float width, float offset) {
    return CGRectMake(rect.origin.x + offset,
                      rect.origin.y,
                      width,
                      rect.size.height);
}

CGRect RightRect(CGRect rect, float width, float offset) {
    return CGRectMake(rect.origin.x + rect.size.width - width - offset,
                      rect.origin.y,
                      width,
                      rect.size.height);
}

CGRect TopRect(CGRect rect, float height, float offset) {
    return CGRectMake(rect.origin.x,
                      rect.origin.y + offset,
                      rect.size.width,
                      height);
}

CGRect BottomRect(CGRect rect, float height, float offset) {
    return CGRectMake(rect.origin.x,
                      rect.origin.y + rect.size.height - height - offset,
                      rect.size.width,
                      height);
}

CGRect LeftTopRect(CGRect rect, float width, float height) {
    return CGRectMake(rect.origin.x,
                      rect.origin.y,
                      width,
                      height);
}

CGRect LeftBottomRect(CGRect rect, float width, float height) {
    return CGRectMake(rect.origin.x,
                      rect.origin.y + rect.size.height - height,
                      width,
                      height);
}

CGRect RightTopRect(CGRect rect, float width, float height) {
    return CGRectMake(rect.origin.x + rect.size.width - width,
                      rect.origin.y,
                      width,
                      height);
}

CGRect RightBottomRect(CGRect rect, float width, float height) {
    return CGRectMake(rect.origin.x + rect.size.width - width,
                      rect.origin.y + rect.size.height - height,
                      width,
                      height);
}

CGRect LeftCenterRect(CGRect rect, float width, float height, float offset) {
    return CGRectMake(rect.origin.x + offset,
                      rect.origin.y + (rect.size.height - height) / 2.0,
                      width,
                      height);
}

CGRect RightCenterRect(CGRect rect, float width, float height, float offset) {
    return CGRectMake(rect.origin.x + rect.size.width - offset - width,
                      rect.origin.y + (rect.size.height - height) / 2.0,
                      width,
                      height);
}

CGRect TopCenterRect(CGRect rect, float width, float height, float offset) {
    return CGRectMake(rect.origin.x + (rect.size.width - width) / 2.0,
                      rect.origin.y + offset,
                      width,
                      height);
}

CGRect BottomCenterRect(CGRect rect, float width, float height, float offset) {
    return CGRectMake(rect.origin.x + (rect.size.width - width) / 2.0,
                      rect.origin.y + rect.size.height - offset - height,
                      width,
                      height);
}

CGRect ScaleRectFromRect(CGRect rect, CGFloat scale) {
    return CGRectMake(CGRectGetMinX(rect)*scale, CGRectGetMinY(rect)*scale, 
                      CGRectGetWidth(rect)*scale, CGRectGetHeight(rect)*scale);
}

CGRect RectFromScaleRect(CGRect rect, CGFloat scale) {
    return CGRectMake(CGRectGetMinX(rect)/scale, CGRectGetMinY(rect)/scale, 
                      CGRectGetWidth(rect)/scale, CGRectGetHeight(rect)/scale);
}
