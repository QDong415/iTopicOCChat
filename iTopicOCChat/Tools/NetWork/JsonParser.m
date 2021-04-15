//
//  JsonParser.m
//  tabbarDemo
//
//  Created by DongJin on 14-12-13.
//  Copyright (c) 2014年 TabBarDemo. All rights reserved.
//

#import "JsonParser.h"
#import "BaseResponse.h"
@implementation JsonParser

+ (UserModel *)parseUserModel:(NSString *)resultdata
{
    UserModel *response ;
    @try{
        response = [[UserModel alloc] initWithString:resultdata error:nil];
    }@catch (NSException *exception) {
        NSLog(@"jsonparser exception %@",exception.description);
    }
    return response;
}

+ (AvatarModel *)parseAvatarModel:(id)resultdata
{
    if ([resultdata isKindOfClass:[NSString class]]) {
        return [JsonParser parseAvatarModelByString:resultdata];
    } else if([resultdata isKindOfClass:[NSDictionary class]]){
        return [JsonParser parseAvatarModelByDictionary:resultdata];
    } else {
        AvatarModel *response ;
        @try{
            response = [[AvatarModel alloc] initWithData:resultdata error:nil];
        }@catch (NSException *exception) {
            NSLog(@"jsonparser exception %@",exception.description);
        }
        if (!response) {
            response = [[AvatarModel alloc]init];
        }
        return response;
    }
    
}
+ (AvatarModel *)parseAvatarModelByDictionary:(NSDictionary *)resultdata
{
    AvatarModel *response ;
    @try{
        response = [[AvatarModel alloc] initWithDictionary:resultdata error:nil];
    }@catch (NSException *exception) {
        NSLog(@"jsonparser exception %@",exception.description);
    }
    if (!response) {
        response = [[AvatarModel alloc]init];
    }
    return response;
}

+ (AvatarModel *)parseAvatarModelByString:(NSString *)resultdata
{
    AvatarModel *response ;
    @try{
        response = [[AvatarModel alloc] initWithString:resultdata error:nil];
    }@catch (NSException *exception) {
        NSLog(@"jsonparser exception %@",exception.description);
    }
    if (!response) {
        response = [[AvatarModel alloc]init];
    }
    return response;
}

+ (id)parseCommonResponseClass:(Class)cls object:(id)responseObject
{
    id responseModel;
    @try{
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            responseModel = [[cls alloc] initWithDictionary:responseObject error:nil];
        } else if ([responseObject isKindOfClass:[NSData class]]) {
            responseModel = [[cls alloc] initWithData:responseObject error:nil];
        } else if ([responseObject isKindOfClass:[NSString class]]) {
            responseModel = [[cls alloc] initWithString:responseObject error:nil];
        }
    }@catch (NSException *exception) {
        NSLog(@"jsonparser exception %@",exception.description);
    }
    if (!responseModel) {
        responseModel = [[cls alloc] initWithError];
    }
    return responseModel;
}

@end
