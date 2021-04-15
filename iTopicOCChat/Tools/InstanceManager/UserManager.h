//
//  AFUser.h
//  iPhone
//
//  Created by QDong Email: 285275534@qq.com on 13-3-26.
//  Copyright (c) 2013年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserModel.h"
#import "AppCommonDefine.h"

#define USERMANAGER [UserManager sharedUserManager]

@interface UserManager : NSObject
{

    
}

@property (nonatomic, strong) UserModel *userModel;

+ (id)sharedUserManager;
- (BOOL)isLogin;

// 登录了就返回userid，未登录就返回@“”
- (NSString *)getUserId;

//检查Cid是否跟本地缓存的一致
- (void)checkCidAndUpdate:(commonSuccess)emptyBlock;

//重新保存下_usermodel
- (void)storeUserModel;

//退出
- (void)clean;

//访问login或者reg接口成功
- (void)loginRequiteSuccess:(UserModel *)userModel;


//修改某项资料
- (void)editInfoStart:(NSString*)content withEventKey:(NSString*)eventKey withSuccessBlock:(commonSuccess)emptyBlock andFailBlock:(commonFail)errorBlock;

- (void)editInfo:(NSDictionary *)params success:(commonSuccess)successBlock failure:(commonFail)failBlock;

//告诉服务器 我刚才完成了某项任务（目前只有 1=每日签到 2=每日分享 101=更新头像 ）
//3=赞一个 102=关注十人 这两个由服务器在对应的接口里检查判断，不单独走这里的代码
- (void)missionCompleteWithId:(NSString*)missionId withSuccessBlock:(commonSuccess)emptyBlock andFailBlock:(commonFail)errorBlock;

- (void)refreshMyProfile;

@end
