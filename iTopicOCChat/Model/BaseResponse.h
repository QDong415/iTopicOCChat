//
//  TopicModel.h
//  tabbarDemo
//
//  Created by DongJin on 14-12-9.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import "JSONModel.h"
@interface BaseResponse  : JSONModel
{
}

@property (assign, nonatomic) int code;
@property (strong, nonatomic) NSString* message;
- (BOOL)isSuccess;
- (id)initWithError;
@end
