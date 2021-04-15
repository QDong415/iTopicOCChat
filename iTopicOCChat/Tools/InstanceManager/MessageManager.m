//
//  iPhone
//
//  Created by QDong Email: 285275534@qq.com on 13-3-26.
//  Copyright (c) 2013年 ibluecollar. All rights reserved.
//

#import "MessageManager.h"
#import "JsonParser.h"
#import "DBHelper.h"
#import "ValueUtil.h"
#import "ChatListResponse.h"
#import "ChatModel.h"
#import "VideoChatViewController.h"
#import "CallManager.h"
#import "AFURLSessionManager.h"

@interface MessageManager ()
{

}

@end

@implementation MessageManager

+ (MessageManager *)sharedMessageManager{
    static MessageManager *_sharedMessageManager=nil;
    static dispatch_once_t predMessage;
    dispatch_once(&predMessage, ^{
        _sharedMessageManager = [[MessageManager alloc] init];
    });
    return _sharedMessageManager;
}

- (void)sendChatMessage:(ChatModel *)chatModel
{
    //post给服务器
    UserManager *manager = USERMANAGER;
    UserModel *userModel = manager.userModel;
    NSDictionary *paramDictionary = [NSDictionary dictionaryWithObjectsAndKeys:chatModel.targetid,@"targetid",chatModel.content,@"content",[NSString stringWithFormat:@"%d",chatModel.type],@"type",[NSString stringWithFormat:@"%d",chatModel.subtype],@"subtype",chatModel.extend?:@"",@"extend",chatModel.filename?:@"",@"filename",userModel.name,@"username", nil];

    __weak MessageManager *weakSelf = self;
    [NETWORK postDataByApi:@"chat/send" parameters:paramDictionary responseClass:[SendMessageResponse class] success:^(NSURLSessionTask *task, id responseObject){
        SendMessageResponse *response = (SendMessageResponse *)responseObject;
        if([response isSuccess]){
            
        }
        [weakSelf sendNotification:response chatModel:chatModel];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        SendMessageResponse *response = [[SendMessageResponse alloc]initWithError];
        [weakSelf sendNotification:response chatModel:chatModel];
    }];
}

#pragma mark public
- (void)sendNotification:(SendMessageResponse *)response chatModel:(ChatModel *)chatModel
{
    response.client_messageid = chatModel.client_messageid;
    response.targetid = chatModel.targetid;
    
    //根据刚才是否网络成功 来更新本地数据库
    if ([response isSuccess]) {
        [DBHELPER updateChatMessageState:response.client_messageid state:SUCCESS];
    } else {
        [DBHELPER updateChatMessageState:response.client_messageid state:FAIL];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_SEND object:response];
}


#pragma mark public 有接口返回了msg不为0。或许推送来了新消息，就拉一遍
- (void)pullMesssages
{
    [NETWORK getDataByApi:@"message/pull" parameters:[NSDictionary dictionary] responseClass:[ChatListResponse class] success:^(NSURLSessionTask *task, id responseObject){
        ChatListResponse* response= (ChatListResponse*)responseObject;
        
        if (![response isSuccess]) {
            return;
        }
        
        if ([[USERMANAGER getUserId] isEqualToString:@""]) {
            return;
        }
        
        NSMutableArray *newMessagesTypes = [NSMutableArray array];
        for (ChatModel *chatModel in response.data) {
            switch (chatModel.type) {
                case TYPE_CHAT_SINGLE:
                case TYPE_CHAT_GROUP:
                {
                    chatModel.state = SUCCESS;
                    chatModel.issender = 0;//当前登录账号是这个消息的发送者
                    chatModel.hadread = 0;//0未读
                    if(chatModel.type == TYPE_CHAT_SINGLE){
                        //单聊的话，服务器返回的targetid肯定是我自己。为了手机本地group查询处理方便，将targetid入库时候设置为对方uid
                        [chatModel setTargetid:chatModel.other_userid];
                    }
                    if(chatModel.subtype == SUBTYPE_VOICE){
                        //声音需要下载
                        chatModel.state = INPROGRESS;
                    }
                    [DBHELPER insertNewChatMessage:chatModel];
                    if ([_delegate respondsToSelector:@selector(receiveChatMessage:)]) {
                        [_delegate receiveChatMessage:chatModel];
                    }
                    
                    if(chatModel.subtype == SUBTYPE_VOICE){
                        //声音需要下载
                        [self downloadChatFile:chatModel];
                    }
                    
                    switch (chatModel.subtype) {
                        case SUBTYPE_CALL_AUDIO:
                        case SUBTYPE_CALL_VIDEO:{
                            if([chatModel.extend intValue] == RCCallHangup){
                                //对方已经挂断了
                                NSLog(@"对方已经挂断了,我没接听到");
                                break;
                            }
                            CallManager *callManager = [CallManager sharedCallManager];
                            //这里要判断我当前是不是在通话中
                            if (callManager.callStatus != RCCallHangup){
                                //当前我正在通话，没空接听
                                NSLog(@"当前我正在通话，没空接听");
                                break;
                            }
                            callManager.channelId = chatModel.filename;
                            callManager.targetId = chatModel.targetid;
                            callManager.callStatus = RCCallIncoming;
                            callManager.mediaType = chatModel.subtype;
                            callManager.startTime = (int)[[NSDate date] timeIntervalSince1970];
                            callManager.other_name = chatModel.other_name;
                            callManager.other_photo = chatModel.other_photo;
                            
                            VideoChatViewController *vc = [[VideoChatViewController alloc]init];
                            [callManager presentCallViewController:vc];
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                    
                default:
                    break;
            }
            [newMessagesTypes addObject:[NSNumber numberWithInt:chatModel.type]];
        }
        
        if([newMessagesTypes count] > 0)
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGES_RECEIVE object:newMessagesTypes];
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
    }];
}

- (void)changeVoiceMessageModelPlayStatus:(ChatModel *)model {
    if (model.subtype != SUBTYPE_VOICE)
        return;
    model.isMediaPlaying = !model.isMediaPlaying;
    if (!model.isMediaPlayed) {
        model.isMediaPlayed = YES;
        
        NSDictionary *extendDict = [NSJSONSerialization JSONObjectWithData:[model.extend dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
        NSMutableDictionary *dict;
        if (extendDict)
            dict = [extendDict mutableCopy];
        else
            dict = [NSMutableDictionary dictionary];
        
        [dict setObject:[NSNumber numberWithBool:YES] forKey:@"played"];
        model.extend = [ValueUtil convertToJSONData:dict];
        [DBHELPER updateMessageWithFilename:model.filename extend:model.extend];
    }
}

- (void)downloadChatFile:(ChatModel *)chatModel
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSString * urlStr = [ValueUtil getQiniuUrlByFileName:chatModel.filename isThumbnail:NO];
    /* 下载地址 */
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    /* 下载路径 */
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [cacheDirectory stringByAppendingPathComponent:chatModel.filename];
    
    /* 开始请求下载 */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"下载进度：%.0f％", downloadProgress.fractionCompleted * 100);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//        dispatch_async(dispatch_get_main_queue(), ^{
            //如果需要进行UI操作，需要获取主线程进行操作
//        });
        /* 设定下载到的位置 */
        return [NSURL fileURLWithPath:filePath];
                
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            chatModel.state = FAIL;
            [DBHELPER updateChatMessageStateByMsgid:chatModel.msgid state:FAIL];
        } else {
            chatModel.state = SUCCESS;
            [DBHELPER updateChatMessageStateByMsgid:chatModel.msgid state:SUCCESS];
        }
        if ([_delegate respondsToSelector:@selector(onChatMessageFileDownloadComplete:error:)]) {
            [_delegate onChatMessageFileDownloadComplete:chatModel error:error];
        }
        NSLog(@"下载完成 %@",filePath.absoluteURL);
//        NSData *voiceData = [NSData dataWithContentsOfURL:filePath];
//        [_recordAudio play:voiceData];
    }];
    [downloadTask resume];
}

//上传图片文件
- (void)uploadFile:(NSString *)sandboxFileName complete:(QNUpCompletionHandler)completionHandler uploadOption:(QNUploadOption *)uploadOption
{
    //是图片
    [QINIUMANAGER getTokenApi:@"qiniu/uploadtoken" parameters:[NSDictionary dictionary] withSuccessBlock:^(NSString *token){
        
        QNUploadManager *upManager = [QINIUMANAGER createUpManager];

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *boxpath = [paths objectAtIndex:0];
        [upManager putFile:[boxpath stringByAppendingPathComponent:sandboxFileName] key:sandboxFileName token:token complete:completionHandler option:uploadOption];
        
    } andFailBlock:^(int code,NSString *message){
        completionHandler(nil,sandboxFileName,nil);
    }];
}

//发送图片消息
- (void)sendImages:(NSArray<NSString *> *)sandboxFileName imageArray:(NSArray<UIImage *> *)imageArray assetArray:(NSArray<PHAsset *> *)assetArray
{
    //是图片
    [QINIUMANAGER getTokenApi:@"qiniu/uploadtoken" parameters:[NSDictionary dictionary] withSuccessBlock:^(NSString *token){
        
        //文件总数量
        NSUInteger totalFileCount = [imageArray count];
        
        QNUploadManager *upManager = [QINIUMANAGER createUpManager];
        
        //2、如果有图，调用七牛sdk上传图片到七牛
        for (int i = 0 ; i < totalFileCount; i++) {
            //七牛云存储不支持一次上传多文件，只能挨个上传
            PHAsset *asset = assetArray[i];
        }
        
    } andFailBlock:^(int code,NSString *message){
        NSLog(@"七牛图片token获取失败 code = %d message = %@",code,message);
    }];
}

@end
