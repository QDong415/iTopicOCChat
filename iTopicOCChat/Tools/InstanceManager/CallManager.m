//
//  CallManager.m
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "CallManager.h"
#import "ValueUtil.h"
#import "VideoChatViewController.h"

@interface CallManager () <AgoraRtcEngineDelegate>

@property (nonatomic, strong) NSMutableArray *callWindows;

@end

@implementation CallManager

+ (id)sharedCallManager{
    static CallManager *_sharedCallManager=nil;
    static dispatch_once_t predUser;
    dispatch_once(&predUser, ^{
        _sharedCallManager = [[CallManager alloc] init];
        _sharedCallManager.callWindows = [[NSMutableArray alloc] init];
    });
    return _sharedCallManager;
}

- (void)initializeAgoraEngine {
    if (!self.agoraKit) {
        self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:@"eba4da1c39f94e23a06dbf32dbaa3768" delegate:self];
    }
}

- (void)setupVideo {
    [self.agoraKit enableVideo];
    [self.agoraKit enableAudio];
    AgoraVideoEncoderConfiguration *encoderConfiguration =
    [[AgoraVideoEncoderConfiguration alloc] initWithSize:AgoraVideoDimension640x360
                                               frameRate:AgoraVideoFrameRateFps24
                                                 bitrate:AgoraVideoBitrateStandard
                                         orientationMode:AgoraVideoOutputOrientationModeAdaptative];
    [self.agoraKit setVideoEncoderConfiguration:encoderConfiguration];
}



#pragma mark - AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:firstRemoteVideoDecodedOfUid:size:elapsed:)]){
        [self.delegate rtcEngine:engine firstRemoteVideoDecodedOfUid:uid size:size elapsed:elapsed];
    }
}

/**
 * uid新加入频道的远端用户/主播 ID。如果 joinChannelByToken 中指定了 uid，则此处返回该 ID；否则使用 Agora 服务器自动分配的 ID。
 * elapsed从本地用户加入频道 joinChannelByToken 或 joinChannelByUserAccount 开始到发生此事件过去的时间（ms）。
 **/
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    self.callStatus = RCCallActive;
    self.connectedTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"有人加入频道");
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didJoinedOfUid:elapsed:)]){
        [self.delegate rtcEngine:engine didJoinedOfUid:uid elapsed:elapsed];
    }
}

//远端用户（通信场景）/主播（直播场景）离开当前频道回调
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason
{
    NSLog(@"有人离开频道");
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:reason:)]){
        [self.delegate rtcEngine:engine didOfflineOfUid:uid reason:reason];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid
{
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didVideoMuted:byUid:)]){
        [self.delegate rtcEngine:engine didVideoMuted:muted byUid:uid];
    }
}

- (void)oppoRefuseMyDialing
{
    if ([self.delegate respondsToSelector:@selector(oppoRefuseMyDialing)]){
        [self.delegate oppoRefuseMyDialing];
    }
}

- (void)presentCallViewController:(UIViewController *)viewController {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    UIWindow *activityWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    activityWindow.windowLevel = UIWindowLevelNormal;
    activityWindow.rootViewController = viewController;
    BOOL needUpdata = [ValueUtil compareVesion:@"13.0" currentVersion:[UIDevice currentDevice].systemVersion];
    if (!needUpdata) {
#ifdef __IPHONE_13_0
        [activityWindow setWindowScene:[UIApplication sharedApplication].keyWindow.windowScene];
#endif
    }
    [activityWindow makeKeyAndVisible];
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    animation.type = kCATransitionMoveIn;     //可更改为其他方式
    animation.subtype = kCATransitionFromBottom; //可更改为其他方式
    [[activityWindow layer] addAnimation:animation forKey:nil];
    [self.callWindows addObject:activityWindow];
}

- (void)dismissCallViewController:(UIViewController *)viewController {

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    if ([viewController isKindOfClass:[VideoChatViewController class]]) {
        UIViewController *rootVC = viewController;
        while (rootVC.parentViewController) {
            rootVC = rootVC.parentViewController;
        }
        viewController = rootVC;
    }

    for (UIWindow *window in self.callWindows) {
        if (window.rootViewController == viewController) {
            [window resignKeyWindow];
            window.hidden = YES;
            [[UIApplication sharedApplication].delegate.window makeKeyWindow];
            [self.callWindows removeObject:window];
            break;
        }
    }
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
