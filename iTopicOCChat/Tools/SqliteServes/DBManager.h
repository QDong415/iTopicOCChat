//
//  DBManager.h
//  tabbarDemo
//
//  Created by DongJin on 14-10-24.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

//表名
#define CHAT_TABLE @"chat"

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
@interface DBManager : NSObject
{
}
- (FMDatabase *)getDatabase;

@end
