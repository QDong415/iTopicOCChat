//
//  UserResponse.h
//  pinpin
//
//  Created by DongJin on 15-2-11.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "BaseResponse.h"
#import "UserModel.h"
@interface UserResponse : BaseResponse
@property (strong, nonatomic) UserModel<Optional> *data;
@end
