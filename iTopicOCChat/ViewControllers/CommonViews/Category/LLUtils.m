//
//  LLUtils.m
//  LLWeChat
//
//  Created by GYJZH on 7/17/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLUtils.h"

@interface LLUtils ()

@end


@implementation LLUtils

+ (instancetype)sharedUtils {
    static LLUtils *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLUtils alloc] init];
    });
    
    return _instance;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end











