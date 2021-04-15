//
//  UserBaseModel.m
//  iTopic
//
//  Created by DongJin on 15-8-30.
//  Copyright (c) 2015年 DongQi. All rights reserved.
//

#import "UserBaseModel.h"
#import "ValueUtil.h"

@implementation UserBaseModel

//jsonmodel 设置所有的属性为可选(所有属性值可以为空)
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
