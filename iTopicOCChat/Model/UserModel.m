//
//  UserModel.m
//  pinpin
//
//  Created by DongJin on 15-2-11.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

//jsonmodel 设置所有的属性为可选(所有属性值可以为空)
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
