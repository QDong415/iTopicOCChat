//
//  VideoChatViewController.h
//  Agora iOS Tutorial Objective-C
//
//  Created by James Fang on 7/15/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

@class CallManager;

#define RCCallMiniButtonTopMargin 29.0f

#import "BaseViewController.h"
#import "ChatModel.h"
#import "ValueUtil.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

@interface CallBaseViewController : BaseViewController


@property (nonatomic, strong) UIView *subVideoView;
@property (nonatomic, strong) UIView *mainVideoView;
@property (nonatomic, strong) UIImageView *remoteVideoMutedIndicator;
@property (nonatomic, strong) UIView *localVideoMutedBg;
@property (nonatomic, strong) UIImageView *localVideoMutedIndicator;

@property (nonatomic, strong) UIButton *speakerButton;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *remoteNameLabel;//对端的名字Label
@property (nonatomic, strong) UIImageView *remotePortraitView;//对端的头像View



/*!
 接听Button
 */
@property(nonatomic, strong) UIButton *acceptButton;

/*!
 挂断Button
 */
@property(nonatomic, strong) UIButton *hangupButton;

/*!
 提示Label
 */
@property(nonatomic, strong) UILabel *tipsLabel;
/*!
 静音Button
 */
@property(nonatomic, strong) UIButton *muteButton;

@property(nonatomic, strong) UIButton *cameraSwitchButton;

@property(nonatomic, strong) UIButton *cameraCloseButton;

- (void)resetLayout:(CallManager *)_callManager ;

@end

