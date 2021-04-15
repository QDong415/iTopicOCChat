//
//  AFMessage.h
//  iPhone
//
//  Created by QDong Email: 285275534@qq.com on 13-3-26.
//  Copyright (c) 2013年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatModel.h"
#import <Photos/Photos.h>
#import "QiniuUploadManager.h"
#import "SendMessageResponse.h"


#define MESSAGEMANAGER [MessageManager sharedMessageManager]

@protocol ReceiveChatMessageDelegate <NSObject>

- (void)receiveChatMessage:(ChatModel *)chatModel;

- (void)onChatMessageFileDownloadComplete:(ChatModel *)chatModel error:(NSError *)error;

@end

@interface MessageManager : NSObject
{
}

@property (nonatomic, weak) id<ReceiveChatMessageDelegate> delegate;

+ (MessageManager *)sharedMessageManager;

- (void)sendChatMessage:(ChatModel *)chatModel;

- (void)pullMesssages;

//上传图片文件
- (void)uploadFile:(NSString *)sandboxFileName complete:(QNUpCompletionHandler)completionHandler uploadOption:(QNUploadOption *)uploadOption;

- (void)sendNotification:(SendMessageResponse *)response chatModel:(ChatModel *)chatModel;

- (void)changeVoiceMessageModelPlayStatus:(ChatModel *)model;

- (void)downloadChatFile:(ChatModel *)chatModel;

@end
