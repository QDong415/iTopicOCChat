//
//  TopicModel.m
//  tabbarDemo
//
//  Created by DongJin on 14-12-9.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import "BaseResponse.h"

@implementation BaseResponse

- (BOOL)isSuccess
{
    return _code==1;
}

- (id) initWithError {
    self = [super init];
    if (self) {
       _message = @"网络访问失败";
    }
    return self;
}

@end
