//
// MIT License
//
// Copyright (c) 2016 EnjoySR <https://github.com/EnjoySR/ESPictureBrowser>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#import <UIKit/UIKit.h>


@protocol ESSinglePictureBrowserDelegate <NSObject>
@optional
/**
 * DQ 2017-03-13 关闭图片浏览器时候的回调
 */
- (void)photoBrowserDidDismiss;
@end

@interface ESSinglePictureBrowser : UIView



/**
 页数文字字体，默认：系统字体，16号
 */
@property (nonatomic, strong) UIFont *pageTextFont;

/**
 页数文字颜色，默认：白色
 */
@property (nonatomic, strong) UIColor *pageTextColor;

/**
 长按图片要执行的事件，将长按图片索引回调
 */
@property (nonatomic, copy) void(^longPressBlock)(NSInteger);

@property (weak,nonatomic) id<ESSinglePictureBrowserDelegate> delegate;

/**
 显示1张图
 @param fromView            用户点击的视图
 @param pictureUrl          大图链接
 @param largeImage          大图Image 和上面二选一
 */
- (void)showSingleImageFromView:(UIView *)fromView placeholderImage:(UIImage *)placeholderImage pictureUrl:(NSString *)pictureUrl largeImage:(UIImage *)largeImage defaultSize:(CGSize)defaultSize;


/**
 让图片浏览器消失
 */
- (void)dismiss;


@end
