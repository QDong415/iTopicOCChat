//
//  DBHelper.h
//  tabbarDemo
//
//  Created by DongJin on 14-10-24.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatModel.h"

#define DBHELPER [DBHelper sharedDBHelper]

@interface DBHelper : NSObject
{
}
+ (DBHelper *) sharedDBHelper;
- (void)loginOut;


#pragma mark - 聊天消息
- (int)getChatTotalUnreadCount;
- (NSArray *)getChatListWithTargetid:(NSString *)targetid startTime:(int)startTime;
- (NSArray *)getConversationList;
- (void)insertNewChatMessage:(ChatModel *)chatModel;
- (void)clearChatWithTargetid:(NSString *)targetid;
- (void)readChatWithTargetid:(NSString *)targetid;
- (void)updateChatMessageState:(NSString *)client_messageid state:(int)state;
- (void)updateChatMessageStateByMsgid:(int)msgid state:(int)state;
- (void)deleteMessageWithDbid:(int)dbid;
- (void)updateMessageWithFilename:(NSString *)filename extend:(NSString *)extend;
- (void)updateCallMessageState:(NSString *)channelid callState:(int)newCallState content:(NSString *)content;
- (int)getChatTotalCount;

- (int)getChatTodayTotalCount;


@end
