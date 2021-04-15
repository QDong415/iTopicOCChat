//
//  MainViewController.h
//  pinpin
//
//  Created by DongJin on 15-4-4.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITabBarController

//清除用户信息并且跳转到登录界面
- (void)clearAndReLogin;

//我们自己的代码，AppDelegate收到融云的Message后，调用这里，传给MainVC处理
//- (void)handleReceiveMessageFromAppDelegate:(RCMessage *)message;

//重新设置ConversationTab上的Badge
- (void)showConversationTabBadge;

- (void)reloadDataIfEmpty;

@end
