//
//  RegisterViewController.m
//
//  Created by DQ 285275534@qq.com on 16-4-6.
//
#import "SMSBaseViewController.h"
#import "BaseResponse.h"

@interface SMSBaseViewController ()<UITextFieldDelegate>
{
    IBOutlet UIButton    *_codeButton;
    NSTimer              *_countTimer;
    int                   _count;
}
@end

@implementation SMSBaseViewController

- (void)startTimer
{
    if (!_countTimer) {
        _count = 60;
        _codeButton.userInteractionEnabled = NO;
        [self count];
        _countTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(count) userInfo:nil repeats:YES];
    }
}

- (void)stopTimer
{
    if ([_countTimer isValid]) {
        [_countTimer invalidate];
    }
    _countTimer = nil;
    _codeButton.userInteractionEnabled = YES;
    [_codeButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

- (void)count
{
    [_codeButton setTitle:[NSString stringWithFormat:@"%d秒后刷新",_count] forState:UIControlStateNormal];
    _count--;
    if (_count < 0) {
        [self stopTimer];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self downTheKeyboard];
    [self stopTimer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

- (IBAction)getCaptcha {

    [_phoneTextField resignFirstResponder];
    
    if (_phoneTextField.text.length < 8) {
        [_phoneTextField becomeFirstResponder];
        [ProgressHUD showError:@"请输入手机号"];
        return;
    }
    
    [_codeTextField becomeFirstResponder];
    
    _lastMobile = _phoneTextField.text;
    
    [ProgressHUD show:@"请稍候..."];
    
    [self requestVerificationCode:NO];
    
}

- (void)requestVerificationCode:(BOOL)isVoice
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:_phoneTextField.text,@"mobile", nil];
    [NETWORK postDataByApi:@"account/coderequire" parameters:dictionary responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
        BaseResponse* result = (BaseResponse *)responseObject;
        [ProgressHUD dismiss];
        if ([result isSuccess]) {
            //@"获取验证码成功"
            [self startTimer];
        } else {
            [ProgressHUD showError:result.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
    }];
}

//检查验证码，之后会触发
- (void)checkVerificationCode
{
    [self downTheKeyboard];
    if (_phoneTextField.text.length != 11) {
        [_phoneTextField becomeFirstResponder];
        [ProgressHUD showError:@"请输入正确的手机号"];
        return;
    }
    if (_codeTextField.text.length == 0) {
        [_codeTextField becomeFirstResponder];
        [ProgressHUD showError:@"请输入正确的验证码"];
        return;
    }
    
    [ProgressHUD show:@"请稍候..."];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:_phoneTextField.text,@"mobile",_codeTextField.text,@"code", nil];
    
    [NETWORK postDataByApi:@"account/validatecode" parameters:dictionary responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
        BaseResponse* response = (BaseResponse *)responseObject;
        if ([response isSuccess]) {
            //验证码效验正确，由子类重写该方法，注意此时ProgressHUD并没关闭
            [self checkVerificationSuccess];
        } else {
            [ProgressHUD dismiss];
            [ProgressHUD showError:response.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
    }];
    
}

//验证码效验正确，由子类重写该方法，注意此时ProgressHUD并没关闭
- (void)checkVerificationSuccess{}

//验证码效验失败，由子类重写该方法
//- (void)checkVerificationFail:(NSString *)errorMessage{}


- (NSString *)lastMobile{
    return _lastMobile?:_phoneTextField.text;
}

- (NSString *)lastCode{
    return _codeTextField.text;
}

@end

