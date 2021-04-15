//
//  SquareMemberListResponse.h
//  pinpin
//
//  Created by DongJin on 15-2-28.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//


#import "BaseResponse.h"
#import "BasePageModel.h"
#import "UserBaseModel.h"



@interface UserBaseListData : BasePageModel
{
}
@property (strong, nonatomic) NSArray<UserBaseModel> *items;
@end

@interface UserBaseListResponse : BaseResponse
{
}
@property (strong, nonatomic) UserBaseListData<Optional>  *data;
@end
