//
//  SquareMemberListResponse.h
//  pinpin
//
//  Created by DongJin on 15-2-28.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//


#import "BaseResponse.h"
#import "BasePageModel.h"


@interface StringListData : BasePageModel
{
}
@property (strong, nonatomic) NSArray<NSString *> *items;
@end

@interface StringListResponse : BaseResponse
{
}
@property (strong, nonatomic) StringListData<Optional>  *data;
@end
