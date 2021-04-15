//
//  DBManager.m
//  tabbarDemo
//
//  Created by DongJin on 14-10-24.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import "DBManager.h"


#define kDefaultDBName @"itopic.db"
@interface DBManager ()
{
    NSString *_DBFilePath;
}

@end

@implementation DBManager

//当前数据库版本
const static int CURRENT_DB_VERSION = 2;


- (id) init
{
    self = [super init];
    if (self) {
        [self initDBByVersion];
    }
    return self;
}


/**
 */
- (void) initDBByVersion {
    
    //获取数据库路径，可能不存在
    _DBFilePath = [self getDBFilePath];
    
    //取出app上个版本的数据库版本
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastVersionInteger = [userDefaults integerForKey:@"lastVersion"];
   
    //卸载掉app之后，依然会保存NSUserDefaults，所以还必须判断文件是否存在
    NSFileManager * fileManager = [NSFileManager defaultManager];
    bool exist = [fileManager fileExistsAtPath:_DBFilePath];
    int lastVersion = exist ? (int)lastVersionInteger : 0;
    
    //fmdb的初始化操作会createFileIfNotExist
    FMDatabase *_db = [self getDatabase];
    [_db open];
    
    //创建表
    [self createChatTables:_db];
    
    for (int i = lastVersion + 1; i <= CURRENT_DB_VERSION; i++) {
        switch (i) {
            case 2:
               
            default:
                break;
        }
    }
    [_db close];
    [userDefaults setInteger:CURRENT_DB_VERSION forKey:@"lastVersion"];
    
}

//一旦发布版本，永远不能改变create语句
- (void)createChatTables:(FMDatabase *)_db
{
    NSString *sql =  [NSString stringWithFormat: @"create table if not exists %@ (dbid INTEGER PRIMARY KEY AUTOINCREMENT,userid varchar(20),msgid integer,client_messageid varchar(20),targetid varchar(20),other_userid varchar(20),other_name varchar(50),other_photo varchar(100),content varchar(4096),create_time integer,state tinyint(1),type tinyint(1),subtype tinyint(1),filename varchar(60),extend varchar(1000),issender tinyint(1),hadread tinyint(1))",CHAT_TABLE];
    [_db executeUpdate:sql];
}

- (NSString*)getDBFilePath
{
    NSString * docp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    return [docp stringByAppendingPathComponent:kDefaultDBName];
}

- (FMDatabase *)getDatabase
{
    return [FMDatabase databaseWithPath:_DBFilePath];
}

@end
