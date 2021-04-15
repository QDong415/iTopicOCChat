//
//  BlockAlertView.h
//  pinpin
//
//  Created by DongJin on 15-4-12.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlockAlertView : UIAlertView<UIAlertViewDelegate>
@property (copy,nonatomic) void(^onClick)(UIAlertView * alertView,NSInteger integer);
@property (assign,nonatomic) bool delay;

@end
