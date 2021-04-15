//
//  RegisterViewController.h
//  pinpin
//
//  Created by DQ 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "BaseViewController.h"

@interface SMSBaseViewController : BaseViewController

@property (strong, nonatomic) NSString *lastMobile;

@property (strong, nonatomic) IBOutlet UITextField *phoneTextField;
@property (strong, nonatomic) IBOutlet UITextField *codeTextField;

- (void)downTheKeyboard;
- (void)checkVerificationCode;
- (NSString *)lastCode;

//用户最后一次点 获取验证码 按钮时候的手机号

@end
