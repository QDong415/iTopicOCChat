//
//  BasePagerData.m
//  tabbarDemo
//
//  Created by DongJin on 14-12-9.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import "BasePageModel.h"

@implementation BasePageModel
- (BOOL)hasMore
{
    return [_totalpage intValue] > [_currentpage intValue];
}
@end
