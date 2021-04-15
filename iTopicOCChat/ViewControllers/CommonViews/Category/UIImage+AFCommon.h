//
//  UIImage+AFCommon.h
//  AFCommon
//
//  Created by QDong Email: 285275534@qq.com on 13-4-2.
//  Copyright (c) 2013年 ManGang. All rights reserved.
//


@interface UIImage (AFCommon)
#pragma mark - 对图像做点处理，返回一个新的UIImage对象。
/**
 生成一个图像的倒影反射
 @param   生成图像的高度 、 透明度 、 是否旋转。
 @returns UIImage对象的倒影（也是UIImage对象）。
 */
- (UIImage *)reflectionWithAlpha:(float)alpha isRotated:(BOOL)rotated;
- (UIImage *)reflectionWithHeight:(int)height andAlpha:(float)alpha isRotated:(BOOL)rotated;
/**
 圆角化一个图片
 @param   圆角的宽度width
 @returns 圆角的图片
 */
- (UIImage *)roundedImageRectWithRadius:(NSInteger)radius;
/**
 旋转图片
 @param 角度或者弧度
 @returns 旋转后的图片
 */
- (UIImage *)rotatedByRadians:(CGFloat)radians;
- (UIImage *)rotatedByDegrees:(CGFloat)degrees;
/**
 改变图片的大小
 @param 大小
 @returns 调整后的图片
 */
- (UIImage *)resizedToSize:(CGSize)size;
/**
 提取子图片
 @param 提取大小
 @returns 子图片
 */
- (UIImage *)subImageAtRect:(CGRect)rect;
/**
 改变图片的颜色
 @param 需要改变的颜色
 @returns 新的图片
 */
- (UIImage *)changeColorWithColor:(UIColor *)theColor;
/**
 修正图片的转向(从相机中取出的照片容易转向)
 */
- (UIImage *)orientationFixed;
#pragma mark - 类方法
/**
 生成一张纯色的image
 @param 颜色，大小
 @returns image
 */
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;
@end
