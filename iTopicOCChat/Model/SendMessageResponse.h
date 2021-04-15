//
//  IntResponse.h
//  pinpin
//
//  Created by DongJin on 15-3-24.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "BaseResponse.h"

@interface SendMessageResponse : BaseResponse
@property (strong, nonatomic) NSString<Optional> *targetid;
@property (strong, nonatomic) NSString<Optional> *client_messageid;
@end
