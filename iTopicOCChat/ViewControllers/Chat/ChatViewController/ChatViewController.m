/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "ChatViewController.h"
#import "UserViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MessageManager.h"
#import "ValueUtil.h"
#import "ChatModel.h"
#import "DBHelper.h"
#import "SendMessageResponse.h"
#import "LLMessageTextCell.h"
#import "LLMessageDateCell.h"
#import "LLMessageCallCell.h"
#import "StringUtil.h"
#import "SimpleWebViewController.h"
#import "LLMessageImageCell.h"
#import "LLMessageVoiceCell.h"
#import "ZLPhotoActionSheet.h"
#import "JGProgressHUD.h"
#import "ESSinglePictureBrowser.h"
#import "VideoChatViewController.h"
#import "CallManager.h"
#import "DictionaryResponse.h"
#import "LLAudioManager.h"
#import "LLVoiceIndicatorView.h"
#import "LLTipView.h"
#import "LLDeviceManager.h"

@interface ChatViewController ()<UINavigationControllerDelegate,ReceiveChatMessageDelegate,LLMessageCellActionDelegate,CallDelegate,LLAudioRecordDelegate,LLAudioPlayDelegate,LLDeviceManagerDelegate>
{
    int _targetGender;
}

@property (nonatomic,strong) JGProgressHUD *progressHUD;
@property (strong, nonatomic) NSMutableArray<ChatModel *> *dataArray;

@property (nonatomic,strong) LLVoiceIndicatorView *voiceIndicatorView;
@property (nonatomic,assign) int countDown;

@end

@implementation ChatViewController

+ (void)pushChatViewController:(BaseViewController*)viewController targetid:(NSString *)targetid userId:(NSString*)hisUserID userName:(NSString*)hisName userPhoto:(NSString *)hisPhoto type:(int)type
{
    if (![viewController checkLogined]) {
        return;
    }
    int viewControllersCount = (int)[viewController.navigationController.viewControllers count];
    //当前堆栈里有 两个以上的vc，从前一个vc开始遍历
    for (int i = viewControllersCount - 2 ; i >= 0; i--) {
        if ([viewController.navigationController.viewControllers[i] isKindOfClass:[ChatViewController class]]) {
            ChatViewController *preChatVC = viewController.navigationController.viewControllers[i];
            if ([preChatVC.targetid isEqualToString:targetid]) {
                //之前就有个chatVC 是与他聊天的
                [viewController.navigationController popToViewController:preChatVC animated:YES];
                return ;
            }
        }
    }
    ChatViewController *chatController = [[ChatViewController alloc] init];
    chatController.targetid = targetid;
    chatController.hisUserID = hisUserID;
    chatController.hisName = hisName;
    chatController.hisPhoto = hisPhoto;
    chatController.type = type;
    [chatController setHidesBottomBarWhenPushed:YES];
    [viewController.navigationController pushViewController:chatController animated:YES];
}

- (id)init {
    self = [super init];
    if (self) {
        self.allowsSendVoice = YES;
        self.allowsSendMultiMedia = YES;
        XHShareMenuItem *shareMenuItem = [[XHShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"message_more_pic"] title:@"图片"];
        
        XHShareMenuItem *audioItem = [[XHShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"message_more_audio_call"] title:@"语音通话"];
        
        XHShareMenuItem *videoItem = [[XHShareMenuItem alloc]initWithNormalIconImage:[UIImage imageNamed:@"message_more_video_call"] title:@"视频通话"];
        
        self.shareMenuItems = @[shareMenuItem,audioItem,videoItem];
    }
    return self;
}


- (BOOL)refreshEnable{
    //是否支持下拉刷新，由子类重写
    return NO;
}

- (BOOL)loadMoreEnable{
    //是否支持底部自动加载更多，由子类重写
    return NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //根据接收者的username获取当前会话的管理者
    [DBHELPER readChatWithTargetid:self.targetid];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_READED object:nil];
    self.dataArray = [NSMutableArray array];
    self.title = _hisName;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.backgroundColor = [UIColor colorNamed:@"bg230"];
    } else {
        self.tableView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //下面3句代码，防止发消息时候，刷新tableview动画会先下沉再弹起
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
        
    //监听新消息已拉（pull/msg接口）
    MESSAGEMANAGER.delegate = self;
    
    //通过会话管理者获取已收发消息
    [self loadFirstMessages];
    
    //    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    //    lpgr.minimumPressDuration = .5;
    //    [self.tableView addGestureRecognizer:lpgr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageCallBack:) name:NOTIFICATION_MESSAGE_SEND object:nil];
    
    [NETWORK getDataByApi:@"user/profile" parameters:[NSDictionary dictionaryWithObjectsAndKeys:self.targetid,@"to_userid",@"1",@"simple", nil] responseClass:[DictionaryResponse class] success:^(NSURLSessionTask *task, id responseObject){
        DictionaryResponse *response = (DictionaryResponse *)responseObject;
        if ([response isSuccess]) {
            _targetGender = [response.data[@"gender"] intValue];
            _hisPhoto = response.data[@"avatar"];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[LLAudioManager sharedManager] stopPlaying];
    //传感器，为了语音从听筒到免提
    [[LLDeviceManager sharedManager] disableProximitySensor];
    [LLDeviceManager sharedManager].delegate = nil;
}

- (void)dealloc
{
    NSLog(@"ChatVC DEALLOC");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    ChatModel *model =  [self.dataArray objectAtIndex:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatModel *model = [self.dataArray objectAtIndex:indexPath.row];
    return model.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatModel *model =  [self.dataArray objectAtIndex:indexPath.row];
    
    if (model.type == TYPE_CHAT_TIPS) {
        //tips消息
        LLMessageDateCell *cell = (LLMessageDateCell *)[tableView dequeueReusableCellWithIdentifier:@"tips"];
        if (cell == nil) {
            cell = [[LLMessageDateCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tips"];
            cell.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.messageModel = model;
        return cell;
    } else {
        if (model.subtype == SUBTYPE_IMAGE) {
            //聊天图片消息
            LLMessageImageCell *cell = (LLMessageImageCell *)[tableView dequeueReusableCellWithIdentifier:@"image"];
            if (cell == nil) {
                cell = [[LLMessageImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image"];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageModel = model;
            cell.delegate = self;
            return cell;
        } else if (model.subtype == SUBTYPE_CALL_AUDIO || model.subtype == SUBTYPE_CALL_VIDEO) {
            //Call消息
            LLMessageCallCell *cell = (LLMessageCallCell *)[tableView dequeueReusableCellWithIdentifier:@"call"];
            if (cell == nil) {
                cell = [[LLMessageCallCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"call"];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageModel = model;
            cell.delegate = self;
            return cell;
        } else if (model.subtype == SUBTYPE_VOICE) {
            //Call消息
            LLMessageVoiceCell *cell = (LLMessageVoiceCell *)[tableView dequeueReusableCellWithIdentifier:@"voice"];
            if (cell == nil) {
                cell = [[LLMessageVoiceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"voice"];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageModel = model;
            cell.delegate = self;
            return cell;
        } else {
            //聊天文本消息
            LLMessageTextCell *cell = (LLMessageTextCell *)[tableView dequeueReusableCellWithIdentifier:@"text"];
            if (cell == nil) {
                cell = [[LLMessageTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"text"];
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.messageModel = model;
            cell.delegate = self;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)insertPreviousMessages:(NSArray *)previousMessages {
    [self insertPreviousMessages:previousMessages completion:nil];
}

static CGPoint delayOffset = {0.0};
- (void)insertPreviousMessages:(NSArray *)previousMessages completion:(void (^)())completion {
    WEAKSELF
    delayOffset = weakSelf.tableView.contentOffset;
    NSMutableArray *indexPaths = [[NSMutableArray alloc] initWithCapacity:previousMessages.count];
    NSMutableIndexSet *indexSets = [[NSMutableIndexSet alloc] init];
    [previousMessages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
        [indexPaths addObject:indexPath];
        ChatModel *tempChatModel = [previousMessages objectAtIndex:idx];
        delayOffset.y += tempChatModel.cellHeight;
        [indexSets addIndex:idx];
    }];
    delayOffset.y -= 44 ;//44是loadingheader的高度
    [UIView setAnimationsEnabled:NO];
    weakSelf.tableView.userInteractionEnabled = NO;
    [weakSelf.dataArray insertObjects:previousMessages atIndexes:indexSets];
    [weakSelf.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [UIView setAnimationsEnabled:YES];
    [weakSelf.tableView setContentOffset:delayOffset animated:NO];
    weakSelf.tableView.userInteractionEnabled = YES;
    if (completion) {
        completion();
    }
}


#pragma mark - XHMessageTableViewController Delegate
- (BOOL)shouldLoadMoreMessagesScrollToTop {
    return YES;
}

- (void)loadMoreMessagesScrollTotop {

    if (!self.loadingMoreMessage) {
        self.loadingMoreMessage = YES;
        
        WEAKSELF
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            ChatModel *firstmodel = self.dataArray[0];
            NSArray *previousOrgMessages = [DBHELPER getChatListWithTargetid:weakSelf.targetid startTime:firstmodel.create_time];
            NSMutableArray *previousWithTimerMessages = [[NSMutableArray alloc] init];
            if ([previousOrgMessages count] > 0) {
                for (ChatModel *model in previousOrgMessages) {
                    //为cell显示做数据上的准备
                    [model processModelForCell];
                    if ([model needShowTimeTips]) {
                        //拆分出时间tipscell，插入总array
                        ChatModel *timemodel = [[ChatModel alloc] init];
                        timemodel.type = TYPE_CHAT_TIPS;
                        timemodel.create_time = model.create_time;
                        timemodel.content = [ValueUtil timeIntervalBeforeNowLongDescription:model.create_time];
                        [timemodel processModelForCell];
                        [previousWithTimerMessages addObject:timemodel];
                    }
                    [previousWithTimerMessages addObject:model];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"顶部加载了%d条",(int)previousOrgMessages.count);
                
                UIActivityIndicatorView *indicator = weakSelf.tableView.tableHeaderView.subviews[0];
                [indicator stopAnimating];
                
                if (previousOrgMessages.count >= 20) {
                } else {
                    self.tableView.tableHeaderView = nil;
                }
                
                [weakSelf insertPreviousMessages:previousWithTimerMessages];
                weakSelf.loadingMoreMessage = NO;
            });
        });
    }
}


#pragma mark - ReceiveChatMessageDelegate
- (void)receiveChatMessage:(ChatModel *)chatModel
{
    if ([_targetid isEqualToString:chatModel.targetid]) {
        [DBHELPER readChatWithTargetid:self.targetid];
        [self addMessageToDataSource:chatModel];
    }
}

- (void)onChatMessageFileDownloadComplete:(ChatModel *)chatModel error:(NSError *)error
{
    if ([_targetid isEqualToString:chatModel.targetid]) {
        for (int i = (int)self.dataArray.count - 1; i >= 0; i-- ) {
            ChatModel *model = [self.dataArray objectAtIndex:i];
            if (model.msgid == chatModel.msgid) {
                model.state = chatModel.state;
                LLMessageBaseCell *baseCell = [self visibleCellForMessageModel:model];
                if (baseCell) {
                    [baseCell updateMessageDownloadStatus];
                }
                break;
            }
        }
    }
}

- (void)sendMessageCallBack:(NSNotification *)notification
{
    SendMessageResponse *response = (SendMessageResponse *)notification.object;
    
    if (![_targetid isEqualToString:response.targetid]) {
        return ;
    }
    if (response.isSuccess) {
        //我发消息成功了
        __block ChatModel *model = nil;
        WEAKSELF;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            model = (ChatModel *)obj;
            if ([model.client_messageid isEqualToString:response.client_messageid]){
                model.state = SUCCESS;
                LLMessageBaseCell *baseCell = [weakSelf visibleCellForMessageModel:model];
                if (baseCell) {
                    [baseCell updateMessageUploadStatus];
                }
                *stop = YES;
            }
        }];
        
    } else {
        //我发消息失败了
        for (int i = 0; i < self.dataArray.count; i ++) {
            ChatModel *model = [self.dataArray objectAtIndex:i];
            if ([response.client_messageid isEqualToString:model.client_messageid]) {
                model.state = FAIL;
                [UIView performWithoutAnimation:^{
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }];
            }
        }
    }
}

- (void)loadFirstMessages
{
    WEAKSELF
    dispatch_async(dispatch_queue_create("readMessage", NULL), ^{
        NSArray *moreMessages = [DBHELPER getChatListWithTargetid:weakSelf.targetid startTime:0];
        if ([moreMessages count] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.dataArray removeAllObjects];
                for (ChatModel *model in moreMessages) {
                    //为cell显示做数据上的准备
                    [model processModelForCell];
                    if ([model needShowTimeTips]) {
                        //拆分出时间tipscell，插入总array
                        ChatModel *timemodel = [[ChatModel alloc] init];
                        timemodel.type = TYPE_CHAT_TIPS;
                        timemodel.create_time = model.create_time;
                        timemodel.content = [ValueUtil timeIntervalBeforeNowLongDescription:model.create_time];
                        [timemodel processModelForCell];
                        [weakSelf.dataArray addObject:timemodel];
                    }
                    [weakSelf.dataArray addObject:model];
                }
                [weakSelf.tableView reloadData];
                [weakSelf scrollToBottomAnimated:NO];
                
                if(moreMessages.count < 20)
                    weakSelf.tableView.tableHeaderView = nil;
            });
        } else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 weakSelf.tableView.tableHeaderView = nil;
            });
        }
    });
}

//我主动发出 或 收到消息，都进入这里
-(BOOL)addMessageToDataSource:(ChatModel *)message
{
    [message processModelForCell];
    
    ChatModel *lastMessage = [self.dataArray lastObject];
    if (message.create_time - lastMessage.create_time > 10 * 60) { //和上次显示时间tips间隔超过10分钟
        message.needShowTimeTips = YES;
    }
    
    if ([message needShowTimeTips]) {
        //才分出时间tipscell，插入总array
        ChatModel *timemodel = [[ChatModel alloc] init];
        timemodel.type = TYPE_CHAT_TIPS;
        timemodel.create_time = message.create_time;
        timemodel.content = [ValueUtil compareCurrentTimeWithTimestamp:message.create_time];
        [timemodel processModelForCell];
        [self.dataArray addObject:timemodel];
    }
    
    [self.dataArray addObject:message];
    
    BOOL needSuccess = YES;
    //这里可以检查一下比如被对方拉黑，可以设置为needSuccess = NO；
    
    [self.tableView reloadData];
    if ([self shouldScrollToBottomForNewMessage]){
        [self scrollToBottomAnimated:YES];
    }
    
    return needSuccess;
}

- (void)scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

- (LLMessageBaseCell *)visibleCellForMessageModel:(ChatModel *)model {
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        LLMessageBaseCell *chatCell = (LLMessageBaseCell *)cell;
        if ([chatCell.messageModel isEqual:model]) {
            return chatCell;
        }
    }
    
    return nil;
}

#pragma mark - send message
-(void)clickSendTextAciton:(NSString *)textMessage
{
    [self clickSendTextAciton:textMessage isGIFEmotion:NO];
}

//点击发送按钮
-(void)clickSendTextAciton:(NSString *)textMessage isGIFEmotion:(BOOL)isGIFEmotion
{
    //普通私信
    [self sendTextMessage:textMessage];
}

- (BOOL)shouldScrollToBottomForNewMessage {
    CGFloat _h = self.tableView.contentSize.height - self.tableView.contentOffset.y - (CGRectGetHeight(self.tableView.frame) - self.tableView.contentInset.bottom);
    return _h <= 66 * 4;
}

#pragma mark 发送消息
- (ChatModel *)createCommonChatModel
{
    ChatModel *willSendModel = [[ChatModel alloc]init];
    willSendModel.client_messageid = [NSString stringWithFormat:@"%@%d%d",_targetid,(int)[[NSDate date] timeIntervalSince1970], arc4random()];
    willSendModel.targetid = _targetid;
    willSendModel.other_userid = _hisUserID;
    willSendModel.other_photo = _hisPhoto;
    willSendModel.other_name = _hisName;
    willSendModel.create_time = (int)[[NSDate date] timeIntervalSince1970];
    willSendModel.type = self.type;
    willSendModel.hadread = 1;
    willSendModel.issender = 1;
    return willSendModel;
}

- (void)sendTextMessage:(NSString *)textMessage
{
    ChatModel *willSendModel = [self createCommonChatModel];
    willSendModel.content = textMessage;
    willSendModel.subtype = SUBTYPE_TEXT;
    willSendModel.extend = @"";
    //先插入数据库
    [DBHELPER insertNewChatMessage:willSendModel];
    
    BOOL needSuccess = [self addMessageToDataSource:willSendModel];
    if (needSuccess) {
        [MESSAGEMANAGER sendChatMessage:willSendModel];
    } else {
        SendMessageResponse *response = [[SendMessageResponse alloc]initWithError];
        [MESSAGEMANAGER sendNotification:response chatModel:willSendModel];
    }
    
    [self finishSendMessageWithBubbleMessageType:SUBTYPE_TEXT];
}

- (void)sendImageMessage:(NSString *)filename extend:(NSString *)extend
{
    ChatModel *willSendModel = [self createCommonChatModel];
    willSendModel.content = @"[图片消息]";
    willSendModel.subtype = SUBTYPE_IMAGE;
    willSendModel.extend = extend;
    willSendModel.filename = filename;
    //先插入数据库
    [DBHELPER insertNewChatMessage:willSendModel];
    //在当前界面显示出来
    [self addMessageToDataSource:willSendModel];
    [self finishSendMessageWithBubbleMessageType:SUBTYPE_IMAGE];
    //上传文件
    WEAKSELF;
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            willSendModel.fileUploadProgress = percent * 100;
            LLMessageBaseCell *baseCell = [weakSelf visibleCellForMessageModel:willSendModel];
            if (baseCell) {
                [baseCell updateMessageUploadStatus];
            }
        });
    }params:[NSDictionary dictionary] checkCrc:NO cancellationSignal:nil];
    [MESSAGEMANAGER uploadFile:filename complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (resp) {
            //上传成功，发送服务器
            [MESSAGEMANAGER sendChatMessage:willSendModel];
        } else {
            //上传图片过程中出错了，回调失败
            SendMessageResponse *response = [[SendMessageResponse alloc] initWithError];
            [MESSAGEMANAGER sendNotification:response chatModel:willSendModel];
        }
    } uploadOption:uploadOption];
}


- (void)sendVoiceMessage:(NSString *)filename extend:(NSString *)extend
{
    ChatModel *willSendModel = [self createCommonChatModel];
    willSendModel.content = @"[语音消息]";
    willSendModel.subtype = SUBTYPE_VOICE;
    willSendModel.extend = extend;
    willSendModel.filename = filename;
    //先插入数据库
    [DBHELPER insertNewChatMessage:willSendModel];
    
    BOOL needSuccess = [self addMessageToDataSource:willSendModel];
    
    [self finishSendMessageWithBubbleMessageType:SUBTYPE_VOICE];
    //上传文件
    WEAKSELF;
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            willSendModel.fileUploadProgress = percent * 100;
            LLMessageBaseCell *baseCell = [weakSelf visibleCellForMessageModel:willSendModel];
            if (baseCell) {
                [baseCell updateMessageUploadStatus];
            }
        });
    }params:[NSDictionary dictionary] checkCrc:NO cancellationSignal:nil];
    [MESSAGEMANAGER uploadFile:filename complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (resp) {
            if (needSuccess) {
                //上传成功，发送服务器
                [MESSAGEMANAGER sendChatMessage:willSendModel];
            } else {
                SendMessageResponse *response = [[SendMessageResponse alloc]initWithError];
                [MESSAGEMANAGER sendNotification:response chatModel:willSendModel];
            }
        } else {
            //上传图片过程中出错了，回调失败
            SendMessageResponse *response = [[SendMessageResponse alloc] initWithError];
            [MESSAGEMANAGER sendNotification:response chatModel:willSendModel];
        }
    } uploadOption:uploadOption];
}

- (ChatModel *)sendCallMessage:(int)subType
{
    ChatModel *willSendModel = [self createCommonChatModel];
    willSendModel.content = subType == SUBTYPE_CALL_AUDIO?@"语音通话":@"视频通话";
    willSendModel.subtype = subType;
    willSendModel.extend = [NSString stringWithFormat:@"%ld",RCCallDialing];
    willSendModel.filename = [NSString stringWithFormat:@"%@:%@:%d",[USERMANAGER getUserId],self.targetid,(int)[[NSDate date] timeIntervalSince1970]];
    //先插入数据库
    [DBHELPER insertNewChatMessage:willSendModel];
    [MESSAGEMANAGER sendChatMessage:willSendModel];
    [self addMessageToDataSource:willSendModel];
    [self finishSendMessageWithBubbleMessageType:SUBTYPE_CALL_AUDIO];
    return willSendModel;
}


#pragma mark - 处理Cell动作
- (void)textPhoneNumberDidTapped:(NSString *)phoneNumber userinfo:(nullable id)userinfo {
    [self finishSendMessageWithBubbleMessageType:SUBTYPE_TEXT];
    NSMutableString * str= [[NSMutableString alloc] initWithFormat:@"telprompt://%@",phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (void)textLinkDidTapped:(NSURL *)url userinfo:(nullable id)userinfo {
    [self finishSendMessageWithBubbleMessageType:SUBTYPE_TEXT];
    SimpleWebViewController *webVC = [[SimpleWebViewController alloc] init];
    webVC.URLString = url.absoluteString;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)textLinkDidLongPressed:(NSURL *)url userinfo:(nullable id)userinfo {
    
}

#pragma mark - XHShareMenuView Delegate
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    switch (index) {
        case 0://发送图片
            [[self photoActionSheet] showPhotoLibrary];
            break;
        case 1:
        case 2:{
            //发送视频通话Item
            [self createAndSendCallMessage:index == 1?SUBTYPE_CALL_AUDIO:SUBTYPE_CALL_VIDEO];
        }
            break;
        default:
            break;
    }
}

#pragma mark - private
- (void)createAndSendCallMessage:(int)subType
{
    ChatModel *callChatModel = [self sendCallMessage:subType];
    VideoChatViewController *vc = [[VideoChatViewController alloc] init];
    CallManager *callManager = [CallManager sharedCallManager];
    callManager.channelId = callChatModel.filename;
    callManager.targetId = self.targetid;
    callManager.other_name = callChatModel.other_name;
    callManager.other_photo = callChatModel.other_photo;
    callManager.callStatus = RCCallDialing;
    callManager.mediaType = subType;
    callManager.startTime = (int)[[NSDate date] timeIntervalSince1970];
    vc.delegate = self;
    [callManager presentCallViewController:vc];
}

#pragma mark - CallDelegate
- (void)onCallMessageUpdata:(NSString *)channelid callState:(int)newCallState content:(NSString *)content
{
    for (int i = (int)self.dataArray.count - 1; i >= 0; i-- ) {
        ChatModel *model = [self.dataArray objectAtIndex:i];
        if ([channelid isEqualToString:model.filename]) {
            model.extend = [NSString stringWithFormat:@"%d",newCallState];
            model.content = content;
            [model processModelForCell];
            [self.tableView beginUpdates];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            break;
        }
    }
}

#pragma mark - LLMessageCellActionDelegate
- (void)cellDidTapped:(LLMessageBaseCell *)cell{
    if (cell.messageModel.subtype == SUBTYPE_IMAGE) {
        LLMessageImageCell *imagecell = (LLMessageImageCell *)cell;
        ESSinglePictureBrowser *browser = [[ESSinglePictureBrowser alloc] init];
        if(cell.messageModel.issender == 1){
            [browser showSingleImageFromView:imagecell.chatImageView placeholderImage:imagecell.chatImageView.image pictureUrl:[ValueUtil getQiniuUrlByFileName:cell.messageModel.filename isThumbnail:NO] largeImage:[cell.messageModel findThumbnailImage] defaultSize:imagecell.chatImageView.image.size];
        } else {
            [browser showSingleImageFromView:imagecell.chatImageView placeholderImage:imagecell.chatImageView.image pictureUrl:[ValueUtil getQiniuUrlByFileName:cell.messageModel.filename isThumbnail:NO] largeImage:nil defaultSize:imagecell.chatImageView.image.size];
        }
    } else if (cell.messageModel.subtype == SUBTYPE_VOICE) {
        LLMessageVoiceCell *voicecell = (LLMessageVoiceCell *)cell;
        ChatModel *messageModel = voicecell.messageModel;
         
        if (messageModel.issender != 1) {
            if (messageModel.state == INPROGRESS){
                // 下载中
                return;
            } else if (messageModel.state == FAIL){
                [MESSAGEMANAGER downloadChatFile:messageModel];
                return;
            }
         }
        
         if (messageModel.isMediaPlaying) {
             messageModel.isMediaPlaying = NO;
             [voicecell stopVoicePlaying];
             [[LLAudioManager sharedManager] stopPlaying];
        
         } else {
             [[LLAudioManager sharedManager] startPlayingWithPath:[ValueUtil getVoiceLocalPathWithFileKey:messageModel.filename] delegate:self userinfo:cell.messageModel continuePlaying:NO];
         }
    } else if (cell.messageModel.subtype == SUBTYPE_CALL_AUDIO) {
        [self createAndSendCallMessage:SUBTYPE_CALL_AUDIO];
    } else if (cell.messageModel.subtype == SUBTYPE_CALL_VIDEO) {
        [self createAndSendCallMessage:SUBTYPE_CALL_VIDEO];
    }
}

- (void)textCellDidDoubleTapped:(LLMessageTextCell *)cell{
}

- (void)redownloadMessage:(ChatModel *)model{
}

- (void)resendMessage:(ChatModel *)model{
}

- (void)selectControllDidTapped:(ChatModel *)model selected:(BOOL)selected{}

- (void)avatarImageDidTapped:(LLMessageBaseCell *)cell {
    ChatModel *model = cell.messageModel;
    if (model.issender == 0) {
        [UserViewController pushToUser:self userid:model.other_userid name:model.other_name avatar:model.other_photo];
    } else {
        UserModel *userModel = [USERMANAGER userModel];
        [UserViewController pushToUser:self userid:userModel.userid name:userModel.name avatar:userModel.avatar];
    }
}

#pragma mark - 处理Cell菜单
- (void)willShowMenuForCell:(LLMessageBaseCell *)cell {
    
}

- (void)didShowMenuForCell:(LLMessageBaseCell *)cell {
    
}

- (void)willHideMenuForCell:(LLMessageBaseCell *)cell {
    
}

- (void)didHideMenuForCell:(LLMessageBaseCell *)cell {
    
}

- (void)deleteMenuItemDidTapped:(LLMessageBaseCell *)cell {
    ChatModel *model = cell.messageModel;
    [DBHELPER deleteMessageWithDbid:model.dbid];
    [self deleteTableRowWithModel:model withRowAnimation:UITableViewRowAnimationFade];
}

- (void)deleteTableRowWithModel:(ChatModel *)model withRowAnimation:(UITableViewRowAnimation)animation {
    NSInteger index = [self.dataArray indexOfObject:model];
    NSMutableArray<NSIndexPath *> *deleteIndexPaths = [NSMutableArray array];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.dataArray removeObjectAtIndex:index];
    [deleteIndexPaths addObject:indexPath];
    
    if (self.dataArray[index-1].type == TYPE_CHAT_TIPS &&
        ((index == self.dataArray.count) || (self.dataArray[index].type == TYPE_CHAT_TIPS))) {
        [self.dataArray removeObjectAtIndex:index - 1];
        [deleteIndexPaths addObject:[NSIndexPath indexPathForRow:index-1 inSection:0]];
    }
    
    [self.tableView deleteRowsAtIndexPaths:deleteIndexPaths withRowAnimation:animation];
}

- (ZLPhotoActionSheet *)photoActionSheet
{
    ZLPhotoActionSheet *_photoActionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大预览数
    _photoActionSheet.configuration.maxPreviewCount = 20;
    //设置照片最大选择数
    _photoActionSheet.configuration.maxSelectCount = 9;
    _photoActionSheet.configuration.allowSelectVideo = NO;
    _photoActionSheet.configuration.allowEditImage = NO;
    _photoActionSheet.configuration.allowSelectOriginal = NO;//dqdebug
    _photoActionSheet.configuration.navBarColor = [[UINavigationBar appearance] barTintColor];
    _photoActionSheet.configuration.navTitleColor = [[UINavigationBar appearance] tintColor];
    _photoActionSheet.configuration.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    _photoActionSheet.sender = self;
//    _photoActionSheet.arrSelectedAssets = _formPhotoGridViewModel.assetArray;
    WEAKSELF;
    
    [_photoActionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //选好了
        //1 所有选好的图片存到沙盒中
//        weakSelf.prototypeHUD.indicatorView = [[JGProgressHUDRingIndicatorView alloc] init];
//        weakSelf.prototypeHUD.textLabel.text = @"处理中";
//        [weakSelf.prototypeHUD showInView:weakSelf.navigationController.view];
        
        NSMutableArray<NSString *> *sandboxFileNameArray = [[NSMutableArray alloc] init];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *boxpath = [paths objectAtIndex:0];
        int currentTime = (int)[[NSDate date] timeIntervalSince1970];
        for (UIImage *image in images) {
            //先生成随机文件名字
            char data[7];
            for (int x=0;x<7;data[x++] = (char)('A' + (arc4random_uniform(26))));
            NSString *lastname = [[NSString alloc] initWithBytes:data length:7 encoding:NSUTF8StringEncoding];;
            NSString *key = [NSString stringWithFormat:@"%@-%d-%@",_targetid,currentTime,lastname];
            NSString *filePath = [boxpath stringByAppendingPathComponent:key];  // 保存文件的名称
            [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES]; // 保存成功会返回YES
            [sandboxFileNameArray addObject:key];
        }
      
        for (int i = 0; i < images.count; i++) {
            UIImage *tempimage = images[i];
            [weakSelf sendImageMessage:sandboxFileNameArray[i] extend:[ValueUtil convertToJSONData:@{@"width":[NSString stringWithFormat:@"%d",(int)tempimage.size.width],@"height":[NSString stringWithFormat:@"%d",(int)tempimage.size.height]}]];
        }
    }];
    return _photoActionSheet;
}

- (JGProgressHUD *)prototypeHUD {
    if (!_progressHUD) {
        _progressHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleLight];
        _progressHUD.interactionType = JGProgressHUDInteractionTypeBlockAllTouches;
        _progressHUD.animation = [JGProgressHUDFadeZoomAnimation animation];
        _progressHUD.shadow = [JGProgressHUDShadow shadowWithColor:[UIColor blackColor] offset:CGSizeZero radius:5.0 opacity:0.3f];
        _progressHUD.square = YES;
    }
    return _progressHUD;
}


#pragma mark - 录音
- (LLVoiceIndicatorView *)voiceIndicatorView {
    if (!_voiceIndicatorView) {
        _voiceIndicatorView = [[NSBundle mainBundle] loadNibNamed:@"LLVoiceIndicatorView" owner:nil options:nil][0];
    }
    
    return _voiceIndicatorView;
}

- (void)voiceRecordingShouldStart {
    [[LLAudioManager sharedManager] stopPlaying];
    
    if (![LLAudioManager sharedManager].isRecording)
        [[LLAudioManager sharedManager] startRecordingWithDelegate:self];
}

- (void)voicRecordingShouldFinish {
    [[LLAudioManager sharedManager] stopRecording];
}

- (void)voiceRecordingShouldCancel {
    [[LLAudioManager sharedManager] cancelRecording];
}

- (void)voiceRecordingDidDragoutside {
    if (_voiceIndicatorView.superview && _voiceIndicatorView.style != kLLVoiceIndicatorStyleTooLong)
        [self.voiceIndicatorView setStyle:kLLVoiceIndicatorStyleCancel];
}

- (void)voiceRecordingDidDraginside {
    if (_voiceIndicatorView.superview && _voiceIndicatorView.style != kLLVoiceIndicatorStyleTooLong)
        [self.voiceIndicatorView setStyle:kLLVoiceIndicatorStyleRecord];
}

- (void)voiceRecordingTooShort {
    [[LLAudioManager sharedManager] cancelRecording];
    
    [LLTipView showTipView:self.voiceIndicatorView];
    [self.voiceIndicatorView setStyle:kLLVoiceIndicatorStyleTooShort];
    
    [self hideVoiceIndicatorViewAfterDelay:MIN_RECORD_TIME_REQUIRED];
}

- (void)audioRecordAuthorizationDidGranted {
    [LLTipView showTipView:self.voiceIndicatorView];
    [self.voiceIndicatorView setStyle:kLLVoiceIndicatorStyleRecord];
}

//录音开始，此时做一个录音动画
- (void)audioRecordDidStartRecordingWithError:(NSError *)error {
    if (error) {
        if (_voiceIndicatorView.superview)
            [LLTipView hideTipView:_voiceIndicatorView];
        return;
    }
}

- (void)audioRecordDidUpdateVoiceMeter:(double)averagePower {
    if (_voiceIndicatorView.superview) {
        [_voiceIndicatorView updateMetersValue:averagePower];
    }
}

- (void)audioRecordDurationDidChanged:(NSTimeInterval)duration {
}


//移除录音动画
- (void)audioRecordDidFailed {
    if (_voiceIndicatorView.superview) {
        [_voiceIndicatorView setCountDown:0];
        [LLTipView hideTipView:_voiceIndicatorView];
    }
}

- (void)audioRecordDidCancelled {
    [self audioRecordDidFailed];
}

- (NSTimeInterval)audioRecordMaxRecordTime {
    return MAX_RECORD_TIME_ALLOWED - 10;
}

- (void)audioRecordDurationTooShort {
    [LLTipView showTipView:self.voiceIndicatorView];
    [self.voiceIndicatorView setStyle:kLLVoiceIndicatorStyleTooShort];
    
    [self hideVoiceIndicatorViewAfterDelay:2];
}

- (void)audioRecordDurationTooLong {
    if (_voiceIndicatorView.superview) {
        _countDown = 9;
        NSTimer *countDownTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(showCountDownIndicator:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:countDownTimer forMode:NSRunLoopCommonModes];
    }
    
}

- (void)showCountDownIndicator:(NSTimer *)timer {
    if (_voiceIndicatorView.superview && _countDown > 0) {
        [_voiceIndicatorView setCountDown:_countDown];
        --_countDown;
    }else {
        [_voiceIndicatorView setCountDown:0];
        [timer invalidate];
        
        [[LLAudioManager sharedManager] stopRecording];
        
    }
}

//声音录制结束
- (void)audioRecordDidFinishSuccessed:(NSString *)voiceFilePath duration:(CFTimeInterval)duration {
    if (_voiceIndicatorView.superview)  {
        if (_voiceIndicatorView.style == kLLVoiceIndicatorStyleTooLong) {
            WEAKSELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                STRONGSELF;
                if (strongSelf->_voiceIndicatorView.superview)
                    [LLTipView hideTipView:strongSelf->_voiceIndicatorView];
                
                [weakSelf.messageInputView cancelRecordButtonTouchEvent];
            });
        }else {
            [LLTipView hideTipView:_voiceIndicatorView];
        }
    }
    
    [self sendVoiceMessage:[voiceFilePath lastPathComponent] extend:[ValueUtil convertToJSONData:@{@"duration":[NSString stringWithFormat:@"%d",(int)duration]}]];
}

- (void)hideVoiceIndicatorViewAfterDelay:(CGFloat)delay {
    if (_voiceIndicatorView.superview) {
        WEAKSELF;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            STRONGSELF;
            if (strongSelf->_voiceIndicatorView.superview)
                [LLTipView hideTipView:strongSelf->_voiceIndicatorView];
        });
    }
}

#pragma mark - LLDeviceManagerDelegate
- (void)deviceIsCloseToUser:(BOOL)isCloseToUser {
    if (isCloseToUser) {
        //切换为听筒播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }else {
        //切换为扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}


#pragma mark - LLAudioPlayDelegate
- (void)audioPlayDidStarted:(id)userinfo {
    ChatModel *messageModel = (ChatModel *)userinfo;
    LLMessageVoiceCell *cell = (LLMessageVoiceCell *)[self visibleCellForMessageModel:messageModel];
    
    [MESSAGEMANAGER changeVoiceMessageModelPlayStatus:messageModel];
    messageModel.isMediaPlaying = YES;
    [cell startVoicePlaying];
    
    [[LLDeviceManager sharedManager] enableProximitySensor];
    [LLDeviceManager sharedManager].delegate = self;
}

- (void)audioPlayVolumeTooLow {
    [LLTipView showTipView:self.voiceIndicatorView];
    [self.voiceIndicatorView setStyle:kLLVoiceIndicatorStyleVolumeTooLow];
}

- (void)voiceCellDidEndPlaying:(id)userinfo {
    [[LLDeviceManager sharedManager] disableProximitySensor];
    [LLDeviceManager sharedManager].delegate = nil;
    
    if (_voiceIndicatorView.superview)
        [LLTipView hideTipView:_voiceIndicatorView];
    
    ChatModel *messageModel = (ChatModel *)userinfo;
    messageModel.isMediaPlaying = NO;
    LLMessageVoiceCell *cell = (LLMessageVoiceCell *)[self visibleCellForMessageModel:messageModel];
    [cell stopVoicePlaying];
}

- (void)audioPlayDidFailed:(id)userinfo {
    [self voiceCellDidEndPlaying:userinfo];
}

- (void)audioPlayDidStopped:(id)userinfo {
    [self voiceCellDidEndPlaying:userinfo];
}

- (void)audioPlayDidFinished:(id)userinfo {
    [self hideVoiceIndicatorViewAfterDelay:3];
    
    ChatModel *messageModel = (ChatModel *)userinfo;
    messageModel.isMediaPlaying = NO;
    LLMessageVoiceCell *cell = (LLMessageVoiceCell *)[self visibleCellForMessageModel:messageModel];
    [cell stopVoicePlaying];
    
    //下面的循环代码是自动播放下一个未读语音
    NSMutableArray<ChatModel *> *allMessageModels = self.dataArray;
    for (NSInteger index = [allMessageModels indexOfObject:messageModel] + 1, r = allMessageModels.count; index < r; index ++ ) {
        ChatModel *model = allMessageModels[index];
    
        if (model.subtype == SUBTYPE_VOICE && !model.isMediaPlayed && !model.isMediaPlaying && model.issender != 1 && model.state == SUCCESS) {
            NSLog(@"model duration = %f",model.mediaDuration);
            [MESSAGEMANAGER changeVoiceMessageModelPlayStatus:model];
            LLMessageVoiceCell *cell = (LLMessageVoiceCell *)[self visibleCellForMessageModel:model];
            if (cell) {
//                cell.messageModel = cell.messageModel; dqdebug 原来的代码是这一句
                [cell updateVoicePlayingStatus];
            }

            [[LLAudioManager sharedManager] startPlayingWithPath:[ValueUtil getVoiceLocalPathWithFileKey:model.filename] delegate:self userinfo:model continuePlaying:YES];
            
            return;
        }
    }
    
    [[LLAudioManager sharedManager] stopPlaying];

}


@end
