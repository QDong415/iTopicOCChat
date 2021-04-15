//
//  ValueUtil.h
//  pinpin
//
//  Created by DongJin on 15-3-18.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ValueUtil : NSObject
#pragma mark 性别key（“male”） 与 string（“男”）转换
+(NSString *)getSexKeyfromString:(NSString *)sexString;
+(NSString *)getSexString:(NSString *)sexCode;

#pragma mark 各种时间 转为 “刚刚，10：00”
+(NSString *) compareCurrentTime:(NSString *)dateString;
+(NSString *) timeStringWithDate:(NSDate *)compareDate;
+(NSString *) compareCurrentTimeWithDate:(NSDate *)compareDate;
+(BOOL) isToday:(NSDate *)createDate;
+(NSString *) timeIntervalBeforeNowLongDescription:(int)timestamp;
+(NSString *) compareCurrentTimeWithTimestamp:(long)timestamp;

#pragma mark 关注状态 - 关注string转化
+(NSString *)getFriendTypeString:(int)friendShip;
+(UIImage *)getFriendTypeImage:(int)friendShip;

+(NSString*) getStringFromArray:(NSArray *)array;
+(NSMutableArray*) getArrayFromString:(NSString *)preString;

+(NSString *)stringDateFromDate:(NSDate *)date;

+ (NSString *)getQiniuUrlByFileName:(NSString *)filename limit:(int)limit max:(BOOL)max;
+ (NSString *)getQiniuUrlByFileName:(NSString *)filename isThumbnail:(BOOL)isThumbnail;
+ (NSString *)getQiniuUrlByParams:(NSString *)filename params:(NSString *)paramsString;

// 将字典或者数组转化为JSON串
+ (NSString*)convertToJSONData:(id)infoDict;

+ (BOOL)isEmptyString:(NSString *)string;

+ (NSString *)findMoneyInt:(int)money;
+ (NSString *)findMoneyString:(NSNumber *)money;

//设备唯一码
+(NSString *)deviceId;

+ (BOOL)compareVesion:(NSString *)targetVersion currentVersion:(NSString *)currentVersion;

+ (NSString *)getTimeStringWithDuration:(NSInteger)duration;
+ (NSString *)getVoiceLocalPathWithFileKey:(NSString *)fileKey;
@end
