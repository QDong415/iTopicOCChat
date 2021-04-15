//
//  SquareMemberListResponse.h
//  pinpin
//
//  Created by DongJin on 15-2-28.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//


#import "BaseResponse.h"
#import "BasePageModel.h"

@interface DictionaryListData : BasePageModel
{
}
@property (strong, nonatomic) NSArray<NSDictionary *> *items;
@end

@interface DictionaryListResponse : BaseResponse
{
}
@property (strong, nonatomic) DictionaryListData<Optional>  *data;
@end
