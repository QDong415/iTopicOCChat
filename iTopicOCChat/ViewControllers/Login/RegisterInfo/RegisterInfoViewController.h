//
//  RegisterInfoViewController.h
//  xiucai
//
//  Created by DongJin on 15-1-2.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import "BasePhotoViewController.h"
@interface RegisterInfoViewController : BasePhotoViewController

@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *code;
@property (assign, nonatomic) BOOL autoreg;


@property (strong, nonatomic) NSString *qqid;//如果是第3方登录的，会有默认姓名
@property (strong, nonatomic) NSString *unionid;//如果是第3方登录的，会有默认姓名
@property (strong, nonatomic) NSString *name;//如果是第3方登录的，会有默认姓名
@property (strong, nonatomic) NSString *photoUrl;//头像链接（如果是相册选取的就不是http开头，如果是第3方登录的，带http开头）


@end
