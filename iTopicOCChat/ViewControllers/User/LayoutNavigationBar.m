//
//  LayoutNavigationBar.m
//  iTopic
//
//  Created by DongJin on 2017/9/24.
//  Copyright © 2017年 DongQi. All rights reserved.
//

#import "LayoutNavigationBar.h"

@implementation LayoutNavigationBar

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), kTopNavHeight);//navBar + 状态栏高度
    for (UIView *view in self.subviews) {
        if([NSStringFromClass([view class]) containsString:@"Background"]) {
            view.frame = self.bounds;
        }
        else if ([NSStringFromClass([view class]) containsString:@"ContentView"]) {
            CGRect frame = view.frame;
            frame.origin.y = kStatusBarHeight; //状态烂高度
            frame.size.height = self.bounds.size.height - frame.origin.y;
            view.frame = frame;
        }
    }
}

@end
