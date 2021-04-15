//
//  UITableView+EmptyFooterView.m
//  MJRefreshExample
//
//  Created by DongJin on 15-4-23.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "UITableView+EmptyFooterView.h"
#import "EmptyView.h"
@implementation UITableView (EmptyFooterView)


- (UIView *)getContainerView:(UIView *)view
{
    UIView *containerview = [[UIView alloc] initWithFrame:[view frame]];
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [containerview addSubview:view];
    return containerview;
}

- (void)setEmptyViewWithArray:(NSArray *)array withMargin:(float )heightLag withTitle:(NSString *)title
{
    if (array.count==0) {
        EmptyView *view = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        view.contentLabel.text = title;
        view.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height-self.tableHeaderView.frame.size.height - heightLag - 64);//往上偏移40
        self.tableFooterView = [self getContainerView:view];
    } else {
        UIView *footview = [[UIView alloc]init];
        self.tableFooterView = footview;
    }
}

- (void)setEmptyViewWithArray:(NSArray *)array withMargin:(float )heightLag
{
    if (array.count==0) {
        EmptyView *view = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        view.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height-self.tableHeaderView.frame.size.height - heightLag);//往上偏移40
        self.tableFooterView = [self getContainerView:view];
    } else {
        UIView *footview = [[UIView alloc]init];
        self.tableFooterView = footview;
    }
}


- (void)setEmptyViewFooterWithArray:(NSArray *)array withTitle:(NSString *)title
{
    if (array.count==0) {
        EmptyView *view = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        view.contentLabel.text = title;
        view.frame = CGRectMake(0,0,self.frame.size.width,240);//footer 固定240高度
        self.tableFooterView = [self getContainerView:view];
    } else {
        UIView *footview = [[UIView alloc]init];
        self.tableFooterView = footview;
    }
}


- (void)setEmptyViewCustomView:(UIView *)view withArray:(NSArray *)array withMargin:(float )heightLag
{
    if (array.count==0) {
        view.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height-self.tableHeaderView.frame.size.height - heightLag - self.tableHeaderView.frame.size.height - 64);//往上偏移40
        self.tableFooterView = [self getContainerView:view];
    } else {
        UIView *footview = [[UIView alloc]init];
        self.tableFooterView = footview;
    }
}

@end
