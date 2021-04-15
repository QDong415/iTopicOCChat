//
//  XHEmotionSectionBar.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionSectionBar.h"

#define kXHSendButtonWidth 60  //最右边的发送按钮
#define kEmojiWidth 40  //每个表情烂宽度


@interface XHEmotionSectionBar ()


@property (nonatomic, weak) UIScrollView *sectionBarScrollView;
@property (nonatomic, weak) UIButton *storeManagerItemButton;

@end

@implementation XHEmotionSectionBar



- (void)sectionImageClicked:(UITapGestureRecognizer *)singleTap{
    UIImageView *faceLogoImageView =  (UIImageView *)[singleTap view];
    if ([self.delegate respondsToSelector:@selector(didSelectedEmotionManager:atSection:)]) {
        NSInteger section = faceLogoImageView.tag;
        if (section < self.emotionManagers.count) {
            [self.delegate didSelectedEmotionManager:[self.emotionManagers objectAtIndex:section] atSection:section];
        }
    }

}

- (IBAction)sendButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectedSend)]) {
        [self.delegate didSelectedSend];
    }
}



- (UIButton *)cratedButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kXHSendButtonWidth, CGRectGetHeight(self.bounds));
    [button setBackgroundImage:[UIImage imageNamed:@"blue_rect"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}


- (UIView *)cratedDividerView {
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 5, 0.5, 30)];
    if (@available(iOS 11.0, *)) {
        view.backgroundColor = [UIColor colorNamed:@"separator"];
    } else {
        view.backgroundColor = COLOR_DIVIDER_RGB;
    }
    return view;
}

- (UIImageView *)cratedImageView:(int)index {
    UIImageView *button = [[UIImageView alloc]initWithFrame:CGRectMake(index * kEmojiWidth, 0, kEmojiWidth, CGRectGetHeight(self.bounds))];

    if (@available(iOS 11.0, *)) {
        button.backgroundColor = index == _currentIndex?[UIColor colorNamed:@"gray"]:[UIColor clearColor];
    } else {
        button.backgroundColor = index == _currentIndex?RGBCOLOR(229,229,229):[UIColor clearColor];
    }
   
    button.contentMode =  UIViewContentModeCenter;
    button.tag = index;
    
    button.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionImageClicked:)];
    [button addGestureRecognizer:singleTap];
    
    return button;
}

//设置当前选中的栏目
- (void)setCurrentIndex:(int)currentIndex
{
    _currentIndex = currentIndex;
    for (UIView *sectionIcon in self.sectionBarScrollView.subviews) {
        if ([sectionIcon isKindOfClass:[UIImageView class]]) {
            if (@available(iOS 11.0, *)) {
                sectionIcon.backgroundColor = sectionIcon.tag == currentIndex?[UIColor colorNamed:@"gray"]:[UIColor clearColor];
            } else {
                sectionIcon.backgroundColor = sectionIcon.tag == currentIndex?RGBCOLOR(229,229,229):[UIColor clearColor];
            }
        }
    }
}

- (void)reloadData {
    if (!self.emotionManagers.count)
        return;
    
    [self.sectionBarScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    for (XHEmotionManager *emotionManager in self.emotionManagers) {
        NSInteger index = [self.emotionManagers indexOfObject:emotionManager];
        UIImageView *sectionIcon = [self cratedImageView:(int)index];
        sectionIcon.image = [UIImage imageNamed:emotionManager.emotionBarLogoImageName];
        [self.sectionBarScrollView addSubview:sectionIcon];
        
        UIView *divider = [self cratedDividerView];
        CGRect dividerFrame = divider.frame;
        dividerFrame.origin.x = index * kEmojiWidth;
        divider.frame = dividerFrame;
        [self.sectionBarScrollView addSubview:divider];
        
    }
    
    [self.sectionBarScrollView setContentSize:CGSizeMake(self.emotionManagers.count * kEmojiWidth, CGRectGetHeight(self.bounds))];
    
    if (self.hideSendButton && _storeManagerItemButton) {
        _storeManagerItemButton.hidden = YES;
    }
}

#pragma mark - Lefy cycle

- (void)setup {
    if (!_sectionBarScrollView) {
        CGFloat scrollWidth = CGRectGetWidth(self.bounds);
        if (!self.hideSendButton) {
            scrollWidth -= kXHSendButtonWidth;
        }
        UIScrollView *sectionBarScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, scrollWidth, CGRectGetHeight(self.bounds))];
        [sectionBarScrollView setScrollsToTop:NO];
        sectionBarScrollView.showsVerticalScrollIndicator = NO;
        sectionBarScrollView.showsHorizontalScrollIndicator = NO;
        sectionBarScrollView.pagingEnabled = NO;
        [self addSubview:sectionBarScrollView];
        _sectionBarScrollView = sectionBarScrollView;
    }
    
    if (!self.hideSendButton) {
        UIButton *storeManagerItemButton = [self cratedButton];
        
        CGRect storeManagerItemButtonFrame = storeManagerItemButton.frame;
        storeManagerItemButtonFrame.origin.x = CGRectGetWidth(self.bounds) - kXHSendButtonWidth;
        storeManagerItemButton.frame = storeManagerItemButtonFrame;
        
        [storeManagerItemButton setTitle:@"发送" forState:UIControlStateNormal];
        [storeManagerItemButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [storeManagerItemButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:storeManagerItemButton];
        _storeManagerItemButton = storeManagerItemButton;
    }
}

- (instancetype)initWithFrame:(CGRect)frame hideSendButton:(BOOL)hideSendButton {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.hideSendButton = hideSendButton;
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.emotionManagers = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reloadData];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
