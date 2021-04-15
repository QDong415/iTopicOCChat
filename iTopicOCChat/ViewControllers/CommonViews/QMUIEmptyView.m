//
//  QMUIEmptyView.m
//  qmui
//
//  Created by 李凯 on 2016/10/9.
//  Copyright © 2016年 QMUI Team. All rights reserved.
//

#import "QMUIEmptyView.h"

@interface QMUIEmptyView ()

@property(nonatomic, strong) UIScrollView *scrollView;  // 保证内容超出屏幕时也不至于直接被clip（比如横屏时）

@end

@implementation QMUIEmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    // 系统默认会在view即将被add到window上时才设置这些值，这个时机有点晚了，因为我们可能在add到window之前就进行sizeThatFits计算或对view进行截图等操作，因此这里提前到init时就去做
    QMUIEmptyView *appearance = [QMUIEmptyView appearance];
    _imageViewInsets = appearance.imageViewInsets;
    _loadingViewInsets = appearance.loadingViewInsets;
    _textLabelInsets = appearance.textLabelInsets;
    _detailTextLabelInsets = appearance.detailTextLabelInsets;
    _actionButtonInsets = appearance.actionButtonInsets;
    _verticalOffset = appearance.verticalOffset;
    _textLabelFont = appearance.textLabelFont;
    _detailTextLabelFont = appearance.detailTextLabelFont;
    _actionButtonFont = appearance.actionButtonFont;
    _textLabelTextColor = appearance.textLabelTextColor;
    _detailTextLabelTextColor = appearance.detailTextLabelTextColor;
    _actionButtonTitleColor = appearance.actionButtonTitleColor;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 10, 0, 10); // 避免 label 直接撑满到屏幕两边，不好看
    [self addSubview:self.scrollView];
    
    _contentView = [[UIView alloc] init];
    [self.scrollView addSubview:self.contentView];
    
    _loadingView = (UIView<QMUIEmptyViewLoadingViewProtocol> *)[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    ((UIActivityIndicatorView *)self.loadingView).hidesWhenStopped = NO;    // 此控件是通过loadingView.hidden属性来控制显隐的，如果UIActivityIndicatorView的hidesWhenStopped属性设置为YES的话，则手动设置它的hidden属性就会失效，因此这里要置为NO
    [self.contentView addSubview:self.loadingView];
    
    _imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:self.imageView];
    
    _textLabel = [[UILabel alloc] init];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 0;
    [self.contentView addSubview:self.textLabel];
    
    _detailTextLabel = [[UILabel alloc] init];
    self.detailTextLabel.textAlignment = NSTextAlignmentCenter;
    self.detailTextLabel.numberOfLines = 0;
    [self.contentView addSubview:self.detailTextLabel];
    
    _actionButton = [[UIButton alloc] init];
//    self.actionButton.qmui_outsideEdge = UIEdgeInsetsMake(-20, -20, -20, -20);
    [self.contentView addSubview:self.actionButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    CGSize contentViewSize = [self CGSizeFlatted:[self sizeThatContentViewFits]];
    self.contentView.frame = [self CGRectFlatMakeX:0 y:CGRectGetMidY(self.scrollView.bounds) - contentViewSize.height / 2 + self.verticalOffset width:contentViewSize.width height:contentViewSize.height];
    
    self.scrollView.contentSize = CGSizeMake(fmax(CGRectGetWidth(self.scrollView.bounds) - [self UIEdgeInsetsGetHorizontalValue:self.scrollView.contentInset], contentViewSize.width), fmax(CGRectGetHeight(self.scrollView.bounds) -  [self UIEdgeInsetsGetVerticalValue:self.scrollView.contentInset ], CGRectGetMaxY(self.contentView.frame)));
    
    CGFloat originY = 0;
    
    if (!self.imageView.hidden) {
        [self.imageView sizeToFit];
        CGRect imageFrame = self.imageView.frame;
        imageFrame.origin.x = ((CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.imageView.frame)) / 2.0 ) + self.imageViewInsets.left - self.imageViewInsets.right;
        imageFrame.origin.y = originY + self.imageViewInsets.top;
        self.imageView.frame = imageFrame;
        originY = CGRectGetMaxY(self.imageView.frame) + self.imageViewInsets.bottom;
    }

    if (!self.textLabel.hidden) {
        CGFloat labelWidth = CGRectGetWidth(self.contentView.bounds) - (self.textLabelInsets.left + self.textLabelInsets.right);
        CGSize labelSize = [self.textLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        self.textLabel.frame = CGRectMake(self.textLabelInsets.left, originY + self.textLabelInsets.top, labelWidth, labelSize.height);
        originY = CGRectGetMaxY(self.textLabel.frame) + self.textLabelInsets.bottom;
    }

    if (!self.detailTextLabel.hidden) {
        CGFloat labelWidth = CGRectGetWidth(self.contentView.bounds) - (self.detailTextLabelInsets.left + self.detailTextLabelInsets.right);
        CGSize labelSize = [self.detailTextLabel sizeThatFits:CGSizeMake(labelWidth, CGFLOAT_MAX)];
        self.detailTextLabel.frame = CGRectMake(self.detailTextLabelInsets.left, originY + self.detailTextLabelInsets.top, labelWidth, labelSize.height);
        originY = CGRectGetMaxY(self.detailTextLabel.frame) + self.detailTextLabelInsets.bottom;
    }
//
//    if (!self.actionButton.hidden) {
//        [self.actionButton sizeToFit];
//        self.actionButton.frame = CGRectSetXY(self.actionButton.frame, CGRectGetMinXHorizontallyCenterInParentRect(self.contentView.bounds, self.actionButton.frame) + self.actionButtonInsets.left - self.actionButtonInsets.right, originY + self.actionButtonInsets.top);
//        originY = CGRectGetMaxY(self.actionButton.frame) + self.actionButtonInsets.bottom;
//    }
}


- (CGFloat)UIEdgeInsetsGetVerticalValue:(UIEdgeInsets )insets {
    return insets.top + insets.bottom;
}

- (CGFloat)UIEdgeInsetsGetHorizontalValue:(UIEdgeInsets )insets {
    return insets.left + insets.right;
}

-(CGSize)CGSizeFlatted:(CGSize)size {
    return CGSizeMake(size.width, size.height);
}

/// 创建一个像素对齐的CGRect
- (CGRect)CGRectFlatMakeX:(CGFloat)x y:(CGFloat)y width:(CGFloat)width height:(CGFloat)height {
    return CGRectMake(x, y, width, height);
}

- (CGSize)sizeThatContentViewFits {
    CGFloat resultWidth = CGRectGetWidth(self.scrollView.bounds) - [self UIEdgeInsetsGetHorizontalValue:self.scrollView.contentInset];
    
    CGFloat imageViewHeight = [self.imageView sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.imageViewInsets.top + self.imageViewInsets.bottom;
    CGFloat loadingViewHeight = CGRectGetHeight(self.loadingView.bounds) + self.loadingViewInsets.top + self.loadingViewInsets.bottom;
    CGFloat textLabelHeight = [self.textLabel sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.textLabelInsets.top + self.textLabelInsets.bottom;
    CGFloat detailTextLabelHeight = [self.detailTextLabel sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.detailTextLabelInsets.top + self.detailTextLabelInsets.bottom;
    CGFloat actionButtonHeight = [self.actionButton sizeThatFits:CGSizeMake(resultWidth, CGFLOAT_MAX)].height + self.actionButtonInsets.top +self.actionButtonInsets.bottom;
    
    CGFloat resultHeight = 0;
    if (!self.imageView.hidden) {
        resultHeight += imageViewHeight;
    }
    if (!self.loadingView.hidden) {
        resultHeight += loadingViewHeight;
    }
    if (!self.textLabel.hidden) {
        resultHeight += textLabelHeight;
    }
    if (!self.detailTextLabel.hidden) {
        resultHeight += detailTextLabelHeight;
    }
    if (!self.actionButton.hidden) {
        resultHeight += actionButtonHeight;
    }
    
    return CGSizeMake(resultWidth, resultHeight);
}

- (void)updateDetailTextLabelWithText:(NSString *)text {
    if (self.detailTextLabelFont && self.detailTextLabelTextColor && text) {
        NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:@{
                                                                                                  NSFontAttributeName: self.detailTextLabelFont,
                                                                                                  NSForegroundColorAttributeName: self.detailTextLabelTextColor,
                                                                                                  NSParagraphStyleAttributeName: [self  qmui_paragraphStyleWithLineHeight:self.detailTextLabelFont.pointSize + 10 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]
                                                                                                  }];
        self.detailTextLabel.attributedText = string;
    }
    self.detailTextLabel.hidden = !text;
    [self setNeedsLayout];
}

- (NSMutableParagraphStyle *)qmui_paragraphStyleWithLineHeight:(CGFloat)lineHeight lineBreakMode:(NSLineBreakMode)lineBreakMode textAlignment:(NSTextAlignment)textAlignment {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = lineHeight;
    paragraphStyle.maximumLineHeight = lineHeight;
    paragraphStyle.lineBreakMode = lineBreakMode;
    paragraphStyle.alignment = textAlignment;
    return paragraphStyle;
}

- (void)setLoadingView:(UIView<QMUIEmptyViewLoadingViewProtocol> *)loadingView {
    if (self.loadingView != loadingView) {
        [self.loadingView removeFromSuperview];
        _loadingView = loadingView;
        [self.contentView addSubview:loadingView];
    }
    [self setNeedsLayout];
}

- (void)setLoadingViewHidden:(BOOL)hidden {
    self.loadingView.hidden = hidden;
    if (!hidden && [self.loadingView respondsToSelector:@selector(startAnimating)]) {
        [self.loadingView startAnimating];
    }
    [self setNeedsLayout];
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.hidden = !image;
    [self setNeedsLayout];
}

- (void)setTextLabelText:(NSString *)text {
    self.textLabel.text = text;
    self.textLabel.hidden = !text;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelText:(NSString *)text {
    [self updateDetailTextLabelWithText:text];
}

- (void)setActionButtonTitle:(NSString *)title {
    [self.actionButton setTitle:title forState:UIControlStateNormal];
    self.actionButton.hidden = !title;
    [self setNeedsLayout];
}

- (void)setImageViewInsets:(UIEdgeInsets)imageViewInsets {
    _imageViewInsets = imageViewInsets;
    [self setNeedsLayout];
}

- (void)setTextLabelInsets:(UIEdgeInsets)textLabelInsets {
    _textLabelInsets = textLabelInsets;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelInsets:(UIEdgeInsets)detailTextLabelInsets {
    _detailTextLabelInsets = detailTextLabelInsets;
    [self setNeedsLayout];
}

- (void)setActionButtonInsets:(UIEdgeInsets)actionButtonInsets {
    _actionButtonInsets = actionButtonInsets;
    [self setNeedsLayout];
}

- (void)setVerticalOffset:(CGFloat)verticalOffset {
    _verticalOffset = verticalOffset;
    [self setNeedsLayout];
}

- (void)setTextLabelFont:(UIFont *)textLabelFont {
    _textLabelFont = textLabelFont;
    self.textLabel.font = textLabelFont;
    [self setNeedsLayout];
}

- (void)setDetailTextLabelFont:(UIFont *)detailTextLabelFont {
    _detailTextLabelFont = detailTextLabelFont;
    [self updateDetailTextLabelWithText:self.detailTextLabel.text];
}

- (void)setActionButtonFont:(UIFont *)actionButtonFont {
    _actionButtonFont = actionButtonFont;
    self.actionButton.titleLabel.font = actionButtonFont;
    [self setNeedsLayout];
}

- (void)setTextLabelTextColor:(UIColor *)textLabelTextColor {
    _textLabelTextColor = textLabelTextColor;
    self.textLabel.textColor = textLabelTextColor;
}

- (void)setDetailTextLabelTextColor:(UIColor *)detailTextLabelTextColor {
    _detailTextLabelTextColor = detailTextLabelTextColor;
    [self updateDetailTextLabelWithText:self.detailTextLabel.text];
}

- (void)setActionButtonTitleColor:(UIColor *)actionButtonTitleColor {
    _actionButtonTitleColor = actionButtonTitleColor;
    [self.actionButton setTitleColor:actionButtonTitleColor forState:UIControlStateNormal];
}

@end

@interface QMUIEmptyView (UIAppearance)

@end

@implementation QMUIEmptyView (UIAppearance)

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self setDefaultAppearance];
    });
}

+ (void)setDefaultAppearance {
    QMUIEmptyView *appearance = [QMUIEmptyView appearance];
    appearance.imageViewInsets = UIEdgeInsetsMake(0, 0, 16, 0);
    appearance.loadingViewInsets = UIEdgeInsetsMake(0, 0, 16, 0);
    appearance.textLabelInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    appearance.detailTextLabelInsets = UIEdgeInsetsMake(0, 0, 10, 0);
    appearance.actionButtonInsets = UIEdgeInsetsZero;
    appearance.verticalOffset = -30;
    
//    appearance.textLabelFont = UIFontMake(15);
    appearance.detailTextLabelFont = [UIFont systemFontOfSize:15.f];
//    appearance.actionButtonFont = UIFontMake(15);
//
//    appearance.textLabelTextColor = UIColorMake(93, 100, 110);
    appearance.detailTextLabelTextColor = RGBCOLOR(133, 140, 150);
//    appearance.actionButtonTitleColor = ButtonTintColor;
}

@end
