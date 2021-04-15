//
//  UIImage+AFCommon.m
//  AFCommon
//
//  Created by QDong Email: 285275534@qq.com on 13-4-2.
//  Copyright (c) 2013年 ManGang. All rights reserved.
//

#import "UIImage+AFCommon.h"
#ifndef UIImageReflectionMethods
#define UIImageReflectionMethods
CGFloat AFDegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat AFRadiansToDegrees(CGFloat radians) {return radians * 180/M_PI;};
CGImageRef CreateGradientImage (int pixelsWide, int pixelsHigh, CGFloat endPoint) {
	CGImageRef theCGImage = NULL;
	
	// gradient is always black-white and the mask must be in the gray colorspace
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	// create the bitmap context
	CGContextRef gradientBitmapContext = CGBitmapContextCreate(NULL, pixelsWide, pixelsHigh,
															   8, 0, colorSpace, kCGBitmapByteOrderDefault);
	
	// define the start and end grayscale values (with the alpha, even though
	// our bitmap context doesn't support alpha the gradient requires it)
	CGFloat colors[] = {0.0, 1.0, 1, 1.0};
	
	// create the CGGradient and then release the gray color space
	CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
	CGColorSpaceRelease(colorSpace);
	
	// create the start and end points for the gradient vector (straight down)
	CGPoint gradientStartPoint = CGPointZero;
	CGPoint gradientEndPoint = CGPointMake(0, endPoint);
	
	if (endPoint < 0) {
		gradientEndPoint = CGPointMake(0, -endPoint);
	}
	
	// draw the gradient into the gray bitmap context
	CGContextDrawLinearGradient(gradientBitmapContext, grayScaleGradient, gradientStartPoint,gradientEndPoint, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(grayScaleGradient);
	
	// convert the context into a CGImageRef and release the context
	theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	
	if (endPoint < 0) {
		// rotate
		CGContextClearRect(gradientBitmapContext, CGRectMake(0, 0, pixelsWide, pixelsHigh));
		CGContextTranslateCTM(gradientBitmapContext, 0.0, pixelsHigh);
		CGContextScaleCTM(gradientBitmapContext, 1.0, -1.0);
		CGContextDrawImage(gradientBitmapContext, CGRectMake(0, 0, pixelsWide, pixelsHigh), theCGImage);
		CGImageRelease(theCGImage);
		theCGImage = CGBitmapContextCreateImage(gradientBitmapContext);
	}
	
	CGContextRelease(gradientBitmapContext);
	
	// return the imageref containing the gradient
    return theCGImage;
}
#endif

@implementation UIImage (AFCommon)
- (UIImage *)reflectionWithAlpha:(float)alpha isRotated:(BOOL)rotated
{
    return [self reflectionWithHeight:0 andAlpha:alpha isRotated:rotated];
}
- (UIImage *)reflectionWithHeight:(int)height andAlpha:(float)alpha isRotated:(BOOL)rotated
{
    if (height == 0){
		height = self.size.height;
	}
	
	// create a bitmap graphics context the size of the image
    //生成一个RGB的颜色空间
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	// create the bitmap context
    //创建一个上下文
	CGContextRef mainViewContentContext = CGBitmapContextCreate (NULL, self.size.width, self.size.height, 8,0, colorSpace,(kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst));
    // this will give us an optimal BGRA format for the device:
      
	CGColorSpaceRelease(colorSpace);
	// create a 2 bit CGImage containing a gradient that will be used for masking the
	// main view content to create the 'fade' of the reflection.  The CGImageCreateWithMask
	// function will stretch the bitmap image as required, so we can create a 1 pixel wide gradient
	CGImageRef gradientMaskImage = CreateGradientImage(1, height,( height * 1.0f / alpha *((rotated)?(-1):(1))));
	
	// create an image by masking the bitmap of the mainView content with the gradient view
	// then release the  pre-masked content bitmap and the gradient bitmap
    //使用 CGContextClipToMask 在图形上下问的某个矩形区域打上mask，这样做无论原先的图片有没有alpha通道，都可以实现半透明效果
	CGContextClipToMask(mainViewContentContext, CGRectMake(0.0, 0.0, self.size.width, height), gradientMaskImage);
	CGImageRelease(gradientMaskImage);
	
	// In order to grab the part of the image that we want to render, we move the context origin to the
	// height of the image that we want to capture, then we flip the context so that the image draws upside down.
    //如果不旋转的话，就把坐标放正
//    if (!rotated) {
        CGContextTranslateCTM(mainViewContentContext, 0.0, self.size.height);
        CGContextScaleCTM(mainViewContentContext, 1.0, -1.0);
//    }
	
	// draw the image into the bitmap context
	CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
	
	// create CGImageRef of the main view bitmap content, and then release that bitmap context
	CGImageRef reflectionImage = CGBitmapContextCreateImage(mainViewContentContext);
	CGContextRelease(mainViewContentContext);
	
	// convert the finished reflection image to a UIImage
	UIImage * theImage = [UIImage imageWithCGImage:reflectionImage];
	// image is retained by the property setting above, so we can release the original
	CGImageRelease(reflectionImage);
	
	return theImage;
}
- (UIImage *)roundedImageRectWithRadius:(NSInteger)radius
{
    int w = self.size.width;
    int h = self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGBitmapByteOrderDefault);
    CGRect rect = CGRectMake(0, 0, w, h);
    CGContextBeginPath(context);
    
    if (radius == 0) {
        CGContextClosePath(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return self;
    }
    else{
        //将当前图形状态推入堆栈。
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, radius, radius);
        float fw = CGRectGetWidth(rect) / radius;
        float fh = CGRectGetHeight(rect) / radius;
        CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
        //把堆栈顶部的状态弹出，返回到之前的图形状态。这也是将某些状态（比如裁剪路径）恢复到原有设置的唯一方式。
        CGContextRestoreGState(context);
    }
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, rect, self.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage* resultImage=[UIImage imageWithCGImage:imageMasked];
    CGImageRelease(imageMasked);
    return resultImage;
}
- (UIImage *)rotatedByRadians:(CGFloat)radians
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(context, self.size.width/2, self.size.height/2);
    // Now, draw the rotated/scaled image into the context
    CGContextRotateCTM(context, radians);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage *)rotatedByDegrees:(CGFloat)degrees
{
    return [self rotatedByRadians:AFDegreesToRadians(degrees)];
    // calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.size.width, self.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(AFDegreesToRadians(degrees));
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    // Create the bitmap context

    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //   // Rotate the image context
    CGContextRotateCTM(bitmap, AFDegreesToRadians(degrees));
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    
    CGContextDrawImage(bitmap, CGRectMake(-self.size.width / 2, -self.size.height / 2, self.size.width, self.size.height), [self CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage *)resizedToSize:(CGSize)size
{
    UIImage* resultImage=nil;
    CGRect rect = (CGRect){0,0,size};
    UIGraphicsBeginImageContext(size);
    [self drawInRect:rect];
    resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}
- (UIImage *)subImageAtRect:(CGRect)rect
{
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage* subImage = [UIImage imageWithCGImage: imageRef];
    CGImageRelease(imageRef);
    return subImage;
}
-(UIImage *)changeColorWithColor:(UIColor *)theColor
{
    UIGraphicsBeginImageContext(self.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSaveGState(ctx);
    CGContextClipToMask(ctx, area, self.CGImage);
    [theColor set];
    CGContextFillRect(ctx, area);
    CGContextRestoreGState(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextDrawImage(ctx, area, self.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (UIImage *)orientationFixed
{
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp || self.imageOrientation == UIImageOrientationUpMirrored)
        return [self copy];
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,CGImageGetBitsPerComponent(self.CGImage), 0,CGImageGetColorSpace(self.CGImage),CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
@end
