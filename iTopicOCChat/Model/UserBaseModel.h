//
//  UserBaseModel.h
//  iTopic
//
//  Created by DongJin on 15-8-30.
//  Copyright (c) 2015年 DongQi. All rights reserved.
//

#import "JSONModel.h"

@protocol UserBaseModel
@end
@interface UserBaseModel : JSONModel

@property (strong, nonatomic) NSString *userid;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *avatar;
@property (assign, nonatomic) int open_time;
@property (assign, nonatomic) double latitude;//通过接口直接返回
@property (assign, nonatomic) double longitude;
@property (assign, nonatomic) int follow;

@property (strong, nonatomic) NSString *cityid;//110000 or 411500
@property (strong, nonatomic) NSString *cityname;//北京市

@property (assign, nonatomic) int gender;//0未填 1男 2女
@property (assign, nonatomic) int age;//@“14”
@property (assign, nonatomic) int vip;//0 or 1 

@end
