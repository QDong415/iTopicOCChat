//
//  AppDelegate.m
//  iTopic
//
//  Created by DongJin on 15-7-8.
//  Copyright (c) 2015年 DongQi. All rights reserved.
//

#import "AppDelegate.h"
#import "RegisterMobileViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "MainViewController.h"
#import "VideoChatViewController.h"
#import "MessageManager.h"
#import "CallManager.h"
#import "UIImage+LLExt.h"
#import <UMCommon/UMCommon.h>
#import <UMVerify/UMVerify.h>
#import "FaceManager.h"
#import "UIColor+QMUI.h"
#import "ValueUtil.h"
#import "DBHelper.h"
#import "RealReachability.h"
#import <GTSDK/GeTuiSdk.h>     //个推头文件应用

#import "RealReachability.h"
#import "AFNetworkReachabilityManager.h"

#import <AudioToolbox/AudioToolbox.h>

// iOS 10 及以上环境，需要添加 UNUserNotificationCenterDelegate 协议，才能使用 UserNotifications.framework 的回调
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<GeTuiSdkDelegate,UNUserNotificationCenterDelegate>
{
    MainViewController *_mainController;
    
    AFNetworkReachabilityStatus _lastNetworkStatus;//上次的网络状态
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc ]initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];

    if (@available(iOS 13.0, *)) {
        int interface = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"interface"];
        if (interface == 1){
            //固定白天模式
            AppDelegate *mAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            mAppDelegate.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
        } else if (interface == 2){
            //固定黑夜模式
            AppDelegate *mAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            mAppDelegate.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
        }
    }
    
    //导航条深色
//    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    //导航栏透明
    [[UINavigationBar appearance] setTranslucent:YES];

    if (@available(iOS 11.0, *)) {
        [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor colorNamed:@"separator235"] size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
        
        //返回键字体颜色
        [[UINavigationBar appearance] setTintColor:[UIColor colorNamed:@"text_black_gray"]];
        self.window.backgroundColor = [UIColor colorNamed:@"white"];
        
    } else {
        [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:COLOR_DIVIDER_RGB size:CGSizeMake(SCREEN_WIDTH, 0.5)]];
        
        //返回键字体颜色
        [[UINavigationBar appearance] setTintColor:COLOR_BLACK_RGB];
        // 尽量用白而不是clear，不然导航栏跳转时候会出现黑色
        self.window.backgroundColor = [UIColor whiteColor];
    }
    
    //友盟
    [UMConfigure initWithAppkey:@"55c95d2ce0f55af81d0030c8" channel:@"AppStore"];
    
    // 注册 APNs
    [self registerRemoteNotification];
    [GLobalRealReachability startNotifier];

    //展开数据库
    DBHELPER;
    //初始化表情
    FACEMANAGER;
    
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    
    [GeTuiSdk runBackgroundEnable:YES];
    
    //初始化友盟的手机号一键登录 itopic
    [UMCommonHandler setVerifySDKInfo:@"1UWimedGsIdE+QN5W64PrfUzfCUY8Cj6xv5lblcD8yLIVFuQUxYL5A3g1fMmL4X42cq8pRbg/DGA7aGcNQZ1ctMRZM1NYfNt8t94UefeCl9Ehf3nGfL0bo78JnCltL0VLETse0LW8OUdWYY27Heq8Hhz/CDmUoAQGvbikqle8CnoH+cBL6RjwEv1iiUaozuG7wHV2WJwCtIJ3NmduofT0zMq9+xoR2SAv3xjbSdbhRE2juRziMtR78tCIJvT9Q5zqfAV5KiToD8=" complete:^(NSDictionary * _Nonnull resultDic) {
        // dq测试发现，这里是异步的，子线程，耗时0.3秒；即便手机无网络权限，也可以成功
        NSLog(@"setVerifySDKInfo完成");
//        [weakSelf showResult:resultDic];
    }];
    
    [self prepareUMAccelerateLogin];
    
    //监听网络
    AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
    [netManager startMonitoring];  //开始监听
    [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusNotReachable){
            NSLog(@"Reachability NotReachable");
        }else if (status == AFNetworkReachabilityStatusUnknown){
            NSLog(@"Reachability sUnknown");
        }else if ((status == AFNetworkReachabilityStatusReachableViaWWAN)||(status == AFNetworkReachabilityStatusReachableViaWiFi)){
            NSLog(@"Reachability wifi");
            if (_lastNetworkStatus == AFNetworkReachabilityStatusNotReachable || _lastNetworkStatus == AFNetworkReachabilityStatusUnknown) {
                //上次的网络状态是未连接，现在有网络可以连接了，重置定位引擎
                [_mainController reloadDataIfEmpty];
//                [self performSelector:@selector(reloadDataIfEmpty) withObject:nil/*可传任意类型参数*/ afterDelay:0.2];
                [self prepareUMAccelerateLogin];
            }
        }
        _lastNetworkStatus = status;
    }];
    
    _mainController = [[MainViewController alloc] init];
    
    self.window.rootViewController = _mainController;
    
    return YES;
}

- (void)prepareUMAccelerateLogin
{
    if (_supportUMAccelerateLogin) {
        return;
    }
    // 检测当前环境是否支持一键登录，支不支持提前知道 (UMPNSAuthTypeLoginToken 检查一键登录环境 UMPNSAuthTypeVerifyToken 检查号码认证环境)
    WEAKSELF
    [UMCommonHandler checkEnvAvailableWithAuthType:UMPNSAuthTypeLoginToken complete:^(NSDictionary * _Nullable resultDic) {
        weakSelf.supportUMAccelerateLogin = [PNSCodeSuccess isEqualToString:[resultDic objectForKey:@"resultCode"]];
        //dq测试发现，如果手机当前没网络权限，supportUMAccelerateLogin == NO；
        NSLog(@"supportUMAccelerateLogin-%@",weakSelf.supportUMAccelerateLogin?@"1":@"0");
    }];
    
    //1. 调用取号接口，加速授权页的弹起
    [UMCommonHandler accelerateLoginPageWithTimeout:6 complete:^(NSDictionary * _Nonnull resultDic)  {
        // dq测试发现，这里是异步的?，主线程，耗时0.7秒
        if ([PNSCodeSuccess isEqualToString:[resultDic objectForKey:@"resultCode"]] == NO) {
            //dq测试发现，如果手机当前没网络权限，就进入这里
            NSLog(@"预取号失败");
        } else {
            NSLog(@"预取号success");
        }
    }];
}

/** 注册 APNs */
- (void)registerRemoteNotification {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionCarPlay) completionHandler:^(BOOL granted, NSError *_Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        UIUserNotificationType types = (UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}


//注册用户通知设置
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 * 推送处理3
 */
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // [3]:向个推服务器注册deviceToken 为了方便开发者，建议使用新方法
    [GeTuiSdk registerDeviceTokenData:deviceToken];
}


#pragma mark - APP运行中接收到通知(推送)处理 - iOS 10以下版本收到推送
/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    // 控制台打印接收APNs信息
    NSLog(@"\n>>>[Receive RemoteNotification]:%@\n\n", userInfo);
    [self pushToNotityViewController:userInfo[@"payload"]];
    completionHandler(UIBackgroundFetchResultNewData);
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
//  iOS 10: App在前台获取到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"App在前台获取到通知：%@", notification.request.content.userInfo);
    [self pushToNotityViewController:notification.request.content.userInfo[@"payload"]];
    // 根据APP需要，判断是否要提示用户Badge、Sound、Alert
    completionHandler(UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

//  iOS 10: 点击通知进入App时触发，在该方法内统计有效用户点击数
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    
    NSLog(@"点击通知进入App时触发：%@", response.notification.request.content.userInfo);
    [self pushToNotityViewController:response.notification.request.content.userInfo[@"payload"]];
    
    // [ GTSdk ]：将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:response.notification.request.content.userInfo];
    
    completionHandler();
}
#endif


#pragma mark - private
- (void)pushToNotityViewController:(id)payload
{
}

/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    NSLog(@"[个推启动成功返回cid RegisterClient]:%@", clientId);
    [USERMANAGER checkCidAndUpdate:nil];
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    // [ GTSdk ]：汇报个推自定义事件(反馈透传消息)
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
    
    //收到个推消息
    if (payloadData) {
        NSDictionary *payloadDictionary = [NSJSONSerialization JSONObjectWithData:payloadData options:0 error:nil];
        switch ([payloadDictionary[@"type"] intValue]) {
                //下面这3种类型的，needpull都是0
            case PUSH_TYPE_REMIND_COMMENT:
               
                break;
            case PUSH_TYPE_REMIND_PRAISE:
                break;
            case PUSH_TYPE_REMIND_FANS:
                break;
            case PUSH_TYPE_REMIND_AT:
                break;
            case PUSH_TYPE_REMIND_SYSYEM:
                //废弃
//                [REMINDMANAGER insertNewArticleSingleRemind:payloadDictionary[@"dataid"]];
                break;
            case PUSH_TYPE_CALL_REFUSE:{
                
                CallManager *callManager = [CallManager sharedCallManager];
                if([payloadDictionary[@"channelid"] isEqualToString:callManager.channelId]){
                    //推送来的被拒绝的channelid 就是当期那的channelid
                    [callManager oppoRefuseMyDialing];
                } else {
                    //不出bug情况下不会进入这里
                }
            }
                break;
                
            default:
                //说明是聊天消息，聊天消息不处理，由needpull处理
                break;
        }
        
        if([@"1" isEqualToString:payloadDictionary[@"needpull"]]){
            [NSObject cancelPreviousPerformRequestsWithTarget:self];
            [self performSelector:@selector(pullMesssages) withObject:nil afterDelay:0.3];
        } else {
            NSMutableArray *newMessagesTypes = [NSMutableArray arrayWithObject:[NSNumber numberWithInt:[payloadDictionary[@"type"] intValue]]];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGES_RECEIVE object:newMessagesTypes];
        }
    }
    if(!offLine){
        UserModel *userModel = [USERMANAGER userModel];
        if(userModel.slience == 0)
            AudioServicesPlaySystemSound(1012);
    }
    
//    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@",taskId,msgId,offLine ? @"<离线消息>" : @""];
//    NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
}

- (void)pullMesssages{
    [MESSAGEMANAGER pullMesssages];
}

/**
 * 推送处理4
 */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
}


// NOTE: 9.0之前使用的API接口
//如果您使用了红包等融云的第三方扩展，请实现下面两个openURL方法
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return YES;
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString*, id> *)options
{
    return YES;
}

#pragma mark - public 获取当前正在活动中的的VC（仅仅为了网络返回值code==3情况下踢出用户并跳转登录界面）
- (UIViewController *)activityViewController {
    __block UIWindow *normalWindow = [self window];
    if (normalWindow.windowLevel != UIWindowLevelNormal) {
        [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(__kindof UIWindow * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.windowLevel == UIWindowLevelNormal) {
                normalWindow = obj;
                *stop        = YES;
            }
        }];
    }
    return [self p_nextTopForViewController:normalWindow.rootViewController];
}

- (UIViewController *)p_nextTopForViewController:(UIViewController *)inViewController {
    while (inViewController.presentedViewController) {
        inViewController = inViewController.presentedViewController;
    }
    
    if ([inViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = [self p_nextTopForViewController:((UITabBarController *)inViewController).selectedViewController];
        return selectedVC;
    } else if ([inViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *selectedVC = [self p_nextTopForViewController:((UINavigationController *)inViewController).visibleViewController];
        return selectedVC;
    } else {
        return inViewController;
    }
}


@end
