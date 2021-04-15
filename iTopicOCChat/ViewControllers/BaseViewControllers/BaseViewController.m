//
//  BaseViewController.m
//  ShowSecret
//
//  Created by QDong Email: 285275534@qq.com on 14-9-29.
//  Copyright (c) 2014年 ibluecollar. All rights reserved.
//

#import "BaseViewController.h"
#import "LoginViewController.h"

#import <UMVerify/UMVerify.h>
#import "UMModelCreate.h"
#import "BaseResponse.h"
#import "DictionaryResponse.h"
#import "RegisterInfoViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self didInitialized];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitialized];
    }
    return self;
}

- (void)didInitialized {
    // 不管navigationBar的backgroundImage如何设置，都让布局撑到屏幕顶部，方便布局的统一
    self.extendedLayoutIncludesOpaqueBars = YES;
}

-(AppDelegate *)getAppDelegate
{
    return (AppDelegate *)[UIApplication   sharedApplication].delegate;
}

- (BOOL)checkLogined
{
    if ([USERMANAGER isLogin]) {
        return YES;
    }
    
    AppDelegate *mAppDelegate = [self getAppDelegate];
    if (mAppDelegate.supportUMAccelerateLogin) {
        UMCustomModel *model = [UMModelCreate createFullScreen];
        
        [UMCommonHandler getLoginTokenWithTimeout:6 controller:self model:model complete:^(NSDictionary * _Nonnull resultDic) {
            NSString *code = [resultDic objectForKey:@"resultCode"];
            if ([PNSCodeLoginControllerPresentSuccess isEqualToString:code]) {
//                [ProgressHUD showSuccess:@"弹起授权页成功"];
            } else if ([PNSCodeLoginControllerClickCancel isEqualToString:code]) {
//                [ProgressHUD showSuccess:@"点击了授权页的返回"];
            } else if ([PNSCodeLoginControllerClickChangeBtn isEqualToString:code]) {
                [UMCommonHandler cancelLoginVCAnimated:YES complete:nil];
                [self presentLoginVC];
            } else if ([PNSCodeLoginControllerClickLoginBtn isEqualToString:code]) {
//                if ([[resultDic objectForKey:@"isChecked"] boolValue] == YES) {
//                    [ProgressHUD showSuccess:@"点击了登录按钮，check box选中，SDK内部接着会去获取登陆Token"];
//                } else {
//                    [ProgressHUD showSuccess:@"点击了登录按钮，check box选中，SDK内部不会去获取登陆Token"];
//                }
            } else if ([PNSCodeLoginControllerClickCheckBoxBtn isEqualToString:code]) {
//                [ProgressHUD showSuccess:@"点击check box"];
            } else if ([PNSCodeLoginControllerClickProtocol isEqualToString:code]) {
//                [ProgressHUD showSuccess:@"点击了协议富文本"];
            } else if ([PNSCodeSuccess isEqualToString:code]) {
                //点击登录按钮获取登录Token成功回调
                [ProgressHUD show:nil];
                NSString *token = [resultDic objectForKey:@"token"];
                [NETWORK postDataByApi:@"account/ummobile" parameters:@{@"token":token,@"verifyId":[UMCommonHandler getVerifyId]} responseClass:[DictionaryResponse class] success:^(NSURLSessionTask *task, id responseObject){
                    [ProgressHUD dismiss];
                    DictionaryResponse* result = (DictionaryResponse* )responseObject;
                    if ([result isSuccess]) {
                        UserModel *userModel = [[UserModel alloc] initWithDictionary:result.data error:nil];
                        [USERMANAGER loginRequiteSuccess:userModel];
                        [UMCommonHandler cancelLoginVCAnimated:YES complete:nil];
                    } else if ([result code] == 2) {
                        //去完善资料
                        RegisterInfoViewController* ivc = [[RegisterInfoViewController alloc] init];
                        ivc.mobile = result.data[@"mobile"];
                        ivc.code = result.data[@"code"];
                        ivc.hidesBottomBarWhenPushed = YES;
//                        [UMCommonHandler cancelLoginVCAnimated:YES complete:^{
//                            [self.navigationController pushViewController:ivc animated:YES];
//                        }];
                        [UMCommonHandler cancelLoginVCAnimated:YES complete:nil];
                        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ivc];
                        [self presentViewController:nc animated:YES completion:nil];
                        
                    } else {
                        //服务器异常
                        [self presentLoginVC];
                    }
                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    [ProgressHUD dismiss];
                    [self presentLoginVC];
                }];
            } else {
                [self presentLoginVC];
            //      [ProgressHUD showError:@"获取登录Token失败"];
            }
        }];
    } else {
        [self presentLoginVC];
    }
    
    return NO;
}

- (void)presentLoginVC
{
    LoginViewController *pickerVc = [[LoginViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pickerVc];
    [self presentViewController:nc animated:YES completion:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self navigationShadow];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)navigationShadow
{
    if(self.navigationController.viewControllers.count == 1){
        
        //1.设置阴影颜色
        
//        self.navigationController.navigationBar.layer.shadowColor = COLOR_BLACK_RGB.CGColor;
//        
//        //2.设置阴影偏移范围
//        
//        self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 2);
//        
//        //3.设置阴影颜色的透明度
//        
//        self.navigationController.navigationBar.layer.shadowOpacity = 0.2;
//        
//        //4.设置阴影半径
//        
//        self.navigationController.navigationBar.layer.shadowRadius = 3;
//        
//        //5.设置阴影路径
//        
//        self.navigationController.navigationBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.navigationController.navigationBar.bounds].CGPath;
        
        
        
//        UIView *backgroundView = [self.navigationController.navigationBar subviews].firstObject;
//        for (UIView *view in backgroundView.subviews) {
//            NSLog(@"height = %f",CGRectGetHeight([view frame]));
//            if (CGRectGetHeight([view frame]) <= 1) {
//                if (@available(iOS 11.0, *)) {
//                    view.backgroundColor = [UIColor colorNamed:@"white"];
//                } else {
//                    view.backgroundColor = RGBCOLOR(234, 234, 234);
//                }
//            }
//        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
