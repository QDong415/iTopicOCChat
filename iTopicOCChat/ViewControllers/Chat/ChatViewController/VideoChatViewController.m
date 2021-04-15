//
//  VideoChatViewController.m
//  Agora iOS Tutorial Objective-C
//
//  Created by James Fang on 7/15/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

#import "VideoChatViewController.h"

#import "CallManager.h"
#import "BaseResponse.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "DBHelper.h"
#import "StringListResponse.h"

@interface VideoChatViewController () <CallManagerDelegate>

@property(nonatomic, strong) CallManager *callManager;

@property(nonatomic, strong) AgoraRtcVideoCanvas *localVideoCanvas;
@property(nonatomic, strong) AgoraRtcVideoCanvas *remoteVideoCanvas;

@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, assign) BOOL needPlayingRingAfterForeground;
@property(nonatomic, strong) NSTimer *activeTimer;
@property(nonatomic, weak) NSTimer *vibrateTimer;

@end

@implementation VideoChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES;
    
    _callManager = [CallManager sharedCallManager];
    _callManager.delegate = self;
    
    if(_callManager.callStatus == RCCallIncoming){
        self.needPlayingRingAfterForeground = YES;
    }
    
    [self registerForegroundNotification];
    
    [self.remotePortraitView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:_callManager.other_photo  isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    
    [_callManager initializeAgoraEngine];
    
    if(_callManager.mediaType == SUBTYPE_CALL_VIDEO){
        [_callManager setupVideo];
        [self setupLocalVideo:self.subVideoView];
        
        self.subVideoView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(subViewAction:)];
        [self.subVideoView addGestureRecognizer:tap];
        
    } else if(_callManager.mediaType == SUBTYPE_CALL_AUDIO){
        [_callManager.agoraKit enableAudio];
    }
    
    if (_callManager.callStatus == RCCallDialing) {
        [self startCallDialingRing];
        [_callManager.agoraKit joinChannelByToken:nil channelId:_callManager.channelId info:nil uid:[[USERMANAGER getUserId] intValue] joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        }];
//        [_callManager.agoraKit setEnableSpeakerphone:YES];
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (_callManager.callStatus == RCCallActive) {
        [self updateActiveTimer];
        [self startActiveTimer];
    } else if (_callManager.callStatus == RCCallDialing) {
        self.tipsLabel.text = @"正在等待对方接受邀请...";
    } else if (_callManager.callStatus == RCCallIncoming) {
        if (self.needPlayingRingAfterForeground) {
            [self shouldRingForIncomingCall];
        }
        if (_callManager.mediaType == SUBTYPE_CALL_AUDIO) {
            self.tipsLabel.text = @"邀请你语音通话";
        } else {
            self.tipsLabel.text = @"邀请你视频通话";
        }
    }
    else if (_callManager.callStatus == RCCallHangup) {//进入这里
        [self callDidDisconnect:NO];
    }

    [self resetLayout:_callManager];
}

- (void)registerForegroundNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAudioRouteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)setupLocalVideo:(UIView *)localVideoView {
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = [[USERMANAGER getUserId] intValue];
    videoCanvas.view = [[UIView alloc] initWithFrame:localVideoView.bounds];
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    self.localVideoCanvas = videoCanvas;
    [localVideoView addSubview:videoCanvas.view];
    [_callManager.agoraKit setupLocalVideo:videoCanvas];
    [_callManager.agoraKit startPreview];
}

- (IBAction)subViewAction:(id)sender {
    [self switchView:self.localVideoCanvas];
    [self switchView:self.remoteVideoCanvas];
}

- (void)switchView:(AgoraRtcVideoCanvas *)canvas {
    
    UIView *parent = [self removeFromParent:canvas];
    if (parent == self.subVideoView) {
        canvas.view.frame = self.mainVideoView.bounds;
        [self.mainVideoView addSubview:canvas.view];
        
    } else if (parent == self.mainVideoView) {
        canvas.view.frame = self.subVideoView.bounds;
        [self.subVideoView addSubview:canvas.view];
        [self.subVideoView bringSubviewToFront:canvas.view];
    }
}

- (void)dealloc {
    [self stopPlayRing];
    if(_callManager.mediaType == SUBTYPE_CALL_VIDEO){
        [_callManager.agoraKit disableVideo];
    } else if(_callManager.mediaType == SUBTYPE_CALL_AUDIO){
        [_callManager.agoraKit disableAudio];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)appDidBecomeActive {
    if (self.needPlayingRingAfterForeground) {
        [self shouldRingForIncomingCall];
    }
}

- (void)checkOppoStillInChannel {
    [NETWORK getDataByApi:@"chat/check_channel" parameters:[NSDictionary dictionaryWithObjectsAndKeys:_callManager.channelId,@"channelid", nil] responseClass:[StringListResponse class] success:^(NSURLSessionTask *task, id responseObject){
        StringListResponse *response = (StringListResponse *)responseObject;
        if ([response isSuccess]) {
            BOOL exist = NO;
            for (NSString *item in response.data.items) {
                if ([[NSString stringWithFormat:@"%@",item] isEqualToString:_callManager.targetId]){
                    exist = YES;
                    break;
                }
            }
            if(!exist){
                NSLog(@"对方不在了，我也退出");
                [self leaveChannel:NO];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
    }];
}


#pragma mark - CallManagerDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    
    self.mainVideoView.hidden = NO;
    
    UIView *parent = self.mainVideoView;
    if (_localVideoCanvas.view.superview == parent) {
        parent = self.subVideoView;
    }
    
    if (_remoteVideoCanvas) {
        return;
    }

    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.view = [[UIView alloc] initWithFrame:parent.bounds];
    videoCanvas.renderMode = AgoraVideoRenderModeHidden;
    videoCanvas.uid = uid;
    [parent addSubview:videoCanvas.view];
    
    self.remoteVideoCanvas = videoCanvas;
    [_callManager.agoraKit setupRemoteVideo:self.remoteVideoCanvas];
}

/**
 * uid新加入频道的远端用户/主播 ID。如果 joinChannelByToken 中指定了 uid，则此处返回该 ID；否则使用 Agora 服务器自动分配的 ID。
 * elapsed从本地用户加入频道 joinChannelByToken 或 joinChannelByUserAccount 开始到发生此事件过去的时间（ms）。
 * 经过测试，我自己加入频道 不会进入这里
 **/
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    [_callManager.agoraKit stopAudioMixing];
    //之前已经在CallManager里处理好status了
    [self resetLayout:_callManager];
    self.tipsLabel.text =  @"";
    [self startActiveTimer];
}

//远端用户（通信场景）/主播（直播场景）离开当前频道回调
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason
{
    [self leaveChannel:NO];
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid
{
    if (uid == [_callManager.targetId intValue]){
        self.mainVideoView.hidden = muted;
        self.remoteVideoMutedIndicator.hidden = !muted;
    }
}

- (void)oppoRefuseMyDialing
{
    if (_callManager.callStatus == RCCallDialing){
        //对方拒绝了我的呼叫
        [self leaveChannel:NO];
        
    } else if (_callManager.callStatus == RCCallIncoming){
        //我还没接呢，对方就取消通话了
        [self callDidDisconnect:YES];
    }
}

- (IBAction)hangupButtonClicked:(UIButton *)sender {
    if (_callManager.callStatus == RCCallIncoming) {
        //来电话我没接，选择了直接挂断
            
        NSString *resultContent = [self callDidDisconnect:YES];
            
        //告诉服务器，我主动挂断了
        [self uploadStatusToService:RCCallHangup content:resultContent needPushToOp:YES];
    } else {
        //通话中 or 呼叫中
        [self leaveChannel:YES];
    }
}

- (void)leaveChannel:(BOOL)hangUpByMyself {
    self.hangupButton.enabled = NO;//dq 防止多次点击
    
    WEAKSELF;
    [_callManager.agoraKit leaveChannel:^(AgoraChannelStats *stat) {
    //        [self hideControlButtons];
            
        //看看之前的状态，如果是我正在呼出，对方未接听，我就挂断，那么需要push给对面
        RCCallStatus preCallStatus = weakSelf.callManager.callStatus;
        
        NSString *resultContent = [weakSelf callDidDisconnect:YES];
            
        //告诉服务器，我主动挂断了
        if (hangUpByMyself) {
            [weakSelf uploadStatusToService:RCCallHangup content:resultContent needPushToOp:preCallStatus == RCCallDialing];
        }
    }];
}

- (void)uploadStatusToService:(RCCallStatus)callStatus content:(NSString *)content needPushToOp:(BOOL)push
{
    NSMutableDictionary* params = [NSMutableDictionary new];
    [params setObject:[NSString stringWithFormat:@"%@",_callManager.channelId] forKey:@"channelid"];
    [params setObject:[NSString stringWithFormat:@"%d",_callManager.mediaType] forKey:@"subtype"];
    [params setObject:[NSString stringWithFormat:@"%ld",callStatus] forKey:@"status"];
    [params setObject:content forKey:@"content"];
    [params setObject:_callManager.targetId forKey:@"to_userid"];
    [params setObject:push?@"1":@"0" forKey:@"push"];
    [NETWORK postDataByApi:@"chat/hangup" parameters:params responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
    } failure:^(NSURLSessionTask *operation, NSError *error) {
    }];
}


//点击接听按钮
- (IBAction)acceptButtonClicked:(UIButton *)sender {
    WEAKSELF;
    [self stopPlayRing];
    sender.enabled = NO;

    [_callManager.agoraKit joinChannelByToken:nil channelId:_callManager.channelId info:nil uid:[[USERMANAGER getUserId] intValue] joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        weakSelf.callManager.callStatus = RCCallActive;
        [weakSelf resetLayout:weakSelf.callManager];
        [weakSelf checkOppoStillInChannel];
    }];
    [_callManager.agoraKit setEnableSpeakerphone:YES];
    self.speakerButton.selected = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (IBAction)didClickMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_callManager.agoraKit muteLocalAudioStream:sender.selected];
}

- (IBAction)didClickVideoMuteButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_callManager.agoraKit muteLocalVideoStream:sender.selected];
    self.subVideoView.hidden = sender.selected;
    self.localVideoMutedBg.hidden = !sender.selected;
    self.localVideoMutedIndicator.hidden = !sender.selected;
}

- (IBAction)didClickSwitchCameraButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_callManager.agoraKit switchCamera];
}

//免提
- (IBAction)speakerButtonClicked:(UIButton *)sender {
    sender.selected = !sender.selected;
    [_callManager.agoraKit setEnableSpeakerphone:sender.selected];
}

- (void)startPlayRing:(NSString *)ringPath {
    if (ringPath) {
        if (self.audioPlayer) {
            [self stopPlayRing];
        }
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if (_callManager.callStatus == RCCallDialing) {
            [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionAllowBluetooth | AVAudioSessionCategoryOptionAllowBluetoothA2DP error:nil];
        } else {
            //默认情况按静音或者锁屏键会静音
            [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
            [self triggerVibrate];
        }

        [audioSession setActive:YES error:nil];

        NSURL *url = [NSURL fileURLWithPath:ringPath];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.volume = 1.0;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }
}

- (void)stopPlayRing {
    if (self.vibrateTimer) {
        [self.vibrateTimer invalidate];
        self.vibrateTimer = nil;
    }
    
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        //设置铃声停止后恢复其他app的声音
        [[AVAudioSession sharedInstance] setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation
                                             error:nil];
    }
}

/*!
 收到电话，可以播放铃声
 */
- (void)shouldRingForIncomingCall {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath = [[[NSBundle mainBundle] pathForResource:@"Ring" ofType:@"bundle"]
            stringByAppendingPathComponent:@"voip/voip_call.mp3"];
        [self startPlayRing:ringPath];
        self.needPlayingRingAfterForeground = NO;
    } else {
        self.needPlayingRingAfterForeground = YES;
    }
}


/*!
 * 通话已结束
 */
#pragma mark private
- (NSString *)callDidDisconnect:(BOOL)hangUpByMyself {
    
    //重要，全局变量设置为挂断
    _callManager.callStatus = RCCallHangup;
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;//自动锁屏
    
    self.tipsLabel.text = hangUpByMyself?@"通话已经结束":@"对方已挂断";

    NSString *content = @"";
    if (_callManager.connectedTime == 0) {
        content = hangUpByMyself?@"对方未接听":@"对方已挂断";
        [DBHELPER updateCallMessageState:_callManager.channelId callState:RCCallHangup content:content];
    } else {
        long sec = [[NSDate date] timeIntervalSince1970] - _callManager.connectedTime;
        content = [NSString stringWithFormat:@"%@ %@",_callManager.mediaType == SUBTYPE_CALL_VIDEO?@"视频时长":@"通话时长" ,[self getReadableStringForTime:sec]];
        [DBHELPER updateCallMessageState:_callManager.channelId callState:RCCallHangup content:content];
    }
    if ([self.delegate respondsToSelector:@selector(onCallMessageUpdata:callState:content:)]){
        [self.delegate onCallMessageUpdata:_callManager.channelId callState:RCCallHangup content:content];
    }
  
    _callManager.connectedTime = 0;
    _callManager.startTime = 0;
    
    [self stopActiveTimer];
    [self shouldStopAlertAndRing];
    
    [self removeFromParent:self.localVideoCanvas];
    self.localVideoCanvas = nil;
    [self removeFromParent:self.remoteVideoCanvas];
    self.remoteVideoCanvas = nil;
    
    [_callManager.agoraKit setupLocalVideo:nil];
    
    //再震动一次
    [self triggerVibrateAction];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[CallManager sharedCallManager] dismissCallViewController:self];
    });
    return content;

}

- (UIView *)removeFromParent:(AgoraRtcVideoCanvas *)canvas {
    UIView *superView = canvas.view.superview;
    if (canvas.view && superView){
        [canvas.view removeFromSuperview];
        return superView;
    }
    return nil;
}

/*!
 停止播放铃声(通话接通或挂断)
 */
- (void)shouldStopAlertAndRing {
    self.needPlayingRingAfterForeground = NO;
    [self stopPlayRing];
}

- (void)triggerVibrate {
    [self.vibrateTimer invalidate];
    self.vibrateTimer = nil;
    
    self.vibrateTimer = [NSTimer scheduledTimerWithTimeInterval:2.f target:self selector:@selector(triggerVibrateAction) userInfo:nil repeats:YES];
}

- (void)triggerVibrateAction
{
    if (@available(iOS 9.0, *)) {
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil);
    } else {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

- (void)startCallDialingRing {
    //经过测试，如果用传统的avplayer去播放嘟嘟声音，问题很多（如果在join之前就播放，join后那两秒声音很杂；如果是join之后播放，声音特别小）
    //后来发现声网sdk提供了专门在频道中期间的播放系统声音startAudioMixing，测试后发现这个方法只能在join之后起效果，不join无效果
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        NSString *ringPath = [[[NSBundle mainBundle] pathForResource:@"Ring" ofType:@"bundle"]
                              stringByAppendingPathComponent:@"voip/voip_calling_ring.mp3"];
       
        [_callManager.agoraKit startAudioMixing:ringPath loopback:YES replace:NO cycle:-1];
    }
}

- (void)startActiveTimer {
    [_activeTimer invalidate];
    _activeTimer = nil;
    self.activeTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                        target:self
                                                      selector:@selector(updateActiveTimer)
                                                      userInfo:nil
                                                       repeats:YES];
    [self.activeTimer fire];
}

- (void)stopActiveTimer {
    if (self.activeTimer) {
        [self.activeTimer invalidate];
        self.activeTimer = nil;
    }
}

- (void)updateActiveTimer {
//    if (hangupButtonClick) return;
    CallManager *callManager = [CallManager sharedCallManager];
    long sec = [[NSDate date] timeIntervalSince1970]  - callManager.connectedTime;
    self.timeLabel.text = [self getReadableStringForTime:sec];

    if (sec >= 3600 && self.timeLabel.frame.size.width != 80)
    {
//        self.timeLabel.frame = CGRectMake(self.view.frame.size.width / 2 - 114.0 / 2, RCCallMiniButtonTopMargin + RCCallMiniLabelHeight + RCCallTimeTopMargin + kTopNavHeight,
//                                          100.0, RCCallTimeLabelHeight);
        self.timeLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (NSString *)getReadableStringForTime:(long)sec {
    if (sec < 60 * 60) {
        return [NSString stringWithFormat:@"%02ld:%02ld", sec / 60, sec % 60];
    } else {
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", sec / 60 / 60, (sec / 60) % 60, sec % 60];
    }
}




@end
