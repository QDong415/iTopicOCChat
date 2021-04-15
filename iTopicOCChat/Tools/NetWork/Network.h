//
//  Network.h

//  Created by QDong Email: 285275534@qq.com on 13-2-24.
//  Copyright (c) 2017年 iTopic. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BASEURL(url_api) [NSString stringWithFormat:@"%@api/%@",HTTP_URL,url_api]

#define NETWORK [Network sharedNetwork]

typedef void (^requestSuccess)(NSURLSessionTask *task, id responseObject);
typedef void (^requestFailure)(NSURLSessionTask *operation, NSError *error);

@interface Network : NSObject
{
}
+ (id)sharedNetwork;

#pragma mark - 纯粹的调用AF访问网络，GET请求
- (void)GET:(NSString*)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock;

#pragma mark - 纯粹的调用AF访问网络，POST请求
- (void)POST:(NSString*)urlString parameters:(NSDictionary*)parameters success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock;

#pragma mark - 2017-02-05 封装好的 GET请求 + jsonmodel解析，直接回调model
/**
 * api 接口，比如@"topic/getlist"
 * parameters 参数，无需拼接userid
 * responseClass 返回后需要解析成的Model类型
 */
- (void)getDataByApi:(NSString *)api parameters:(NSDictionary *)parameters responseClass:(Class)cls success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock;

#pragma mark - 2017-02-05  封装好的 POST请求 + jsonmodel解析，直接回调model
/**
 * api 接口，比如@"topic/getlist"
 * parameters 参数，无需拼接userid
 * responseClass 返回后需要解析成的Model类型
 */
- (void)postDataByApi:(NSString *)api parameters:(NSDictionary*)parameters responseClass:(Class)cls success:(requestSuccess)requestSuccessBlock failure:(requestFailure)requestFailureBlock;


@end












