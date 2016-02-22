//
//  UIImage+Helper.h
//  phpwind
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper) 

+ (UIImage *)imageWithFileName:(NSString *)fileName;

- (UIImage *)scaleToSize:(CGSize)size;

- (UIImage *)aspectScaleToSize:(CGSize)size;

- (UIImage *)imageByCropping:(CGRect)rect;

- (UIImage *)imageByCroppingWithRatio:(float)value;

- (UIImage *)resizeImageWithCapInsets:(UIEdgeInsets)capInsets;

- (UIImage *)leftMirrorImageToRight;

- (UIImage *)topMirrorImageToBottom;

- (BOOL)writeImageToFileAtPath:(NSString *)aPath;

- (UIImage *)clipsImageToSize:(CGSize)desSZ;

- (UIImage *)resetSquareImage;

- (UIImage *)resetSquareImage:(CGSize)desSZ;

+ (UIImage *)createImageWithColor:(UIColor *)color;

- (UIImage*)cropImage:(UIImage*)image to:(CGRect)cropRect;

- (UIImage *)cropImage:(UIImage *)image to:(CGRect)cropRect andScaleTo:(CGSize)size;

- (UIImage *)ajustOrientation:(UIImage *)image;

+ (UIImage *)fixOrientation:(UIImage *)aImage;

@end
