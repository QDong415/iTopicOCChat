//
//  RegisterViewController.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "LoginViewController.h"
#import "UIImage+AFCommon.h"
#import "RegisterMobileViewController.h"
#import "UserResponse.h"
#import "ValueUtil.h"
#import "FindPasswordViewController.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import "SimpleWebViewController.h"
#import "ThirdView.h"
#import "RegisterInfoViewController.h"

@interface LoginViewController ()<UITextFieldDelegate>
{
    IBOutlet UIButton    *_nextButton;
    IBOutlet UITextField *_phoneTextField;
    IBOutlet UITextField *_codeTextField;
    IBOutlet UILabel    *_regLabel;
    IBOutlet UILabel    *_forgetLabel;
    IBOutlet UILabel    *_agreementLabel;
    
    IBOutlet UILabel    *_titleLabel;
    IBOutlet UIView    *_lineView1;
    IBOutlet UIView    *_lineView2;
    
    ThirdView *_thirdView;
}
@end

@implementation LoginViewController

- (void)awakeFromNib {

    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.view.backgroundColor = [UIColor colorNamed:@"white"];
        _titleLabel.textColor = [UIColor colorNamed:@"black_white"];
        _regLabel.textColor = [UIColor colorNamed:@"text_gray"];
        _forgetLabel.textColor = [UIColor colorNamed:@"text_gray"];
        _phoneTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        _codeTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        _agreementLabel.textColor = [UIColor colorNamed:@"text_gray"];
        _lineView1.backgroundColor = [UIColor colorNamed:@"text_gray"];
        _lineView2.backgroundColor = [UIColor colorNamed:@"text_gray"];
    }
    
    int viewControllersCount = (int)[self.navigationController.viewControllers count];
    if (viewControllersCount == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 28, 28);
        [button setBackgroundImage:[UIImage imageNamed:@"navigationbar_close"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"navigationbar_close_highlighted"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
                self.navigationItem.leftBarButtonItem = homeButtonItem;
    }
    
    //设置导航栏透明
    [self.navigationController.navigationBar setTranslucent:true];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    _regLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toReg:)];
    [_regLabel addGestureRecognizer:labelTapGestureRecognizer];
    
    _forgetLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toForget:)];
    [_forgetLabel addGestureRecognizer:labelTapGestureRecognizer2];
    
    NSString * showText = @"登录即表示同意服务协议和隐私政策";
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:showText];
    [attString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(7, 4)];
    [attString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(12, 4)];
    _agreementLabel.attributedText = attString;
    
    __weak LoginViewController *weakSelf = self;
    [_agreementLabel yb_addAttributeTapActionWithStrings:@[@"服务协议",@"隐私政策"] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        SimpleWebViewController *vc = [[SimpleWebViewController alloc]init];
        if (index == 0) {
            vc.URLString = [NSString stringWithFormat:@"%@home/article/agreement?agreementid=1",HTTP_URL];
            vc.title = @"用户协议";
        } else {
            vc.URLString = [NSString stringWithFormat:@"%@home/article/agreement?agreementid=2",HTTP_URL];
            vc.title = @"隐私政策";
        }
        
        vc.hidesBottomBarWhenPushed = YES;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        [weakSelf presentViewController:nc animated:YES completion:nil];
    }];
    
//    if (!CONFIGMANAGER.app_reviewing) {
//        _thirdView = [[[UINib nibWithNibName:@"ThirdView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
//        _thirdView.frame = CGRectMake(0, SCREEN_HEIGHT - 165, SCREEN_WIDTH, 165);
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleWechatTap:)];
//        _thirdView.wechatView.userInteractionEnabled = YES;
//        [_thirdView.wechatView addGestureRecognizer:singleTap];
//        [self.view addSubview:_thirdView];
//    }
    

}

- (void)navigationShadow
{
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)toReg:(UITapGestureRecognizer *)recognizer
{
    int viewControllersCount = (int)[self.navigationController.viewControllers count];
    
    //当前堆栈里有 两个以上的vc，从前一个vc开始遍历
    for (int i = viewControllersCount - 2 ; i >= 0; i--) {
        if ([self.navigationController.viewControllers[i] isKindOfClass:[RegisterMobileViewController class]]) {
            
            RegisterMobileViewController *regVC = self.navigationController.viewControllers[i];
            
            [self.navigationController popToViewController:regVC animated:YES];
            return;
        }
    }
    
    RegisterMobileViewController *regVC = [[RegisterMobileViewController alloc]init];
    [self.navigationController pushViewController:regVC animated:YES];
}

- (IBAction)toForget:(UITapGestureRecognizer *)recognizer
{
    FindPasswordViewController *findVc = [[FindPasswordViewController alloc]init];
    [self.navigationController pushViewController:findVc animated:YES];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self downTheKeyboard];
}

- (void)downTheKeyboard
{
    [_phoneTextField resignFirstResponder];
    [_codeTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_phoneTextField]) {
        [_codeTextField becomeFirstResponder];
    }else{
        [_codeTextField resignFirstResponder];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)nextRegister {
    [self downTheKeyboard];
    if (_phoneTextField.text.length != 11) {
        [_phoneTextField becomeFirstResponder];
        [ProgressHUD showError:@"请输入正确的手机号"];
        return;
    }
    if (_codeTextField.text.length == 0 || _codeTextField.text.length > 30) {
        [_codeTextField becomeFirstResponder];
        [ProgressHUD showError:@"请输入正确的密码"];
        return;
    }
    
    [ProgressHUD show:@"登录中..."];
    
    NSString *pwd = _codeTextField.text ;
    
    NSMutableDictionary* paramDictionary = [NSMutableDictionary new];
    [paramDictionary setObject:_phoneTextField.text forKey:@"mobile"];
    [paramDictionary setObject:pwd forKey:@"password"];
    
    [NETWORK postDataByApi:@"account/login" parameters:paramDictionary responseClass:[UserResponse class] success:^(NSURLSessionTask *task, id responseObject){
        
        UserResponse* result = (UserResponse *)responseObject;
        
        if ([result isSuccess]) {
            //访问login或者reg网络成功 处理我们自己的逻辑
            [USERMANAGER loginRequiteSuccess:result.data];
            
            [ProgressHUD dismiss];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            [ProgressHUD dismiss];
            [ProgressHUD showError:result.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
    }];
}


@end

