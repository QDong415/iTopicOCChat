//
//  InfoModel.h
//  XLPagerTabStrip
//
//  Created by DongJin on 15-6-1.
//  Copyright (c) 2015年 Xmartlabs. All rights reserved.
//


#define INPROGRESS 0//client定义的。发送中
#define SUCCESS 1//client定义的。发送成功
#define FAIL 2//client定义的。发送失败

#define TYPE_CHAT_SINGLE 1//单聊
#define TYPE_CHAT_GROUP 2//群聊
#define TYPE_CHAT_TIPS 3//聊天时候的tips

#define SUBTYPE_TEXT 1//文本消息
#define SUBTYPE_IMAGE 2//图片消息
#define SUBTYPE_VOICE 3//语音条消息
#define SUBTYPE_GIFT 4//礼物消息

#define SUBTYPE_CALL_AUDIO 10//电话消息
#define SUBTYPE_CALL_VIDEO 11//视频消息

/**
 * 每一条字段后面的注释表明它的数据来源 ：
 *
 * sqlite表示该变量来自手机本地sqlite数据库，服务器上无此字段，比如 是否已读，是否发送成功
 * service表示该变量来自服务器接口返回
 * service+sqlite 表示服务器也会返回，手机端也会去存
 * temp表示不入库也不是网络请求，只是Activity为了临时处理
 */
@protocol ChatModel
@end

@interface ChatModel : JSONModel
{
}

@property(assign,nonatomic) int dbid;//手机端本地数据库主键（sqlite）
@property(assign,nonatomic) int msgid;//服务器返回的主键id（service + sqlite）

//如果是群聊（type==2），这里是发布人id; 如果是单聊，这里是对方id
//如果是服务器返回的ChatBean，这里是发布人id，也就是对方id；
//如果是本地发消息时候创建的单聊ChatBean，就用代码设为对方id； 如果是本地发消息时候创建的群聊ChatBean，就用代码设为自己
@property(strong,nonatomic) NSString<Optional> *other_userid;//（service + sqlite）
@property(strong,nonatomic) NSString<Optional> *other_name;//（service + sqlite）
@property(strong,nonatomic) NSString<Optional> *other_photo;//（service + sqlite）

//如果是群聊（type==2），这里是群id；如果是单聊，这里是对方的userid（同other_userid）
@property(strong,nonatomic) NSString<Optional> *targetid; //（service + sqlite）

@property(strong,nonatomic) NSString<Optional> *content;//消息文本内容 //（service + sqlite）
@property(assign,nonatomic) int create_time;//1491545686 //（service + sqlite）
@property(assign,nonatomic) int type;//1为单聊 2为群聊 3为聊天时候的tips 4系统通知 //（service + sqlite）
@property(assign,nonatomic) int subtype;//1为文本 2为图片 3为语音 //（service + sqlite）
@property(assign,nonatomic) int issender;//当前登录账号是这个消息的发送者，1==我发送的  //（sqlite）
@property(assign,nonatomic) int hadread;//0默认，未读 //（sqlite）

//extend = 服务器返回的json，如果subtype是1图片，那么extend是{"height":2340,"width":1080}
//如果subtype是2语音条，那么extend是{"duration":"6"}
@property(strong,nonatomic) NSString<Optional> *extend;//json，拓展项 //（service + sqlite）

//filename = 附件本地沙盒文件名，同时也是七牛文件名
//如果subtype是1图片，或者2语音条，那么就是文件名
//如果subtype是11或者10电话消息，那么就是1611:800018:1586864352 （发送人id:接受人id:时间戳）
@property (nonatomic, strong) NSString *filename;  //（service + sqlite）

#pragma mark - 图片
@property (assign,nonatomic) CGSize thumbnailImageSize;//客户端自己定义的，从extend解析出来的图片宽 //（temp)
@property (nonatomic) NSInteger fileUploadProgress;//附件上传进度，范围为0--100 //（temp)
@property (nonatomic) NSInteger fileDownloadProgress;//附件下载进度，范围为0--100 //（temp)

#pragma mark - 音频、视频
@property (nonatomic) BOOL isMediaPlaying;//client定义的。 //（temp)
@property (nonatomic) BOOL isMediaPlayed;//client定义的。 //（temp)
@property (nonatomic) BOOL needAnimateVoiceCell;//client定义的。 //（temp)
//单位为秒
@property (nonatomic) CGFloat mediaDuration;//client定义的。从extend里解析出来的 //（temp)


@property(assign,nonatomic) int state;//client定义的。发送状态 //（sqlite)
@property(assign,nonatomic) int hisTotalUnReadedChatCount;//client定义的。与这个人的所有的未读消息数量 //（sqlite)
@property(strong,nonatomic) NSString *timeLag;//client定义的。直接显示的时间 //（temp)
@property(strong,nonatomic) NSString *client_messageid;//client定义的。messageid //（service + sqlite）
@property(assign,nonatomic) BOOL needShowTimeTips;//client定义的。是否要显示时间tips //（temp)

//展示消息的CellHeight，计算一次，然后缓存
@property(assign,nonatomic) float cellHeight;//ios client定义的 //（temp)

@property(strong,nonatomic) NSMutableAttributedString *attributedText;//ios client定义的 //（temp)

- (void)processModelForCell; //为cell显示做数据上的准备
- (UIImage *)findThumbnailImage;

@end
