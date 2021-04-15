//
//  JsonParser.h
//  tabbarDemo
//
//  Created by DongJin on 14-12-13.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AvatarModel.h"
#import "UserModel.h"

@interface JsonParser : NSObject
{
}
+ (id)parseCommonResponseClass:(Class)cls object:(id)responseObject;
+ (UserModel *)parseUserModel:(NSString *)resultdata;

+ (AvatarModel *)parseAvatarModel:(id)resultdata;




@end
