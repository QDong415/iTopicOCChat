//
// MIT License
//
// Copyright (c) 2016 EnjoySR <https://github.com/EnjoySR/ESSinglePictureBrowser>
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

#import "ESSinglePictureBrowser.h"
#import "ESPictureView.h"
#import "UIView+WebCache.h"

@interface ESSinglePictureBrowser()<UIScrollViewDelegate, ESPictureViewDelegate, UIActionSheetDelegate>

/// 图片数组，3个 UIImageView。进行复用
@property (nonatomic, strong) NSMutableArray<ESPictureView *> *pictureViews;

/// 界面子控件
@property (nonatomic, weak) UIScrollView *scrollView;
/// 页码文字控件
@property (nonatomic, weak) UILabel *pageTextLabel;
/// 消失的 tap 手势
@property (nonatomic, weak) UITapGestureRecognizer *dismissTapGes;
/// 消失的 tap 手势
@property (nonatomic, assign) CGRect fromViewRect;

@end

@implementation ESSinglePictureBrowser

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.pageTextFont = [UIFont systemFontOfSize:16];
    self.pageTextColor = [UIColor whiteColor];
    // 初始化数组
    self.pictureViews = [NSMutableArray array];
    
    // 初始化 scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    scrollView.showsVerticalScrollIndicator = false;
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.pagingEnabled = true;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 初始化label
    UILabel *label = [[UILabel alloc] init];
    label.alpha = 0;
    label.textColor = self.pageTextColor;
    label.font = self.pageTextFont;
    [self addSubview:label];
    self.pageTextLabel = label;
    
    // 添加手势事件
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longGes];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGes:)];
    [self addGestureRecognizer:tapGes];
    self.dismissTapGes = tapGes;
}

- (void)showSingleImageFromView:(UIView *)fromView placeholderImage:(UIImage *)placeholderImage pictureUrl:(NSString *)pictureUrl largeImage:(UIImage *)largeImage defaultSize:(CGSize)defaultSize
{

    // 添加到 window 上
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 计算 scrollView 的 contentSize
    self.scrollView.contentSize = CGSizeMake(0, _scrollView.frame.size.height);
    // 滚动到指定位置
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:false];
    // 设置第1个 view 的位置以及大小
    
    ESPictureView *view = [self getPhotoView];
    view.index = 0;
    CGRect frame = view.frame;
    frame.size = self.frame.size;
    view.frame = frame;
    
    // 3. 如果都没有就设置为屏幕宽度，待下载完成之后再次计算
    view.pictureSize = CGSizeEqualToSize(defaultSize,CGSizeZero)?CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width):defaultSize;

    // 设置占位图
    view.placeholderImage = placeholderImage;
    
    if(largeImage){
        [view setLargeImage:largeImage];
    } else {
        view.urlString = pictureUrl;
    }
    
    CGPoint center = view.center;
    center.x = 0 + _scrollView.frame.size.width * 0.5;
    view.center = center;
    
    
    ESPictureView *pictureView = view;
    // 获取来源图片在屏幕上的位置
    _fromViewRect = [fromView convertRect:fromView.bounds toView:nil];
    
    [pictureView animationShowWithFromRect:_fromViewRect animationBlock:^{
        self.backgroundColor = [UIColor blackColor];
        self.pageTextLabel.alpha = 1;
    } completionBlock:^{

    }];

}

- (void)dismiss {
    // 取到当前显示的 pictureView
    ESPictureView *pictureView = _pictureViews[0];
    // 取消所有的下载
    for (ESPictureView *pictureView in _pictureViews) {
        [pictureView.imageView sd_cancelCurrentImageLoad];
    }
    
    // 执行关闭动画
    [pictureView animationDismissWithToRect:_fromViewRect animationBlock:^{
        self.backgroundColor = [UIColor clearColor];
        self.pageTextLabel.alpha = 0;
    } completionBlock:^{
        if ([self.delegate respondsToSelector:@selector(photoBrowserDidDismiss)]) {
            [self.delegate photoBrowserDidDismiss];
        }
        [self removeFromSuperview];
    }];
}

#pragma mark - 监听事件

- (void)tapGes:(UITapGestureRecognizer *)ges {
    [self dismiss];
}

- (void)longPress:(UILongPressGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan) {
        // 跳出提示
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存到相册", nil];
        [sheet showInView:self.window];
    }
}

#pragma mark - 私有方法

- (void)setPageTextFont:(UIFont *)pageTextFont {
    _pageTextFont = pageTextFont;
    self.pageTextLabel.font = pageTextFont;
}

- (void)setPageTextColor:(UIColor *)pageTextColor {
    _pageTextColor = pageTextColor;
    self.pageTextLabel.textColor = pageTextColor;
}



/**
 获取图片控件：如果缓存里面有，那就从缓存里面取，没有就创建

 @return 图片控件
 */
- (ESPictureView *)getPhotoView {
    ESPictureView *view;
        view = [ESPictureView new];
        // 手势事件冲突处理
        [self.dismissTapGes requireGestureRecognizerToFail:view.imageView.gestureRecognizers.firstObject];
        view.pictureDelegate = self;
    [_scrollView addSubview:view];
    [_pictureViews addObject:view];
    return view;
}



#pragma mark - ESPictureViewDelegate 

- (void)pictureViewTouch:(ESPictureView *)pictureView {
    [self dismiss];
}
- (void)pictureView:(ESPictureView *)pictureView scale:(CGFloat)scale {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - scale];
}
    
- (void)dealloc {
}

#pragma mark - UIAcitonSheetDeleagate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // 取到当前显示的 pictureView
        ESPictureView *pictureView = _pictureViews[0];
        
        UIImageWriteToSavedPhotosAlbum(pictureView.imageView.image, self, @selector(image: didFinishSavingWithError: contextInfo:), nil);
    } else if (buttonIndex == 2) {
        //@"取消");
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    error ? [ProgressHUD showError:@"保存失败"] : [ProgressHUD showSuccess:@"保存成功"];
//    error ? [MBProgressHUD py_showError:@"保存失败" toView:nil] : [MBProgressHUD py_showSuccess:@"保存成功" toView:nil];
}

@end
