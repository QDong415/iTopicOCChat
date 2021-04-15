//
//  UserModel.h
//  pinpin
//
//  Created by DongJin on 15-2-11.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "JSONModel.h"

@interface UserModel : JSONModel
@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString<Optional> *mobile;//登录手机号
@property (strong, nonatomic) NSString *name;//真实姓名
@property (strong, nonatomic) NSString<Optional> *avatar;//头像model
@property (strong, nonatomic) NSString<Optional> *intro;//自我介绍
@property (assign, nonatomic) int gender;//0未填 1男 2女
@property (assign, nonatomic) int age;//@“14”
@property (strong, nonatomic) NSString<Optional> *tags;//个人标签，比如 “责任心强”，“上进”
@property (strong, nonatomic) NSString<Optional> *cover;//背景图
@property (strong, nonatomic) NSString<Optional> *cityid;//110000 or 411500
@property (strong, nonatomic) NSString<Optional> *cityname;//北京市

@property (strong, nonatomic) NSString<Optional> *token;//以后每次请求，放到http header里
@property (strong, nonatomic) NSString<Optional> *cid;//个推;

@property (assign, nonatomic) int slience;//0 ==正常收消息，1==静音

//特殊
@property (assign, nonatomic) int topiccount;
@property (assign, nonatomic) int videocount;
@property (assign, nonatomic) int followcount;//关注了几个人
@property (assign, nonatomic) int fanscount;//几个粉丝

//查看他人接口才有
@property (assign, nonatomic) int follow;//0 未关注 1已关注 2被关注 3互相


@end
