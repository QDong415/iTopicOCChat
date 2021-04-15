//
//  AppDelegate.h
//  iTopic
//
//  Created by DongJin on 15-7-8.
//  Copyright (c) 2015年 DongQi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//是否支持友盟一键登录
@property (assign, nonatomic) BOOL supportUMAccelerateLogin;

#pragma mark - 获取当前正在活动中的的VC（仅仅为了踢出用户并跳转登录界面）
- (UIViewController *)activityViewController;

@end

