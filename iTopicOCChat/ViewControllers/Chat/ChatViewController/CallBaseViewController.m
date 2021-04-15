//
//  VideoChatViewController.m
//  Agora iOS Tutorial Objective-C
//
//  Created by James Fang on 7/15/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//


#define RCCallHeaderLength 110.0f
#define RCCallButtonLength 65.0f
#define RCCallMiniButtonLength 28.0f

#define RCCallCustomButtonLength 68.0f
#define RCCallLabelHeight 25.0f
#define RCCallMiniLabelHeight 18.0f
#define RCCallTimeLabelHeight 14.0f
#define RCCallVerticalMargin 32.0f
#define RCCallHorizontalMargin 15.f
#define RCCallHorizontalMiddleMargin 44.5f
#define RCCallHorizontalBigMargin 72.5f
#define RCCallInsideMargin 7.75f
#define RCCallTimeTopMargin 12.0f
#define RCCallInsideMiniMargin 6.5f
#define RCCallTopMargin 15.0f
#define RCCallTipsLabelTopMargin 56.5f
#define RCCallButtonInsideMargin 4.0f
#define RCCallButtonHorizontalMargin 44.5f
#define RCCallButtonBottomMargin 29.5f
#define RCCallCollectionCellWidth 55.0f
#define RCCallTopGGradientHeight 100

#import "CallBaseViewController.h"
#import "CallManager.h"

@interface CallBaseViewController ()

@end

@implementation CallBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGBCOLOR(20, 28, 36);
    
    _mainVideoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _mainVideoView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:_mainVideoView];
    
    _remoteVideoMutedIndicator = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"videoMutedIndicator"]];
    _remoteVideoMutedIndicator.frame = CGRectMake(0, 0, 120, 100);
    _remoteVideoMutedIndicator.center = _mainVideoView.center;
    [self.view addSubview:_remoteVideoMutedIndicator];
    
    
    _remotePortraitView = [[UIImageView alloc] init];
    [self.view addSubview:_remotePortraitView];
    _remotePortraitView.hidden = YES;
   
    _remotePortraitView.layer.borderWidth = 4;
    _remotePortraitView.layer.borderColor = [UIColor whiteColor].CGColor;
    _remotePortraitView.layer.cornerRadius = 14;
    _remotePortraitView.layer.masksToBounds = YES;
    
    _remoteNameLabel = [[UILabel alloc] init];
    _remoteNameLabel.backgroundColor = [UIColor clearColor];
    _remoteNameLabel.textColor = [UIColor whiteColor];
    _remoteNameLabel.layer.shadowOpacity = 0.8;
    _remoteNameLabel.layer.shadowRadius = 3.0;
    _remoteNameLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _remoteNameLabel.layer.shadowOffset = CGSizeMake(0, 1);
    _remoteNameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
    _remoteNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_remoteNameLabel];
    _remoteNameLabel.hidden = YES;
    
    _acceptButton = [[UIButton alloc] init];
    [_acceptButton setImage:[UIImage imageNamed:@"answer.png"] forState:UIControlStateNormal];
    [_acceptButton setImage:[UIImage imageNamed:@"answer_hover.png"] forState:UIControlStateHighlighted];
    [_acceptButton setTitle:@"接听" forState:UIControlStateNormal];
    [_acceptButton addTarget:self action:@selector(acceptButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _acceptButton.titleLabel.layer.shadowOpacity = 0.8;
    _acceptButton.titleLabel.layer.shadowRadius = 3.0;
    _acceptButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _acceptButton.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:_acceptButton];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.layer.shadowOpacity = 0.8;
    _timeLabel.layer.shadowRadius = 3.0;
    _timeLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _timeLabel.layer.shadowOffset = CGSizeMake(0, 1);    
    _timeLabel.font = [UIFont systemFontOfSize:17];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_timeLabel];
    _timeLabel.hidden = YES;
    
    _muteButton = [[UIButton alloc] init];
    [_muteButton setImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateNormal];
    [_muteButton setImage:[UIImage imageNamed:@"mute_hover.png"] forState:UIControlStateHighlighted];
    [_muteButton setImage:[UIImage imageNamed:@"mute_hover.png"] forState:UIControlStateSelected];
    [_muteButton setTitle:@"静音" forState:UIControlStateNormal];
    [_muteButton addTarget:self action:@selector(didClickMuteButton:) forControlEvents:UIControlEventTouchUpInside];
    _muteButton.titleLabel.layer.shadowOpacity = 0.8;
    _muteButton.titleLabel.layer.shadowRadius = 3.0;
    _muteButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _muteButton.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:_muteButton];
    _muteButton.hidden = YES;
    
    _tipsLabel = [[UILabel alloc] init];
    _tipsLabel.backgroundColor = [UIColor clearColor];
    _tipsLabel.textColor = [UIColor whiteColor];
    _tipsLabel.font = [UIFont systemFontOfSize:17];
    _tipsLabel.textAlignment = NSTextAlignmentCenter;
    _tipsLabel.layer.shadowOpacity = 0.8;
    _tipsLabel.layer.shadowRadius = 3.0;
    _tipsLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _tipsLabel.layer.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:_tipsLabel];
    _tipsLabel.hidden = YES;
    
    _speakerButton = [[UIButton alloc] init];
    [_speakerButton setImage:[UIImage imageNamed:@"handfree.png"] forState:UIControlStateNormal];
    [_speakerButton setImage:[UIImage imageNamed:@"handfree_hover.png"] forState:UIControlStateHighlighted];
    [_speakerButton setImage:[UIImage imageNamed:@"handfree_hover.png"] forState:UIControlStateSelected];
     [_speakerButton addTarget:self action:@selector(speakerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_speakerButton setTitle:@"免提" forState:UIControlStateNormal];
    _speakerButton.titleLabel.layer.shadowOpacity = 0.8;
    _speakerButton.titleLabel.layer.shadowRadius = 3.0;
    _speakerButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _speakerButton.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:_speakerButton];
    _speakerButton.hidden = YES;
    
    _hangupButton = [[UIButton alloc] init];
    [_hangupButton setImage:[UIImage imageNamed:@"hang_up.png"] forState:UIControlStateNormal];
    [_hangupButton setImage:[UIImage imageNamed:@"hang_up_hover.png"] forState:UIControlStateHighlighted];
    [_hangupButton setTitle:@"挂断" forState:UIControlStateNormal];
    [_hangupButton addTarget:self action:@selector(hangupButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    _hangupButton.titleLabel.layer.shadowOpacity = 0.8;
    _hangupButton.titleLabel.layer.shadowRadius = 3.0;
    _hangupButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _hangupButton.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:_hangupButton];
    _hangupButton.hidden = YES;
    
    _cameraSwitchButton = [[UIButton alloc] init];
    [_cameraSwitchButton setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [_cameraSwitchButton setImage:[UIImage imageNamed:@"camera_hover.png"] forState:UIControlStateHighlighted];
    [_cameraSwitchButton setImage:[UIImage imageNamed:@"camera_hover.png"] forState:UIControlStateSelected];
    [_cameraSwitchButton addTarget:self action:@selector(didClickSwitchCameraButton:)
                  forControlEvents:UIControlEventTouchUpInside];
    [_cameraSwitchButton setTitle:@"切换摄像头" forState:UIControlStateNormal];
    _cameraSwitchButton.titleLabel.layer.shadowOpacity = 0.8;
    _cameraSwitchButton.titleLabel.layer.shadowRadius = 3.0;
    _cameraSwitchButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _cameraSwitchButton.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    [self.view addSubview:_cameraSwitchButton];
    _cameraSwitchButton.hidden = YES;
    
    _cameraCloseButton = [[UIButton alloc] init];
    [_cameraCloseButton setImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateNormal];
    [_cameraCloseButton setImage:[UIImage imageNamed:@"video.png"] forState:UIControlStateHighlighted];
    [_cameraCloseButton setImage:[UIImage imageNamed:@"video_hover.png"] forState:UIControlStateSelected];
    [_cameraCloseButton setTitle:@"关闭摄像头" forState:UIControlStateNormal];
    [_cameraCloseButton setTitle:@"打开摄像头" forState:UIControlStateSelected];
//    [_cameraCloseButton setSelected:!callManager.cameraEnabled];
    [_cameraCloseButton addTarget:self
                           action:@selector(didClickVideoMuteButton:)
                 forControlEvents:UIControlEventTouchUpInside];
    _cameraCloseButton.titleLabel.layer.shadowOpacity = 0.8;
    _cameraCloseButton.titleLabel.layer.shadowRadius = 3.0;
    _cameraCloseButton.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    _cameraCloseButton.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    
    [self.view addSubview:_cameraCloseButton];
    _cameraCloseButton.hidden = YES;
    
    _subVideoView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 16 - 95, kStatusBarHeight + 30, 95, 167)];
    [self.view addSubview:_subVideoView];
    
    _localVideoMutedBg = [[UIView alloc] initWithFrame:_subVideoView.frame];
    _localVideoMutedBg.backgroundColor = RGBCOLOR(58, 63, 77);
    [self.view addSubview:_localVideoMutedBg];
    
    _localVideoMutedIndicator = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"videoMutedIndicator"]];
    _localVideoMutedIndicator.frame = CGRectMake(0, 0, 36, 30);
    [self.view addSubview:_localVideoMutedIndicator];
    _localVideoMutedIndicator.center = _localVideoMutedBg.center;
    [self.view bringSubviewToFront:_subVideoView];
    
    [self hideVideoMuted];

}


#pragma mark - layout
- (void)resetLayout:(CallManager *)_callManager {
    
    [self resetLayoutSingle:_callManager];
    
    RCCallStatus callStatus = _callManager.callStatus;
    
    int RCCallExtraSpace = 0;
    if (@available(iOS 11.0, *)) {
        RCCallExtraSpace = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
    }
    
    if (_callManager.mediaType == SUBTYPE_CALL_VIDEO) {

        if (callStatus == RCCallDialing) {

        } else if (callStatus == RCCallActive) {

        } else if (callStatus != RCCallHangup) {
         
        }

        if (callStatus == RCCallActive) {
            self.timeLabel.frame =
                CGRectMake(RCCallHorizontalMargin, RCCallMiniButtonTopMargin + RCCallMiniLabelHeight + RCCallTimeTopMargin + kStatusBarHeight,
                           self.view.frame.size.width - RCCallHorizontalMargin * 2,RCCallTimeLabelHeight);
            self.timeLabel.hidden = NO;
        } else if (callStatus != RCCallHangup) {
            self.timeLabel.hidden = YES;
        }

        if (callStatus == RCCallActive) {
            self.tipsLabel.frame =
                CGRectMake(RCCallHorizontalMargin,
                           self.view.frame.size.height - RCCallButtonBottomMargin * 3 - RCCallButtonLength - RCCallExtraSpace  - 20,
                           self.view.frame.size.width - RCCallHorizontalMargin * 2, RCCallLabelHeight);
        } else if (callStatus == RCCallDialing) {
            self.tipsLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                               CGRectGetMaxY(self.remoteNameLabel.frame) + 10, self.view.frame.size.width - RCCallHorizontalMargin * 2 , RCCallLabelHeight);
            
        } else if (callStatus == RCCallIncoming ) {
            self.tipsLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                                          CGRectGetMaxY(self.remoteNameLabel.frame) + 10, self.view.frame.size.width - RCCallHorizontalMargin * 2 , RCCallLabelHeight);
        } else if (callStatus == RCCallHangup) {
            self.tipsLabel.frame = CGRectMake(
                RCCallHorizontalMargin,
                self.view.frame.size.height - RCCallButtonBottomMargin * 3 - RCCallButtonLength - RCCallExtraSpace - 20,
                self.view.frame.size.width - RCCallHorizontalMargin * 2, RCCallLabelHeight);
        }
        self.tipsLabel.hidden = NO;

        if (callStatus == RCCallDialing) {
            self.muteButton.frame = CGRectMake(RCCallHorizontalMiddleMargin,
                                               self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength -  RCCallExtraSpace,
                                               RCCallCustomButtonLength, RCCallCustomButtonLength);
            [self layoutTextUnderImageButton:self.muteButton largeButton:NO];
            self.muteButton.hidden = NO;
            self.muteButton.enabled = NO;
        } else if (callStatus == RCCallActive) {
            self.muteButton.frame = CGRectMake(RCCallHorizontalMiddleMargin,
                                               self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength - RCCallExtraSpace,
                                               RCCallCustomButtonLength, RCCallCustomButtonLength);
            [self layoutTextUnderImageButton:self.muteButton largeButton:NO];
            self.muteButton.hidden = NO;
            self.muteButton.enabled = YES;
        }else if (callStatus != RCCallHangup) {
            self.muteButton.hidden = YES;
            self.muteButton.enabled = NO;
        }

        if (callStatus == RCCallDialing) {
            self.speakerButton.frame = CGRectMake(self.view.frame.size.width -RCCallHorizontalMiddleMargin - RCCallCustomButtonLength,
                                               self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength - RCCallExtraSpace,
                                               RCCallCustomButtonLength, RCCallCustomButtonLength);
            [self layoutTextUnderImageButton:self.speakerButton largeButton:NO];
            self.speakerButton.hidden = NO;
            [self setSpeakerEnable:NO];
            if ([self isHeadsetPluggedIn])
                [self reloadSpeakerRoute:NO];
        } else if (callStatus != RCCallHangup) {
            self.speakerButton.hidden = YES;
        }

        if (callStatus == RCCallDialing) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - RCCallButtonLength) / 2,
                       self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace, RCCallButtonLength,
                       RCCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton largeButton:YES];
            self.hangupButton.hidden = NO;

            self.acceptButton.hidden = YES;
        } else if (callStatus == RCCallIncoming ) {
            self.hangupButton.frame = CGRectMake(
                                                 RCCallHorizontalBigMargin, self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace,
                                                 RCCallButtonLength, RCCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton largeButton:NO];
            self.hangupButton.hidden = NO;

            self.acceptButton.frame =
            CGRectMake(
                       self.view.frame.size.width - RCCallHorizontalBigMargin - RCCallButtonLength, self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace,
                       RCCallButtonLength, RCCallButtonLength);
            [self layoutTextUnderImageButton:self.acceptButton largeButton:NO];
            self.acceptButton.hidden = NO;
        } else if (callStatus == RCCallActive) {
            self.hangupButton.frame =
            CGRectMake((self.view.frame.size.width - RCCallButtonLength) / 2,
                       self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace, RCCallButtonLength,
                       RCCallButtonLength);
            [self layoutTextUnderImageButton:self.hangupButton largeButton:YES];
            self.hangupButton.hidden = NO;

            self.acceptButton.hidden = YES;
        }

        if (callStatus == RCCallActive) {
            self.cameraSwitchButton.frame = CGRectMake(self.view.frame.size.width -RCCallHorizontalMiddleMargin - RCCallCustomButtonLength,self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength - RCCallExtraSpace,RCCallCustomButtonLength, RCCallCustomButtonLength);
            [self layoutTextUnderImageButton:self.cameraSwitchButton largeButton:NO];
            self.cameraSwitchButton.hidden = NO;
        } else if (callStatus != RCCallHangup) {
            self.cameraSwitchButton.hidden = YES;
        }

        if (callStatus == RCCallActive) {
            self.cameraCloseButton.frame =
            CGRectMake(self.view.frame.size.width - RCCallHorizontalMiddleMargin - RCCallCustomButtonLength,
                       CGRectGetMinY(self.cameraSwitchButton.frame) - RCCallCustomButtonLength  - 30, RCCallCustomButtonLength, RCCallCustomButtonLength);
            [self layoutTextUnderImageButton:self.cameraCloseButton largeButton:NO];
            self.cameraCloseButton.hidden = NO;
        } else if (callStatus != RCCallHangup) {
            self.cameraCloseButton.hidden = YES;
        }
    } else {
        //最大的一层了，语音通话， type == SUBTYPE_CALL_AUDIO
               if (callStatus == RCCallActive) {
                   self.timeLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                                                        CGRectGetMaxY(self.remoteNameLabel.frame) + 10, self.view.frame.size.width - RCCallHorizontalMargin * 2 , RCCallLabelHeight);
                   self.timeLabel.hidden = NO;
               } else if (callStatus != RCCallHangup) {
                   self.timeLabel.hidden = YES;
               }

               if (callStatus == RCCallActive) {
                   self.tipsLabel.frame =
                       CGRectMake(RCCallHorizontalMargin,
                                  self.view.frame.size.height - RCCallButtonBottomMargin * 3 - RCCallButtonLength - RCCallExtraSpace  - 20,
                                  self.view.frame.size.width - RCCallHorizontalMargin * 2, RCCallLabelHeight);
               } else if (callStatus == RCCallDialing) {
                   self.tipsLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                                      CGRectGetMaxY(self.remoteNameLabel.frame) + 10, self.view.frame.size.width - RCCallHorizontalMargin * 2 , RCCallLabelHeight);
                   
               } else if (callStatus == RCCallIncoming ) {
                   self.tipsLabel.frame = CGRectMake(RCCallHorizontalMargin,
                                                                 CGRectGetMaxY(self.remoteNameLabel.frame) + 10, self.view.frame.size.width - RCCallHorizontalMargin * 2 , RCCallLabelHeight);
               } else if (callStatus == RCCallHangup) {
                    self.tipsLabel.frame = CGRectMake(
                                RCCallHorizontalMargin,
                                self.view.frame.size.height - RCCallButtonBottomMargin * 3 - RCCallButtonLength - RCCallExtraSpace  - 20,
                                self.view.frame.size.width - RCCallHorizontalMargin * 2, RCCallLabelHeight);
               }
               self.tipsLabel.hidden = NO;
               
               if (callStatus == RCCallActive) {
                   self.muteButton.frame = CGRectMake(RCCallHorizontalMiddleMargin,
                                                      self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength - RCCallExtraSpace,
                                                      RCCallCustomButtonLength, RCCallCustomButtonLength);

                     [self layoutTextUnderImageButton:self.muteButton largeButton:NO];
                   self.muteButton.hidden = NO;
                   self.muteButton.enabled = YES;
               } else if (callStatus == RCCallDialing) {
                   self.muteButton.frame = CGRectMake(RCCallHorizontalMiddleMargin,
                                                      self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength - RCCallExtraSpace,
                                                      RCCallCustomButtonLength, RCCallCustomButtonLength);
                   [self layoutTextUnderImageButton:self.muteButton largeButton:NO];
                   self.muteButton.hidden = NO;
                   self.muteButton.enabled = NO;
               } else if (callStatus != RCCallHangup) {
                   self.muteButton.hidden = YES;
               }

               if (callStatus == RCCallActive){
                   self.speakerButton.frame =
                   CGRectMake(self.view.frame.size.width - RCCallHorizontalMiddleMargin - RCCallCustomButtonLength,
                              self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength - RCCallExtraSpace, RCCallCustomButtonLength,
                              RCCallCustomButtonLength);
                   [self layoutTextUnderImageButton:self.speakerButton largeButton:NO];
                   self.speakerButton.hidden = NO;
//                   [self.speakerButton setSelected:self.callSession.speakerEnabled];
                   if ([self isHeadsetPluggedIn])
                       [self reloadSpeakerRoute:NO];
               } else if (callStatus == RCCallDialing) {
                   self.speakerButton.frame =
                       CGRectMake(self.view.frame.size.width - RCCallHorizontalMiddleMargin - RCCallCustomButtonLength,
                                  self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2) - RCCallCustomButtonLength - RCCallExtraSpace, RCCallCustomButtonLength,
                                  RCCallCustomButtonLength);
                   [self layoutTextUnderImageButton:self.speakerButton largeButton:NO];
                   self.speakerButton.hidden = NO;
                   if ([self isHeadsetPluggedIn])
                   [self reloadSpeakerRoute:NO];
               } else if (callStatus != RCCallHangup) {
                   self.speakerButton.hidden = YES;
               }

               if (callStatus == RCCallDialing) {
                   self.hangupButton.frame =
                       CGRectMake((self.view.frame.size.width - RCCallButtonLength) / 2,
                                  self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace, RCCallButtonLength,
                                  RCCallButtonLength);
                  [self layoutTextUnderImageButton:self.hangupButton largeButton:YES];
                   self.hangupButton.hidden = NO;

                   self.acceptButton.hidden = YES;
               } else if (callStatus == RCCallIncoming) {
                   self.hangupButton.frame = CGRectMake(
                       RCCallHorizontalBigMargin, self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace,
                       RCCallButtonLength, RCCallButtonLength);
                   [self layoutTextUnderImageButton:self.hangupButton largeButton:NO];
                   self.hangupButton.hidden = NO;

                   self.acceptButton.frame =
                       CGRectMake(self.view.frame.size.width - RCCallHorizontalBigMargin - RCCallButtonLength,
                                  self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace, RCCallButtonLength,
                                  RCCallButtonLength);
                   [self layoutTextUnderImageButton:self.acceptButton largeButton:NO];
                   self.acceptButton.hidden = NO;
               } else if (callStatus == RCCallActive) {
                   self.hangupButton.frame =
                       CGRectMake((self.view.frame.size.width - RCCallButtonLength) / 2,
                                  self.view.frame.size.height - (RCCallButtonBottomMargin * 2 - RCCallInsideMargin * 2 + RCCallCustomButtonLength / 2 + 1.25f) - RCCallButtonLength/2 - RCCallExtraSpace, RCCallButtonLength,
                                  RCCallButtonLength);
                   [self layoutTextUnderImageButton:self.hangupButton largeButton:YES];
                   self.hangupButton.hidden = NO;

                   self.acceptButton.hidden = YES;
               }

               self.cameraCloseButton.hidden = YES;
               self.cameraSwitchButton.hidden = YES;

    }
}

- (void)resetLayoutSingle:(CallManager *)callManager
{

    int RCCallExtraSpace = 0;
    int RCCallStatusBarHeight = 0;
    if (@available(iOS 11.0, *)) {
        RCCallExtraSpace = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        RCCallStatusBarHeight = 30;
    }
    
        if (callManager.mediaType == SUBTYPE_CALL_AUDIO) {
            [self.acceptButton setImage:[UIImage imageNamed:@"answer.png"]
                               forState:UIControlStateNormal];
            [self.acceptButton setImage:[UIImage imageNamed:@"answer_hover.png"]
                               forState:UIControlStateHighlighted];

                            self.remotePortraitView.frame =
                                CGRectMake((self.view.frame.size.width - RCCallHeaderLength) / 2, RCCallTopGGradientHeight + kTopNavHeight, RCCallHeaderLength, RCCallHeaderLength);
            //                self.remotePortraitView.image = remoteHeaderImage;
                            self.remotePortraitView.hidden = NO;
                            
                            [self.remoteNameLabel setText:callManager.other_name];
                            self.remoteNameLabel.frame =
                                CGRectMake(RCCallHorizontalMargin, CGRectGetMaxY(self.remotePortraitView.frame) + 14,
                                           self.view.frame.size.width - RCCallHorizontalMargin * 2, RCCallMiniLabelHeight);
                            self.remoteNameLabel.hidden = NO;
                            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
     

            if (callManager.callStatus == RCCallDialing) {
//                self.remotePortraitView.alpha = 0.5;
            } else if (callManager.callStatus == RCCallIncoming) {
//                self.remotePortraitView.alpha = 0.5;
//                self.remotePortraitView.image = remoteHeaderImage;

                
            } else if (callManager.callStatus == RCCallActive) {
//                self.remotePortraitView.alpha = 0.5;
               
//                self.remotePortraitView.image = remoteHeaderImage;
           

            }else {
//                self.remotePortraitView.alpha = 1.0;
//                self.remotePortraitView.image = remoteHeaderImage;
             
            }

            self.mainVideoView.hidden = YES;
            self.subVideoView.hidden = YES;
//            [self resetRemoteUserInfoIfNeed];
        } else {
            //视频通话，SUBTYPE_CALL_VIDEO
            [self.acceptButton setImage:[UIImage imageNamed:@"answervideo.png"]
                               forState:UIControlStateNormal];
            [self.acceptButton setImage:[UIImage imageNamed:@"answervideo_hover.png"]
                               forState:UIControlStateHighlighted];
            
            if (callManager.callStatus == RCCallDialing) {
//                self.mainVideoView.hidden = NO;
    //            self.mainVideoView.frame = CGRectMake(0, RCCallStatusBarHeight, self.view.frame.size.width, self.view.frame.size.height - RCCallExtraSpace - RCCallStatusBarHeight);
              

            } else if (callManager.callStatus == RCCallActive) {
//                self.mainVideoView.hidden = NO;
            } else {
//                self.mainVideoView.hidden = YES;
            }

            if (callManager.callStatus == RCCallActive) {
                self.remotePortraitView.hidden = YES;
                    self.remoteNameLabel.hidden = YES;
//                self.remoteNameLabel.frame =
//                CGRectMake(RCCallHorizontalMargin, RCCallMiniButtonTopMargin + RCCallStatusBarHeight,
//                               self.view.frame.size.width - RCCallHorizontalMargin * 2, RCCallMiniLabelHeight);
//                self.remoteNameLabel.hidden = NO;
//                self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
//
//                [self.remoteNameLabel setText:callManager.other_name];
            } else if (callManager.callStatus == RCCallIncoming
                       || callManager.callStatus == RCCallDialing) {
                self.remotePortraitView.frame =
                    CGRectMake((self.view.frame.size.width - RCCallHeaderLength) / 2, RCCallTopGGradientHeight + kTopNavHeight, RCCallHeaderLength, RCCallHeaderLength);
//                self.remotePortraitView.image = remoteHeaderImage;
                self.remotePortraitView.hidden = NO;
                
                [self.remoteNameLabel setText:callManager.other_name];
                self.remoteNameLabel.frame =
                    CGRectMake(RCCallHorizontalMargin, CGRectGetMaxY(self.remotePortraitView.frame) + 14,
                               self.view.frame.size.width - RCCallHorizontalMargin * 2, RCCallMiniLabelHeight);
                self.remoteNameLabel.hidden = NO;
                self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
            } else {
            }

            if (callManager.callStatus == RCCallActive) {
//                if ([RCCallKitUtility isLandscape] && [self isSupportOrientation:(UIInterfaceOrientation)[UIDevice currentDevice].orientation]) {
//                    self.subVideoView.frame =
//                        CGRectMake(self.view.frame.size.width - RCCallHeaderLength - RCCallHorizontalMargin / 2,
//                                   RCCallVerticalMargin, RCCallHeaderLength * 1.5, RCCallHeaderLength);
//                } else {
//                    self.subVideoView.frame =
//                        CGRectMake(self.view.frame.size.width - RCCallHeaderLength - RCCallHorizontalMargin / 2,
//                                   RCCallVerticalMargin, RCCallHeaderLength, RCCallHeaderLength * 1.5);
//                }
                self.subVideoView.hidden = NO;
            }

            self.remoteNameLabel.textAlignment = NSTextAlignmentCenter;
    
            if (callManager.callStatus == RCCallDialing) {
       
            } else if ( callManager.callStatus == RCCallDialing || callManager.callStatus == RCCallIncoming) {
//                self.remotePortraitView.alpha = 0.5;

            } else {
   
//                self.remotePortraitView.alpha = 1.0;
            }
        }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)hangupButtonClicked:(UIButton *)sender {

}

//免提
- (IBAction)speakerButtonClicked:(UIButton *)sender {

}


//点击接听按钮
- (IBAction)acceptButtonClicked:(UIButton *)sender {

}

- (IBAction)didClickMuteButton:(UIButton *)sender {

}

- (IBAction)didClickVideoMuteButton:(UIButton *)sender {

}

- (void) hideVideoMuted {
    self.remoteVideoMutedIndicator.hidden = true;
    self.localVideoMutedBg.hidden = true;
    self.localVideoMutedIndicator.hidden = true;
}

- (IBAction)didClickSwitchCameraButton:(UIButton *)sender {

}

- (void)setSpeakerEnable:(BOOL)enable
{
//    [callManager setSpeakerEnabled:enable];
    [self.speakerButton setSelected:enable];
}


    - (BOOL)isHeadsetPluggedIn
    {
        AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
        for (AVAudioSessionPortDescription* desc in [route outputs])
        {
            NSString *outputer = desc.portType;
            if ([outputer isEqualToString:AVAudioSessionPortHeadphones] || [outputer isEqualToString:AVAudioSessionPortBluetoothLE] || [outputer isEqualToString:AVAudioSessionPortBluetoothHFP] || [outputer isEqualToString:AVAudioSessionPortBluetoothA2DP])
                return YES;
        }
        return NO;
    }


    - (void)reloadSpeakerRoute:(BOOL)enable
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.speakerButton.enabled = enable;
        });
    }


- (void)layoutTextUnderImageButton:(UIButton *)button largeButton:(BOOL)largeButton {
    [button.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:13]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    button.titleEdgeInsets = UIEdgeInsetsMake(0, -button.imageView.frame.size.width,
                                              -button.imageView.frame.size.height - (largeButton?RCCallInsideMiniMargin:RCCallInsideMargin), 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-button.titleLabel.intrinsicContentSize.height - (largeButton?RCCallInsideMiniMargin:RCCallInsideMargin), 0, 0,
                                              -button.titleLabel.intrinsicContentSize.width);
}


- (void)handleAudioRouteChange:(NSNotification*)notification
{
    NSInteger reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    AVAudioSessionRouteDescription *route = [AVAudioSession sharedInstance].currentRoute;
    AVAudioSessionPortDescription *port = route.outputs.firstObject;
    switch (reason)
    {
        case AVAudioSessionRouteChangeReasonUnknown:
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable : //1
            [self reloadSpeakerRoute:NO];
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable : //2
            [self reloadSpeakerRoute:YES];
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange : //3
            break;
        case AVAudioSessionRouteChangeReasonOverride : //4
        {
            if ([port.portType isEqualToString:AVAudioSessionPortBuiltInReceiver] || [port.portType isEqualToString: AVAudioSessionPortBuiltInSpeaker]){
                [self reloadSpeakerRoute:YES];
            }
            else{
                [self reloadSpeakerRoute:NO];
            }
        }
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep : //6
            break;
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory : //7
            break;
        case AVAudioSessionRouteChangeReasonRouteConfigurationChange : //8
            break;
        default:
            break;
    }
}



@end
