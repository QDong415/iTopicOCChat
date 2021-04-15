//
//  UMPNSReturnCode.h
//  UMVerify
//
//  Copyright © 2019 umeng. All rights reserved.
//

#ifndef PNSReturnCode_h
#define PNSReturnCode_h

#import <Foundation/Foundation.h>


/// 接口成功
static NSString * const PNSCodeSuccess = @"600000";
/// 获取运营商配置信息失败
static NSString * const PNSCodeGetOperatorInfoFailed = @"600004";
/// 未检测到sim卡
static NSString * const PNSCodeNoSIMCard = @"600007";
/// 蜂窝网络未开启
static NSString * const PNSCodeNoCellularNetwork = @"600008";
/// 无法判运营商
static NSString * const PNSCodeUnknownOperator = @"600009";
/// 未知异常
static NSString * const PNSCodeUnknownError = @"600010";
/// 获取token失败
static NSString * const PNSCodeGetTokenFailed = @"600011";
/// 预取号失败
static NSString * const PNSCodeGetMaskPhoneFailed = @"600012";
/// 运营商维护升级，该功能不可用
static NSString * const PNSCodeInterfaceDemoted = @"600013";
/// 运营商维护升级，该功能已达最大调用次数
static NSString * const PNSCodeInterfaceLimited = @"600014";
/// 接口超时
static NSString * const PNSCodeInterfaceTimeout = @"600015";
/// AppID、Appkey解析失败
static NSString * const PNSCodeDecodeAppInfoFailed = @"600017";
/// 运营商已切换
static NSString * const PNSCodeCarrierChanged = @"600021";
/// 终端环境检测失败（终端不支持认证 / 终端检测参数错误）
static NSString * const PNSCodeEnvCheckFail = @"600025";

/*************** 号码认证授权页相关返回码 START ***************/

/// 唤起授权页成功
static NSString * const PNSCodeLoginControllerPresentSuccess = @"600001";
/// 唤起授权页失败
static NSString * const PNSCodeLoginControllerPresentFailed = @"600002";
/// 授权页已加载时不允许调用加速或预取号接口
static NSString * const PNSCodeCallPreLoginInAuthPage = @"600026";
/// 点击返回，⽤户取消一键登录
static NSString * const PNSCodeLoginControllerClickCancel = @"700000";
/// 点击切换按钮，⽤户取消免密登录
static NSString * const PNSCodeLoginControllerClickChangeBtn = @"700001";
/// 点击登录按钮事件
static NSString * const PNSCodeLoginControllerClickLoginBtn = @"700002";
/// 点击CheckBox事件
static NSString * const PNSCodeLoginControllerClickCheckBoxBtn = @"700003";
/// 点击协议富文本文字
static NSString * const PNSCodeLoginControllerClickProtocol = @"700004";

/*************** 号码认证授权页相关返回码 FINISH ***************/

#endif /* PNSReturnCode_h */
