//
//  DBHelper.m
//  tabbarDemo
//
//  Created by DongJin on 14-10-24.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import "DBHelper.h"
#import "FMDatabase.h"
#import "DBManager.h"
#import "JsonParser.h"

@interface DBHelper()
{
    DBManager *_DBManager;
}
@end

static DBHelper * _DBHelper;
static dispatch_once_t predSqliteOperate;
@implementation DBHelper

+ (DBHelper *) sharedDBHelper {
    dispatch_once(&predSqliteOperate, ^{
        _DBHelper=[[DBHelper alloc] init];
    });
    return _DBHelper;
}

- (id) init {
    self = [super init];
    if (self) {
        _DBManager = [[DBManager alloc]init];
    }
    return self;
}

/****************************************/
#pragma mark - 聊天消息
- (int)getChatTotalUnreadCount
{
    int count= 0;
    NSString * query = [NSString stringWithFormat:@"SELECT count(1) FROM %@ WHERE userid = '%@' and hadread = 0",CHAT_TABLE,[USERMANAGER getUserId]];
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    FMResultSet *_rs = [_db executeQuery:query];
    while ([_rs next]) {
        count = [_rs intForColumnIndex:0];
    }
    [_rs close];
    [_db close];
    return count;
}

- (int)getChatUnreadCountWithTargetid:(NSString *)targetid
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    int count = [self getChatUnreadCountWithTargetid:targetid withDb:_db];
    [_db close];
    return count;
}

- (int)getChatUnreadCountWithTargetid:(NSString *)targetid withDb:(FMDatabase *)_db
{
    int count= 0;
    NSString * query = [NSString stringWithFormat:@"SELECT count(1) FROM %@ WHERE userid = '%@' and targetid = '%@' and hadread = 0",CHAT_TABLE,[USERMANAGER getUserId],targetid];
    FMResultSet *_rs = [_db executeQuery:query];
    while ([_rs next]) {
        count = [_rs intForColumnIndex:0];
    }
    [_rs close];
    return count;
}


- (int)getChatTotalCount
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    int count= 0;
    NSString * query = [NSString stringWithFormat:@"SELECT count(1) FROM %@ WHERE userid = '%@'",CHAT_TABLE,[USERMANAGER getUserId]];
    FMResultSet *_rs = [_db executeQuery:query];
    while ([_rs next]) {
        count = [_rs intForColumnIndex:0];
    }
    [_rs close];
    [_db close];
    return count;
}

- (int)getChatTodayTotalCount
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSUIntegerMax fromDate:[NSDate date]];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    NSTimeInterval ts = (double)(int)[[calendar dateFromComponents:components] timeIntervalSince1970];
    
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    int count= 0;
    NSString * query = [NSString stringWithFormat:@"SELECT count(1) FROM %@ WHERE userid = '%@' and create_time > %d",CHAT_TABLE,[USERMANAGER getUserId],(int)ts];
    FMResultSet *_rs = [_db executeQuery:query];
    while ([_rs next]) {
        count = [_rs intForColumnIndex:0];
    }
    [_rs close];
    [_db close];
    return count;
}

- (NSArray *)getConversationList
{
//    NSString * query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE userid = '%@' group by targetid order by create_time desc",CHAT_TABLE,[USERMANAGER getUserId]];
    
     NSString * query = [NSString stringWithFormat:@"select a.* from %@ a,(select targetid,max(create_time) time from %@ WHERE userid = '%@' group by targetid) b where a.targetid=b.targetid and a.create_time=b.time order by a.create_time desc ",CHAT_TABLE,CHAT_TABLE,[USERMANAGER getUserId]];
    
//    select a.* from CHAT_TABLE a,
//    (select targetid,max(time) time from CHAT_TABLE group by targetid) b
//    where a.targetid=b.targetid
//    and a.create_time=b.time
    
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    FMResultSet *_rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray array];
    NSMutableArray *targetid_array = [NSMutableArray array];//为了去重
    while ([_rs next]) {
        if ([targetid_array containsObject:[_rs stringForColumn:@"targetid"]]) {
            continue;
        }
        ChatModel *model = [[ChatModel alloc]init];
        model.other_userid = [_rs stringForColumn:@"other_userid"];
        model.other_name = [_rs stringForColumn:@"other_name"];
        model.other_photo = [_rs stringForColumn:@"other_photo"];
        model.content = [_rs stringForColumn:@"content"];
        model.create_time = [_rs intForColumn:@"create_time"];
        model.state = [_rs intForColumn:@"state"];
        model.subtype = [_rs intForColumn:@"subtype"];
        model.targetid = [_rs stringForColumn:@"targetid"];
        model.type = [_rs intForColumn:@"type"];
        model.extend = [_rs stringForColumn:@"extend"];
        model.issender = [_rs intForColumn:@"issender"];
        model.hadread = [_rs intForColumn:@"hadread"];
        model.hisTotalUnReadedChatCount = [self getChatUnreadCountWithTargetid:model.other_userid withDb:_db];
        [array addObject:model];
        [targetid_array addObject:model.targetid];
    };
    [_rs close];
    [_db close];
    return array;
}

- (NSArray *)getChatListWithTargetid:(NSString *)targetid startTime:(int)startTime
{
    NSString *query = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE userid = '%@' and targetid = '%@' %@ order by create_time desc limit 20",CHAT_TABLE,[USERMANAGER getUserId],targetid,startTime>0?([NSString stringWithFormat:@" and create_time < %d",startTime]):@""];
    
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    FMResultSet *_rs = [_db executeQuery:query];
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:[_rs columnCount]];
    while ([_rs next]) {
        ChatModel *model = [[ChatModel alloc]init];
        model.dbid = [_rs intForColumn:@"dbid"];
        model.msgid = [_rs intForColumn:@"msgid"];
        model.client_messageid = [_rs stringForColumn:@"client_messageid"];
        model.other_userid = [_rs stringForColumn:@"other_userid"];
        model.other_name = [_rs stringForColumn:@"other_name"];
        model.other_photo = [_rs stringForColumn:@"other_photo"];
        model.content = [_rs stringForColumn:@"content"];
        model.create_time = [_rs intForColumn:@"create_time"];
        model.state = [_rs intForColumn:@"state"];
        model.subtype = [_rs intForColumn:@"subtype"];
        model.type = [_rs intForColumn:@"type"];
        model.targetid = [_rs stringForColumn:@"targetid"];
        model.filename = [_rs stringForColumn:@"filename"];
        model.extend = [_rs stringForColumn:@"extend"];
        model.issender = [_rs intForColumn:@"issender"];
        model.hadread = [_rs intForColumn:@"hadread"];
        
        [array insertObject:model atIndex:0];
    };
    [_rs close];
    [_db close];
    
    int lastRemindTime = 0;//显示时间tips
    for (ChatModel *model in array) {
        if (model.create_time - lastRemindTime > 5 * 60) { //和上次显示时间tips间隔超过5分钟
            lastRemindTime = model.create_time;
            //UI是用create_time是否nil，来判断显示tips的
            model.needShowTimeTips = YES;
        }
    }
    return array;
}


- (void)insertNewChatMessage:(ChatModel *)chatModel
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    
    //其实这里可以检查是否已经存在msgid
//    NSString *exitsql = [NSString stringWithFormat:@"SELECT id FROM %@ where userid = '%@' and msgid = '%d'",CHAT_TABLE,[USERMANAGER getUserId],chatModel.msgid];
//    FMResultSet *_rs = [_db executeQuery:exitsql];
//    while ([_rs next]) {
//        if ([userid isEqualToString:[_rs stringForColumn:@"to_userid"]]) {
//            [_rs close];
//            [_db close];
//            return  YES;
//        }
//    };
    
    NSString *sql2 = [NSString stringWithFormat:@"insert into %@ (userid,msgid,client_messageid,other_userid,other_name,other_photo,content,create_time,state,subtype,type,targetid,filename,extend,issender,hadread) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",CHAT_TABLE];
    [_db executeUpdate: sql2,[USERMANAGER getUserId],[NSString stringWithFormat:@"%d",chatModel.msgid],chatModel.client_messageid,chatModel.other_userid,chatModel.other_name,chatModel.other_photo,chatModel.content,[NSString stringWithFormat:@"%d",chatModel.create_time],[NSString stringWithFormat:@"%d",chatModel.state],[NSString stringWithFormat:@"%d",chatModel.subtype],[NSString stringWithFormat:@"%d",chatModel.type],chatModel.targetid,chatModel.filename,chatModel.extend,[NSString stringWithFormat:@"%d",chatModel.issender],[NSString stringWithFormat:@"%d",chatModel.hadread]];
    [_db close];
}

- (void)clearChatWithTargetid:(NSString *)targetid
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    //删除数据
    [_db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE userid = '%@' and targetid = '%@'",CHAT_TABLE,[USERMANAGER getUserId],targetid]];
    [_db close];
}

- (void)readChatWithTargetid:(NSString *)targetid
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];

    //不删除数据，只是状态改为已读
    [_db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET hadread = 1 where  userid = '%@' and targetid = '%@'",CHAT_TABLE,[USERMANAGER getUserId],targetid]];
    
    [_db close];
}

- (void)updateChatMessageState:(NSString *)client_messageid state:(int)state
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    
    //不删除数据，只是状态改为已读
    [_db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET state = %d where client_messageid = '%@'",CHAT_TABLE,state,client_messageid]];
    
    [_db close];
}

- (void)updateChatMessageStateByMsgid:(int)msgid state:(int)state
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    
    //不删除数据，只是状态改为已读
    [_db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET state = %d where msgid = %d",CHAT_TABLE,state,msgid]];
    
    [_db close];
}

- (void)deleteMessageWithDbid:(int)dbid
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    //删除数据
    [_db executeUpdate:[NSString stringWithFormat:@"DELETE FROM %@ WHERE userid = '%@' and dbid = '%d'",CHAT_TABLE,[USERMANAGER getUserId],dbid]];
    [_db close];
}

- (void)updateCallMessageState:(NSString *)channelid callState:(int)newCallState content:(NSString *)content
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
    
    [_db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET extend = %d, content = '%@' where filename = '%@'",CHAT_TABLE,newCallState,content,channelid]];
    
    [_db close];
}

- (void)updateMessageWithFilename:(NSString *)filename extend:(NSString *)extend
{
    FMDatabase *_db = [_DBManager getDatabase];
    [_db open];
       
    [_db executeUpdate:[NSString stringWithFormat:@"UPDATE %@ SET extend = '%@' where filename = '%@'",CHAT_TABLE,extend,filename]];
       
    [_db close];
}

/**************************/


#pragma mark - /****************** 系统通知列表 end **********************/
- (void)loginOut
{
    _DBManager = nil;
    _DBHelper = nil;
    predSqliteOperate = 0;
}


@end
