//
//  UITableView+EmptyFooterView.h
//  MJRefreshExample
//
//  Created by DongJin on 15-4-23.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (EmptyFooterView)

- (void)setEmptyViewWithArray:(NSArray *)array withMargin:(float )heightLag withTitle:(NSString *)title;
- (void)setEmptyViewWithArray:(NSArray *)array withMargin:(float )heightLag;
- (void)setEmptyViewFooterWithArray:(NSArray *)array withTitle:(NSString *)title;
- (void)setEmptyViewCustomView:(UIView *)view withArray:(NSArray *)array withMargin:(float )heightLag;
@end
