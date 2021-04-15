//
//  AFUser.m
//  iPhone
//
//  Created by QDong Email: 285275534@qq.com on 13-3-26.
//  Copyright (c) 2013年 ibluecollar. All rights reserved.
//

#define USER_STORE_KEY @"current-user"

#import "UserManager.h"
#import "JsonParser.h"
#import "ValueUtil.h"
#import "UserResponse.h"
#import "BaseResponse.h"

#import <GTSDK/GeTuiSdk.h>

@interface UserManager ()
{
}
@end

@implementation UserManager

-(void)setUserModel:(UserModel *)userModel
{
    //之前是否已经登录
    BOOL isLogin = _userModel && _userModel.userid;
    
    //重新赋值新的Model
    _userModel = userModel;
    
    //保存起来
    [[NSUserDefaults standardUserDefaults]setObject:[_userModel toJSONString] forKey:USER_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:isLogin?NOTIFICATION_USER_CHANGE:NOTIFICATION_USER_LOGIN_CHANGE object:_userModel];
}

- (void)storeUserModel
{
    [[NSUserDefaults standardUserDefaults]setObject:[_userModel toJSONString] forKey:USER_STORE_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isLogin
{
    return _userModel && _userModel.userid;
}


- (void)clean
{
    if(_userModel){
        _userModel = nil;
        //刷新全局变量：当前用户付款过的红包动态
//        [HOMEMANAGER resetPaidTopicPhotoArray];
        
        [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:USER_STORE_KEY];
        [[NSUserDefaults standardUserDefaults]synchronize];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER_LOGIN_CHANGE object:_userModel];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

//访问login或者reg网络成功
- (void)loginRequiteSuccess:(UserModel *)userModel
{
    //保存用户json到NSUserDefaults，和全局变量
    [self setUserModel:userModel];
    //检查cid
    [self checkCidAndUpdate:^(id anything){
        //告诉php服务器我刚才注册成功了，php服务器收到这个接口后，会推送小秘书默认消息
        [NETWORK postDataByApi:@"account/doregaction" parameters:[NSDictionary dictionary] responseClass:nil success:nil failure:nil];
    }];
    //刷新全局变量：当前用户付款过的红包动态
//    [HOMEMANAGER resetPaidTopicPhotoArray];
}

//检查Cid是否跟本地缓存的一致
- (void)checkCidAndUpdate:(commonSuccess)emptyBlock
{
    NSString *cid = [GeTuiSdk clientId];
    if(cid && _userModel && ![cid isEqualToString:_userModel.cid]){
        //有新的cid。通知服务器
        [USERMANAGER editInfoStart:cid withEventKey:@"cid" withSuccessBlock:emptyBlock andFailBlock:^(int code,NSString *message){}];
    }
}

#pragma mark - common
- (id)init{
    self=[super init];
    if (self) {
        _userModel = [JsonParser parseUserModel:[[NSUserDefaults standardUserDefaults]objectForKey:USER_STORE_KEY]];
    }
    return self;
}

// 登录了就返回userid，未登录就返回@“”
- (NSString *)getUserId
{
    return _userModel?_userModel.userid:@"";
}

+ (id)sharedUserManager{
    static UserManager *_sharedUserManager=nil;
    static dispatch_once_t predUser;
    dispatch_once(&predUser, ^{
        _sharedUserManager=[[UserManager alloc] init];
    });
    return _sharedUserManager;
}

//修改某项资料
- (void)editInfoStart:(NSString*)content withEventKey:(NSString*)eventKey withSuccessBlock:(commonSuccess)emptyBlock andFailBlock:(commonFail)errorBlock
{
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:content,@"value",eventKey,@"event", nil];
    
    [NETWORK postDataByApi:@"account/modify" parameters:params responseClass:[UserResponse class] success:^(NSURLSessionTask *task, id responseObject){
        UserResponse *tempResponse = (UserResponse *)responseObject;
        if (tempResponse.isSuccess) {
            UserModel *tempModel =  tempResponse.data;
            
            [_userModel setAge:tempModel.age];
            [_userModel setAvatar:tempModel.avatar];
            [_userModel setGender:tempModel.gender];
            [_userModel setIntro:tempModel.intro];
            [_userModel setTags:tempModel.tags];
            [_userModel setName:tempModel.name];
            [_userModel setCover:tempModel.cover];
            [_userModel setCid:tempModel.cid];
            [self setUserModel:_userModel];
            
            if (emptyBlock) {
                emptyBlock(nil);
            }
        } else if (errorBlock) {
            errorBlock(0,tempResponse.message);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (errorBlock) {
            errorBlock(-1,@"网络访问失败");
        }
    }];
}

- (void)editInfo:(NSDictionary *)params success:(commonSuccess)successBlock failure:(commonFail)failBlock
{
    [NETWORK postDataByApi:@"account/modifyarray" parameters:params responseClass:[UserResponse class] success:^(NSURLSessionTask *task, id responseObject){
        
        UserResponse *tempResponse = (UserResponse *)responseObject;
        if (tempResponse.isSuccess) {
            UserModel *tempModel =  tempResponse.data;
            
            [_userModel setAge:tempModel.age];
            [_userModel setAvatar:tempModel.avatar];
            [_userModel setGender:tempModel.gender];
            [_userModel setIntro:tempModel.intro];
            [_userModel setTags:tempModel.tags];
            [_userModel setName:tempModel.name];
            [_userModel setCover:tempModel.cover];
            [_userModel setCid:tempModel.cid];
            [_userModel setCityid:tempModel.cityid];
            [_userModel setCityname:tempModel.cityname];
            [_userModel setSlience:tempModel.slience];
            [self setUserModel:_userModel];
            
            if (successBlock) successBlock(nil);
        } else if (failBlock) {
            failBlock(0,tempResponse.message);
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (failBlock) failBlock(0,@"网络访问失败");
    }];
}

- (void)refreshMyProfile
{
    if ([self isLogin]) {
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_userModel.userid?:@"",@"to_userid", nil];
        [NETWORK getDataByApi:@"user/profile" parameters:params responseClass:[UserResponse class] success:^(NSURLSessionTask *task, id responseObject){
                UserResponse *tempResponse = (UserResponse *)responseObject;
                if (tempResponse.isSuccess) {
                    UserModel *tempModel = tempResponse.data;
                    
                    [_userModel setAge:tempModel.age];
                    [_userModel setAvatar:tempModel.avatar];
                    [_userModel setGender:tempModel.gender];
                    [_userModel setIntro:tempModel.intro];
                    [_userModel setTags:tempModel.tags];
                    [_userModel setName:tempModel.name];
                    [_userModel setCover:tempModel.cover];
                    [_userModel setCityid:tempModel.cityid];
                    [_userModel setCityname:tempModel.cityname];
                    
                    [self storeUserModel];
                }
                
            } failure:^(NSURLSessionTask *operation, NSError *error) {
            }];
    }
}


//告诉服务器 我刚才完成了某项任务（目前只有 1=每日签到 2=每日分享 101=更新头像 ）
//3=赞一个 102=关注十人 这两个由服务器在对应的接口里检查判断，不单独走这里的代码
- (void)missionCompleteWithId:(NSString*)missionId withSuccessBlock:(commonSuccess)emptyBlock andFailBlock:(commonFail)errorBlock
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:missionId,@"missionid", nil];
    
    [NETWORK postDataByApi:@"mission/action" parameters:dictionary responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
        BaseResponse *tempResponse = (BaseResponse *)responseObject;
        if (tempResponse.isSuccess) {
            if (emptyBlock) {
                emptyBlock(nil);
            }
        } else if (errorBlock) {
            errorBlock(0,tempResponse.message);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (errorBlock) {
            errorBlock(-1,@"网络访问失败");
        }
    }];
}

@end
