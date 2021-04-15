//
//  Network.m

//  Created by QDong Email: 285275534@qq.com on 13-2-24.
//  Copyright (c) 2017年 iTopic. All rights reserved.
//

#import "Network.h"
#import "AFNetworking.h"
#import "BaseResponse.h"
#import "NSString+AFCommon.h"
#import "BasePhotoViewController.h"
#import "ValueUtil.h"


#define RESPONSE_CONTENT_TYPE [NSSet setWithObjects:@"text/json",@"text/javascript",@"application/json",@"text/plain",@"text/html",@"application/xhtml+xml",@"application/xml",nil]

#define USE_CHECK 1

@implementation Network

- (AFHTTPSessionManager *)newManager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = RESPONSE_CONTENT_TYPE;
    [manager.requestSerializer setValue:@"Keep-Alive" forHTTPHeaderField:@"Connection"];
    return manager;
}

- (NSMutableDictionary *)configParams:(NSDictionary*)orgdict
{
    //拼接上uid etag ts。但是没sign
    NSMutableDictionary *parametersMutableDictionary = orgdict.mutableCopy;
    //登录后调用的接口该参数为必选参数
    [parametersMutableDictionary setObject:[USERMANAGER getUserId] forKey:@"userid"];
    NSString *timeString = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    [parametersMutableDictionary setObject:timeString forKey:@"ts"];
    [parametersMutableDictionary setObject:@"ios" forKey:@"os"];
    [parametersMutableDictionary setObject:APP_CURRENT_VERSION forKey:@"clientver"];
    [parametersMutableDictionary setObject:[ValueUtil deviceId] forKey:@"deviceid"];
    [parametersMutableDictionary setObject:SIG_KEY forKey:@"sig"];
    //加入签名
    [parametersMutableDictionary setObject:[[self dictionaryToString:parametersMutableDictionary] md5String] forKey:@"sig"];
    return parametersMutableDictionary;
}

#pragma mark - 纯粹的调用AF访问网络，GET请求
- (void)GET:(NSString*)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock
{
    NSLog(@"GET = %@?%@",urlString,[self dictionaryToString:parameters]);
    
    AFHTTPSessionManager *manager = [self newManager];
    [manager GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        //AFNetwork提交进度
    }success:^(NSURLSessionTask *task, id responseObject) {
        //AFNetwork访问网络成功。只要是code == 200，就进入这里，无论数据是否正确
        requestSuccessBlock(task,responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        requestFailureBlock(operation,error);
    }];
}

#pragma mark - 纯粹的调用AF访问网络，POST请求
- (void)POST:(NSString*)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock
{
    NSLog(@"POST = %@",urlString);
    NSLog(@"params = %@",parameters);
    
    AFHTTPSessionManager *manager = [self newManager];
    [manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        //AFNetwork提交进度
    }success:^(NSURLSessionTask *task, id responseObject) {
        //AFNetwork访问网络成功。只要是code == 200，就进入这里，无论数据是否正确
        requestSuccessBlock(task,responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        requestFailureBlock(operation,error);
    }];
}

#pragma mark - 2017-02-05  封装好的 GET请求 + jsonmodel解析，直接回调model
/**
 * api 接口，比如@"topic/getlist"
 * parameters 参数，无需拼接userid
 * responseClass 返回后需要解析成的Model类型
 */
- (void)getDataByApi:(NSString *)api parameters:(NSDictionary *)parameters responseClass:(Class)cls success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock
{
    NSMutableDictionary *parametersMutableDictionary = [self configParams:parameters];
    
    [self GET:BASEURL(api) parameters:parametersMutableDictionary success:^(NSURLSessionTask *task, id responseObject) {
        //AFNetwork返回成功，3.0的AF，默认返回的responseObject是字典
        if (requestSuccessBlock) {
            //requestSuccessBlock 是我们自己定义的
            //在这里用jsonmodel把af返回的字典(responseObject)解析成model
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
            
            requestSuccessBlock(task,responseModel);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (requestFailureBlock) {
            requestFailureBlock(operation,error);
        }
    }];
}

#pragma mark - 2017-02-05  封装好的 POST请求 + jsonmodel解析，直接回调model
/**
 * api 接口，比如@"topic/getlist"
 * parameters 参数，无需拼接userid
 * responseClass 返回后需要解析成的Model类型
 */
- (void)postDataByApi:(NSString *)api parameters:(NSDictionary*)parameters responseClass:(Class)cls success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock
{
    NSMutableDictionary *parametersMutableDictionary = [self configParams:parameters];
    
    [self POST:BASEURL(api) parameters:parametersMutableDictionary success:^(NSURLSessionTask *task, id responseObject) {
        //AFNetwork返回成功，3.0的AF，默认返回的responseObject是字典
        if (requestSuccessBlock) {
            //requestSuccessBlock 是我们自己定义的
            //在这里用jsonmodel把af返回的字典(responseObject)解析成model
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

            requestSuccessBlock(task,responseModel);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        if (requestFailureBlock) {
            requestFailureBlock(operation,error);
        }
    }];
}

#pragma mark - 参数转换
//对dic进行排序并拼接成string
- (NSString*)dictionaryToString:(NSDictionary*)dict
{
    NSArray* keyArray = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        return result == NSOrderedDescending;
    }];
    NSMutableString* signString = [NSMutableString new];
    for (int i=0;i<keyArray.count;i++) {
        NSString* key = keyArray[i];
        if (i != 0) {
            [signString appendString:@"&"];
        }
        [signString appendFormat:@"%@=%@",key,(dict[key]?dict[key]:@"")];
    }
    return signString;
}


#pragma mark - common
- (id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

static Network *_network = nil;
+ (id)sharedNetwork{
    static dispatch_once_t predNetwork;
    dispatch_once(&predNetwork, ^{
        _network=[[Network alloc] init];
    });
    return _network;
}

+ (id)alloc
{
	NSAssert(_network == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}
@end
