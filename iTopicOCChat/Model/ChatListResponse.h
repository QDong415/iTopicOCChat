//
//  SquareMemberListResponse.h
//  pinpin
//
//  Created by DongJin on 15-2-28.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//


#import "BaseResponse.h"
#import "BasePageModel.h"
#import "ChatModel.h"

@interface ChatListResponse : BaseResponse
{
}
@property (strong, nonatomic) NSArray<ChatModel>  *data;
@end
