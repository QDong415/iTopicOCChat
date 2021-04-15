//
//  HomeManager.h
//  pinpin
//
//  Created by DongJin on 15-3-21.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuSDK.h"
#define QINIUMANAGER [QiniuUploadManager sharedQiniuUploadManager]
@interface QiniuUploadManager : NSObject
{
}
+ (id)sharedQiniuUploadManager;

//获取上传token
- (void)getTokenApi:(NSString *)api parameters:(NSDictionary *)dictionary withSuccessBlock:(commonSuccess)emptyBlock andFailBlock:(commonFail)errorBlock;

- (QNUploadManager *)createUpManager;

@end
