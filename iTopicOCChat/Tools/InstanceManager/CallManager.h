//
//  CallManager.h
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoChatViewController.h"
/*!
 通话状态
 */
typedef NS_ENUM(NSInteger, RCCallStatus) {
    /*!
     初始状态
     */
    RCCallHangup   = 0,
    /*!
     正在呼出
     */
    RCCallDialing = 1,
    /*!
     正在呼入
     */
    RCCallIncoming = 2,
    /*!
     正在通话
     */
    RCCallActive = 3,
};

@protocol CallManagerDelegate <NSObject>

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed;

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

//远端用户（通信场景）/主播（直播场景）离开当前频道回调
- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason;

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didVideoMuted:(BOOL)muted byUid:(NSUInteger)uid;

- (void)oppoRefuseMyDialing;

@end


@interface CallManager : NSObject
{
}

+ (id)sharedCallManager;

@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
@property (assign, nonatomic) id<CallManagerDelegate> delegate;

- (void)initializeAgoraEngine;
- (void)setupVideo;

- (void)oppoRefuseMyDialing;

- (void)presentCallViewController:(UIViewController *)viewController;
- (void)dismissCallViewController:(UIViewController *)viewController;

/*!
 通话ID
 */
@property(nonatomic, strong) NSString *channelId;

/*!
 通话的目标会话ID
 */
@property(nonatomic, strong) NSString *targetId;

/*!
 通话的目标会话ID
 */
@property(nonatomic, strong) NSString *other_name;
/*!
 通话的目标会话ID
 */
@property(nonatomic, strong) NSString *other_photo;

/*!
 通话的当前状态, 重要
 */
@property(nonatomic, assign) RCCallStatus callStatus;

@property(nonatomic, assign) int mediaType;

/*!
 通话开始的时间

 @discussion
 如果是用户呼出的通话，则startTime为通话呼出时间；如果是呼入的通话，则startTime为通话呼入时间。
 */
@property(nonatomic, assign) long long startTime;

/*!
 通话接通时间
 */
@property(nonatomic, assign) long long connectedTime;

@end
