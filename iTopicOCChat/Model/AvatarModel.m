//
//  AvatarModel.m
//
//  Created by DongJin on 15-2-11.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "AvatarModel.h"
#import "ValueUtil.h"

@implementation AvatarModel
-(NSString *)findOriginalUrl
{
    if (_filename) {
        //说明是新版本
        if ([_filename hasPrefix:@"http"]) {
            //服务器返回的直接就是地址，不需要手机端再拼接头部
            return _filename;
        }else{
            //服务器返回的文件名，需要手机端再拼接头部
            return [NSString stringWithFormat:@"%@%@",QINIU_URL,_filename];
        }
    }
    return nil;
}

-(NSString *)findSmallUrl
{
    if (_filename) {
         return [ValueUtil getQiniuUrlByFileName:_filename limit:120 max:YES];
    }
    return nil;
}

-(BOOL)isGif
{
    return _filename && [_filename hasSuffix:@".gif"];
}
-(BOOL)isEmpty
{
    return !_filename || _filename.length == 0;
}

@end
