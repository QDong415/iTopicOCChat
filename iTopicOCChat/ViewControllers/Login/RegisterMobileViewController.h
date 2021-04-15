//
//  RegisterViewController.h
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "SMSBaseViewController.h"

@interface RegisterMobileViewController : SMSBaseViewController

@property (strong, nonatomic) NSString *openid;//如果是第3方登录的，会有默认姓名
@property (strong, nonatomic) NSString *name;//如果是第3方登录的，会有默认姓名
@property (strong, nonatomic) NSString *photoUrl;//头像链接（如果是相册选取的就不是http开头，如果是第3方登录的，带http开头）

@end
