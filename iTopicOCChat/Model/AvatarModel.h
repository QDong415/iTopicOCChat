//
//  AvatarModel.h
//
//  Created by DongJin on 15-2-11.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "JSONModel.h"
@protocol AvatarModel
@end
@interface AvatarModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *filename; //新版本图片返回的是json
@property (strong, nonatomic) NSNumber<Optional> *width;
@property (strong, nonatomic) NSNumber<Optional> *height;
-(NSString *)findOriginalUrl;
-(NSString *)findSmallUrl;
-(BOOL)isEmpty;
-(BOOL)isGif;
@end
