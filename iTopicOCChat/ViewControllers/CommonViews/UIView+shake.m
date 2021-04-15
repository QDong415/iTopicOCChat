//
//  UIView+shake.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-28.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "UIView+shake.h"

@implementation UIView (shake)
- (void)shake {
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.translation.x"];
    CGFloat currentTx = self.transform.tx;
    
    animation.delegate = self;
    animation.duration = 0.7f;
    animation.values = @[ @(currentTx), @(currentTx + 17), @(currentTx-13), @(currentTx + 13), @(currentTx -6), @(currentTx + 6), @(currentTx) ];
    animation.keyTimes = @[ @(0), @(0.225), @(0.425), @(0.6), @(0.75), @(0.875), @(1) ];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:nil];
}
@end
