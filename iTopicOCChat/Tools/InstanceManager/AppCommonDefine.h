//
//  AppCommonDefine.h
//  ShowSecret
//
//  Created by DQ Email:285275534@qq.com on 14-10-8.
//  Copyright (c) 2014年 ibluecollar. All rights reserved.
//
#import "AppDelegate.h"
#ifndef itopic_AppCommonDefine_h
#define itopic_AppCommonDefine_h

#define HTTP_URL @"http://47.104.91.32/"

#define HOST_URL @"http://itopic.buildbees.cn/"

#define QINIU_URL @"http://topicqn.yuanchuangyuan.com/" //七牛链接

#define WEAKSELF __weak typeof(self) weakSelf = self;
#define STRONGSELF if (!weakSelf) return; \
__strong typeof(weakSelf) strongSelf = weakSelf

#define SAFE_SEND_MESSAGE(obj, msg) if ((obj) && [(obj) respondsToSelector:@selector(msg)])

// 个推 itopic
#define kGtAppId           @"JjRS35nTSP9k7ZSBKt8DM6"
#define kGtAppKey          @"AQngfBxi8pATf95ENg2Kj9"
#define kGtAppSecret       @"G6gnMrlBs06cBY9lqyL5V"

#define        kBDMapAPIkey          @"mUHtKMz3bktXneXv0lnx81jg"    //百度地图

//http请求用的秘钥，若修改的话，需要三端统一
#define SIG_KEY @"iTopic2015"

//本app在 appstore里的appid
#define APPSTORE_ID @"1031910855"


#define MISSION_ENABLE NO //本app支持 积分和任务体系
#define MISSION_SIGN_ID @"1" // 每日签到 任务标示id
#define MISSION_SHARE_ID @"2" // 每日分享 任务标示id
#define MISSION_PRAISE_ID @"3" // 每日点赞 任务标示id
#define MISSION_AVATAR_ID @"101" // 上传头像 任务标示id
#define MISSION_FOLLOW_TEN_ID @"102" // 关注十人 任务标示id

#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define kStatusBarHeight UIApplication.sharedApplication.statusBarFrame.size.height  //非X是20 X是44
#define kTopNavHeight (int)(44 + kStatusBarHeight) //非X是64 X是98 ，44是导航栏的高度

//分享链接
#define SHARE_TOPIC_URL(topicId) [NSString stringWithFormat:@"%@home/topic/detail?tid=%@",HOST_URL,topicId]

//当前应用版本 版本比较用
#define APP_CURRENT_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define COLOR_BLACK_RGB RGBCOLOR(91,91,91)
#define COLOR_GRAY_DARK_RGB RGBCOLOR(104,104,104)
#define COLOR_GRAY_RGB RGBCOLOR(145,145,145)
#define COLOR_ORANGE_RGB RGBCOLOR(250,111,46)
#define COLOR_BLUE_RGB RGBCOLOR(58,155,252)
#define COLOR_RED_RGB RGBCOLOR(237,60,33)
#define COLOR_GREEN_RGB RGBCOLOR(44,195,177)
#define COLOR_WHITE_RGB RGBCOLOR(248,248,248)
#define COLOR_BACKGROUND_RGB RGBCOLOR(248,248,246)
#define COLOR_DIVIDER_RGB RGBCOLOR(220,220,220)
#define COLOR_NAME_RGB [UIColor colorWithRed:19/255.0f green:52/255.0f blue:101/255.0f alpha:1]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

//用户资料发生改变
#define        NOTIFICATION_USER_CHANGE     @"NOTIFICATION_USER_CHANGE"
//用户 登录 或者 退出
#define        NOTIFICATION_USER_LOGIN_CHANGE     @"NOTIFICATION_USER_LOGIN_CHANGE"
//定位结束 只有经纬度，还没address
#define        NOTIFICATION_LOCATION_FINISH  @"NOTIFICATION_LOCATION_FINISH"
//定位结束 最后一步
#define        NOTIFICATION_LOCATION_ADDRESS_FINISH  @"NOTIFICATION_LOCATION_ADDRESS_FINISH"

//关注他人结束
#define        NOTIFICATION_FOLLOW_FINISH  @"NOTIFICATION_FOLLOW_FINISH"
//红包支付成功
#define        NOTIFICATION_TOPIC_REDPACKET_PAID_SUCCESS  @"NOTIFICATION_TOPIC_REDPACKET_PAID_SUCCESS"
//发送聊天消息，成功或者失败
#define         NOTIFICATION_MESSAGE_SEND @"NOTIFICATION_MESSAGE_SEND"
//读了消息（可能是进入了聊天气泡界面，也可能点开了通知）
#define         NOTIFICATION_MESSAGE_READED @"NOTIFICATION_MESSAGE_READED"
//拉到新消息，object是新消息的types集合 array<NSNumber>
#define         NOTIFICATION_MESSAGES_RECEIVE @"NOTIFICATION_MESSAGES_RECEIVE"

//关注 粉丝
#define        INT_FOLLOWTYPE_NONE 0
#define        INT_FOLLOWTYPE_MY_FOLLOWING 1
#define        INT_FOLLOWTYPE_MY_FANS 2
#define        INT_FOLLOWTYPE_EACH 3

#define PUSH_TYPE_REMIND_COMMENT 4// 被评论提醒通知 不入库，只是推送时候作为type
#define PUSH_TYPE_REMIND_PRAISE 5// 被赞提醒通知 不入库，只是推送时候作为type
#define PUSH_TYPE_REMIND_FANS 6// 被粉丝提醒通知 不入库，只是推送时候作为type
#define PUSH_TYPE_REMIND_SYSYEM 7// 系统消息提醒通知 不入库，只是推送时候作为type
#define PUSH_TYPE_REMIND_AT 8// 被@提醒通知 不入库，只是推送时候作为type
#define PUSH_TYPE_CALL_REFUSE 10// 对方拒绝了我的通话申请(注意是未接通的通话申请)

//#ifdef __OPTIMIZE__
//#define NSLog(...) NSLog(__VA_ARGS__)
//#define debugMethod() NSLog(@"%s", __func__)
//#else
//#define NSLog(...)
//#define debugMethod()
//#endif

//常用的block
typedef void (^commonSuccess)(id object);
typedef void (^doBlock)();
typedef void (^commonFail)(int code,NSString *message);

#endif

