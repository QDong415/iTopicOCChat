//
//  RegisterViewController.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "RegisterMobileViewController.h"
#import "UIImage+AFCommon.h"
#import "RegisterInfoViewController.h"
#import "LoginViewController.h"
#import "FindPasswordViewController.h"
#import "ValueUtil.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import "SimpleWebViewController.h"
#import "UserResponse.h"

@interface RegisterMobileViewController ()<UITextFieldDelegate>
{
    IBOutlet UIButton    *_nextButton;
    
    IBOutlet UILabel    *_loginLabel;
    
    IBOutlet UILabel *_agreementLabel;
    IBOutlet UILabel *_passwordLabel;
    IBOutlet UITextField *_passwordTextField;
    
    IBOutlet UILabel    *_titleLabel;
    IBOutlet UIView    *_lineView1;
    IBOutlet UIView    *_lineView2;
        IBOutlet UIView    *_lineView3;
        IBOutlet UIView    *_lineView4;
}

@end

@implementation RegisterMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.view.backgroundColor = [UIColor colorNamed:@"white"];
        _titleLabel.textColor = [UIColor colorNamed:@"black_white"];
        _loginLabel.textColor = [UIColor colorNamed:@"text_gray"];
        _agreementLabel.textColor = [UIColor colorNamed:@"text_gray"];
        _passwordTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        self.codeTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        self.phoneTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        _lineView1.backgroundColor = [UIColor colorNamed:@"text_gray"];
        _lineView2.backgroundColor = [UIColor colorNamed:@"text_gray"];
         _lineView3.backgroundColor = [UIColor colorNamed:@"text_gray"];
         _lineView4.backgroundColor = [UIColor colorNamed:@"text_gray"];
    }
    
    int viewControllersCount = (int)[self.navigationController.viewControllers count];
    if (viewControllersCount == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 28, 28);
        [button setBackgroundImage:[UIImage imageNamed:@"navigationbar_close"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"navigationbar_close_highlighted"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        //创建关闭按钮
        UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
        self.navigationItem.leftBarButtonItem=homeButtonItem;
    }
    
    _loginLabel.userInteractionEnabled=YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toLogin:)];
    [_loginLabel addGestureRecognizer:labelTapGestureRecognizer];
    
    
    NSString * showText = @"注册即表示同意服务协议和隐私政策";
    NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:showText];
    [attString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(7, 4)];
    [attString addAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:NSMakeRange(12, 4)];
    _agreementLabel.attributedText = attString;
    
    __weak RegisterMobileViewController *weakSelf = self;
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
    
    _nextButton.layer.masksToBounds = YES;
    _nextButton.layer.cornerRadius = 5.0f;
    
//        if (!CONFIGMANAGER.app_reviewing) {
//            _thirdView = [[[UINib nibWithNibName:@"ThirdView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
//            _thirdView.frame = CGRectMake(0, SCREEN_HEIGHT - 165, SCREEN_WIDTH, 165);
//            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleWechatTap:)];
//            _thirdView.wechatView.userInteractionEnabled = YES;
//            [_thirdView.wechatView addGestureRecognizer:singleTap];
//            [self.view addSubview:_thirdView];
//        }

}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toLogin:(UITapGestureRecognizer *)recognizer
{
    int viewControllersCount = (int)[self.navigationController.viewControllers count];
    
    //当前堆栈里有 两个以上的vc，从前一个vc开始遍历
    for (int i = viewControllersCount - 2 ; i >= 0; i--) {
        if ([self.navigationController.viewControllers[i] isKindOfClass:[LoginViewController class]]) {
            
            LoginViewController *loginVC = self.navigationController.viewControllers[i];
            
            [self.navigationController popToViewController:loginVC animated:YES];
            return;
        }
    }
    
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

- (void)findpassword:(UITapGestureRecognizer *)recognizer
{
    FindPasswordViewController *vc = [[FindPasswordViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//一键注册，这是本demo为了方便用户注册，实际开发正式app请删除这些代码
- (IBAction)autoreg
{
    [self downTheKeyboard];
    
    NSDate* dat = [NSDate date];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%d", (int)a];
    NSString *mobileend = [timeString substringFromIndex:timeString.length - 9];
    NSString *mobile = [NSString stringWithFormat:@"1%@%d",mobileend,arc4random() % 10];
    
    RegisterInfoViewController* ivc = [[RegisterInfoViewController alloc] init];
    ivc.mobile = mobile;
    ivc.autoreg = YES;
    ivc.password = @"123";
    [self.navigationController pushViewController:ivc animated:YES];
    
}

// 点击下一步按钮
- (IBAction)nextRegister {
    
    if ([ValueUtil isEmptyString:self.phoneTextField.text]) {
        [self.phoneTextField becomeFirstResponder];
        return;
    }
    if ([ValueUtil isEmptyString:self.codeTextField.text]) {
        [self.codeTextField becomeFirstResponder];
        return;
    }
    if ([ValueUtil isEmptyString:_passwordTextField.text]) {
        [_passwordTextField becomeFirstResponder];
        return;
    }
    
    [self checkVerificationSuccess];
}

//验证码效验正确，由子类重写该方法，注意此时ProgressHUD并没关闭
- (void)checkVerificationSuccess
{
    RegisterInfoViewController* ivc = [[RegisterInfoViewController alloc] init];
    ivc.mobile = self.lastMobile;
    ivc.code = [self lastCode];
    ivc.password = _passwordTextField.text;
    [self.navigationController pushViewController:ivc animated:YES];
}


@end

