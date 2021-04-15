//
//  MainViewController.m
//  pinpin
//
//  Created by DongJin on 15-4-4.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "MainViewController.h"
#import "JsonParser.h"
#import "MineTabPersonalViewController.h"
#import "RegisterMobileViewController.h"
#import "LoginViewController.h"
#import "DBHelper.h"
#import "UIImage+LLExt.h"
#import "ConversationViewController.h"
#import "ValueUtil.h"
#import "BaseResponse.h"
#import "UserManager.h"

@interface MainViewController ()
{
}
@end

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //布局
    [self setUpSubviews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginChanged:) name:NOTIFICATION_USER_LOGIN_CHANGE object:nil];
    //监听新消息已拉（pull/msg接口）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessages:) name:NOTIFICATION_MESSAGES_RECEIVE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReaded:) name:NOTIFICATION_MESSAGE_READED object:nil];
    
    if ([USERMANAGER isLogin]) {
        NSMutableDictionary* params = [NSMutableDictionary new];
        [NETWORK postDataByApi:@"account/open" parameters:params responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
            BaseResponse *response = (BaseResponse *)responseObject;
            if ([response isSuccess]) {
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
        }];
        [USERMANAGER refreshMyProfile];
    } else {
    }
    
}

- (void)reloadDataIfEmpty
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER_LOGIN_CHANGE object:nil];
}

- (void)receiveMessages:(NSNotification *)notification
{
    [self showConversationTabBadge];
}

- (void)messageReaded:(NSNotification *)notification
{
    [self showConversationTabBadge];
}

#pragma mark NSNotification - 用户登录退出
- (void)userLoginChanged:(NSNotification *)notification
{
    [self showConversationTabBadge];
}

- (void)setUpSubviews
{
    MineTabPersonalViewController *_mineViewController = [[MineTabPersonalViewController alloc] init];

    
    ConversationViewController *_conversationViewController = [[ConversationViewController alloc]init];
    UINavigationController *_conversationNavigation= [[UINavigationController alloc] initWithRootViewController:_conversationViewController];
    _conversationNavigation.tabBarItem.title = @"聊天";
    _conversationNavigation.tabBarItem.image = [UIImage imageNamed:@"tabbar_chat_origin"];
    _conversationNavigation.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_chat_selected"];
    _conversationViewController.navigationItem.title = @"聊天";
    
    UINavigationController *_mineNavigation = [[UINavigationController alloc] initWithRootViewController:_mineViewController];
    _mineNavigation.tabBarItem.title = @"我的";
    _mineNavigation.tabBarItem.image = [UIImage imageNamed:@"tabbar_mine_oringin"];
    _mineNavigation.tabBarItem.selectedImage = [UIImage imageNamed:@"tabbar_mine_selected"];
    
    NSArray *SubControllers = @[
                                _conversationNavigation,
                                _mineNavigation
                                ];
    
    self.viewControllers = SubControllers;
    
    if (@available(iOS 13.0, *)) {
        
        UITabBarAppearance *appearance = [self.tabBar.standardAppearance copy];
        appearance.shadowImage = [UIImage imageWithColor:[UIColor colorNamed:@"separator235"] size:CGSizeMake(SCREEN_WIDTH, 0.5)];
        self.tabBar.standardAppearance = appearance;
        
        [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor colorNamed:@"separator235"] size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
        
//        [self.tabBar setShadowImage:[UIImage imageWithColor:[UIColor colorNamed:@"separator"] size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
    } else {
//        [self.tabBar setShadowImage:[UIImage imageWithColor:COLOR_DIVIDER_RGB size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
    }
//    [self.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
    //打开时候计算一次
    [self showConversationTabBadge];
}

//暗黑模式切换
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [self.tabBar.standardAppearance copy];
        appearance.shadowImage = [UIImage imageWithColor:[UIColor colorNamed:@"separator235"] size:CGSizeMake(SCREEN_WIDTH, 0.5)];
        self.tabBar.standardAppearance = appearance;
        
        [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor colorNamed:@"separator235"] size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
    }
}

#pragma mark - public
//清除用户信息并且跳转到登录界面
- (void)clearAndReLogin
{
    [USERMANAGER clean];
    
    AppDelegate *mAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *currentViewController = [mAppDelegate activityViewController];
    if ([currentViewController isKindOfClass:[RegisterMobileViewController class]] ||
        [currentViewController isKindOfClass:[LoginViewController class]] ) {
        NSLog(@"当前最上层已经是登录注册界面");
    } else {
        //让他重新登录
        LoginViewController *pickerVc = [[LoginViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pickerVc];
        [currentViewController presentViewController:nc animated:YES completion:nil];
        NSLog(@"重新去登录界面");
    }
}

//#pragma mark - public
//重新设置ConversationTab上的Badge
- (void)showConversationTabBadge
{
    UIViewController *vc = self.childViewControllers[0];
    if([USERMANAGER isLogin]){
        int unreadCount = [DBHELPER getChatTotalUnreadCount];
        
        if (unreadCount > 0) {
            vc.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        } else {
            vc.tabBarItem.badgeValue = nil;
        }
        UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber = unreadCount;
    } else {
        vc.tabBarItem.badgeValue = nil;
        UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber = 0;
    }
}


@end
