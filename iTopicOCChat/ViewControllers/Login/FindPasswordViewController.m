//
//  RegisterViewController.m
//  pinpin
//
//  Created by DQ 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "BaseResponse.h"
@interface FindPasswordViewController ()<UITextFieldDelegate>
{
    IBOutlet UILabel    *_titleLabel;
    IBOutlet UIView    *_lineView1;
    IBOutlet UIView    *_lineView2;
        IBOutlet UIView    *_lineView3;
        IBOutlet UIView    *_lineView4;
    
    IBOutlet UIButton    *_nextButton;
    IBOutlet UITextField *_passwordTextField;
}
@end

@implementation FindPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    if (@available(iOS 11.0, *)) {
        self.view.backgroundColor = [UIColor colorNamed:@"white"];
        _titleLabel.textColor = [UIColor colorNamed:@"black_white"];
   
        _passwordTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        self.codeTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        self.phoneTextField.textColor = [UIColor colorNamed:@"text_black_gray"];
        _lineView1.backgroundColor = [UIColor colorNamed:@"text_gray"];
        _lineView2.backgroundColor = [UIColor colorNamed:@"text_gray"];
         _lineView3.backgroundColor = [UIColor colorNamed:@"text_gray"];
         _lineView4.backgroundColor = [UIColor colorNamed:@"text_gray"];
    }
    
    _nextButton.layer.masksToBounds = YES;
    _nextButton.layer.cornerRadius = 5.0f;
}

- (void)downTheKeyboard
{
    [super downTheKeyboard];
    [_passwordTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)nextRegister {
   
    if (_passwordTextField.text.length == 0) {
        [_passwordTextField becomeFirstResponder];
        [ProgressHUD showError:@"密码不能为空"];
        return;
    }else if (_passwordTextField.text.length > 30){
        [_passwordTextField becomeFirstResponder];
        [ProgressHUD showError:@"密码不能超过30个字符"];
        return;
    }
    
    [self checkVerificationSuccess];
}

//验证码效验正确，由子类重写该方法，注意此时ProgressHUD并没关闭
- (void)checkVerificationSuccess
{
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:_passwordTextField.text forKey:@"password"];
    [params setObject:self.lastMobile forKey:@"mobile"];
    [params setObject:[self lastCode] forKey:@"code"];

    [NETWORK postDataByApi:@"account/findpw" parameters:params responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
        [ProgressHUD dismiss];
        BaseResponse* result = (BaseResponse*)responseObject;
        if ([result isSuccess]) {
            [ProgressHUD showSuccess:@"密码重置成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [ProgressHUD showError:result.message];
        }
        
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
    }];
}



@end

