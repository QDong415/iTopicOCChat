//
//  QiniuUploadManager.m
//  pinpin
//
//  Created by DongJin on 15-3-21.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "QiniuUploadManager.h"
#import "DictionaryResponse.h"
#import "ValueUtil.h"

@implementation QiniuUploadManager

+ (id)sharedQiniuUploadManager{
    static QiniuUploadManager *_sharedQiniuUploadManager=nil;
    static dispatch_once_t predUser;
    dispatch_once(&predUser, ^{
        _sharedQiniuUploadManager=[[QiniuUploadManager alloc] init];
    });
    return _sharedQiniuUploadManager;
}

//获取上传token //
- (void)getTokenApi:(NSString *)api parameters:(NSDictionary *)dictionary withSuccessBlock:(commonSuccess)emptyBlock andFailBlock:(commonFail)errorBlock
{
    BOOL photoQiniuToken = [api isEqualToString:@"qiniu/uploadtoken"];
    if (photoQiniuToken) {
        //说明是上传图片的七牛token，可以用缓存；否则是视频的七牛token，视频的不用缓存
        int expires = (int)[[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@_expires",api]];
        if (expires > [[NSDate date] timeIntervalSince1970] + 600) {
            NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@_token",api]];
            if (![ValueUtil isEmptyString:token] && emptyBlock) {
                emptyBlock(token);
                return;
            }
        }
    }

    //有效期还有10分钟就要结束，重新获取
    [NETWORK getDataByApi:api parameters:dictionary responseClass:[DictionaryResponse class] success:^(NSURLSessionTask *task, id responseObject){
        
        DictionaryResponse *dictionaryResponse = (DictionaryResponse *)responseObject;
        if ([dictionaryResponse isSuccess]) {
            
            if (photoQiniuToken) {
                [[NSUserDefaults standardUserDefaults]setObject:dictionaryResponse.data[@"token"] forKey:[NSString stringWithFormat:@"%@_token",api]];
                [[NSUserDefaults standardUserDefaults]setInteger:[dictionaryResponse.data[@"expires"] intValue] forKey:[NSString stringWithFormat:@"%@_expires",api]];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            
            if (emptyBlock) {
                emptyBlock(dictionaryResponse.data[@"token"]);
            }
        } else if (errorBlock) {
            errorBlock(0,dictionaryResponse.message);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (errorBlock) {
            errorBlock(0,@"网络访问失败");
        }
    }];
}

- (QNUploadManager *)createUpManager
{
    QNConfiguration *config = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.zone = [QNFixedZone zone1];
    }];
    
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:config];
    
    return upManager;
}


@end
