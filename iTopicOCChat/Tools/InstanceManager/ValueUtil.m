//
//  ValueUtil.m
//  pinpin
//
//  Created by DongJin on 15-3-18.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "ValueUtil.h"
#import "PDKeyChain.h"

#define EMPTY_ID @"0"
#define EMPTY_ID_INT 0

@implementation ValueUtil


+(NSString *)getSexKeyfromString:(NSString *)sexString
{
    NSString *sexCode = EMPTY_ID;
     if ([sexString isEqualToString:@"男"  ]) {
        sexCode =  @"1";
    }else if ([sexString isEqualToString:@"女"  ]) {
        sexCode =  @"2";
    }
    return sexCode;
}


+(NSString *)getSexString:(NSString *)sexCode
{
    NSString *sexString = @"未填";
    if ([sexCode isEqualToString:@"1"  ]) {
        sexString =  @"男";
    }else if ([sexCode isEqualToString:@"2"  ]) {
        sexString =  @"女";
    }
    return sexString;
}

+ (NSMutableArray*) getArrayFromString:(NSString *)preString{
    NSMutableArray* resultArray = [NSMutableArray array];
    NSArray* tempArray = [preString componentsSeparatedByString:@","];
    for (NSString *str in tempArray) {
        if (![str isEqualToString:@""]) {
            [resultArray addObject:str];
        }
    }
   return resultArray;
}

+(NSString*) getStringFromArray:(NSArray *)array
{
    return [array componentsJoinedByString:@","];
}

+(NSString *)getFriendTypeString:(int)friendShip
{
    NSString *relationStr = @"关注"; //0 未关注
    switch (friendShip) {
        case INT_FOLLOWTYPE_MY_FANS: //2 TA关注我
            relationStr = @"TA关注我";
            break;
        case INT_FOLLOWTYPE_MY_FOLLOWING: //1 已关注
            relationStr = @"已关注";
            break;
        case INT_FOLLOWTYPE_EACH: //3 互相关注
            relationStr = @"互相关注";
            break;
        default:
            break;
    }
    return relationStr;
    
}

+(UIImage *)getFriendTypeImage:(int)friendShip
{
    NSString *relationStr = @"green_rect"; //0 未关注
    switch (friendShip) {
        case INT_FOLLOWTYPE_MY_FANS: //2 TA关注我
            //			relationStr = "TA关注我";
            break;
        case INT_FOLLOWTYPE_MY_FOLLOWING: //1 已关注
            relationStr = @"red_rect";
            break;
        case INT_FOLLOWTYPE_EACH: //3 互相关注
            //			relationStr = "互相关注";
            relationStr = @"red_rect";
            break;
        default:
            break;
    }
    return [UIImage imageNamed:relationStr];
    
}



#pragma mark - 转换时间
/**
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 */
+(NSString *) compareCurrentTime:(NSString *)dateString
{
    NSDate *compareDate = [ValueUtil dateFromString:dateString];
   return  [ValueUtil compareCurrentTimeWithDate:compareDate];
}

+(NSString *) timeStringWithDate:(NSDate *)compareDate
{
    return [ValueUtil isToday:compareDate]?[ValueUtil stringTimeFromDate:compareDate] : [ValueUtil stringDateFromDate:compareDate];
}

#pragma mark - 转换时间
+(NSString *) compareCurrentTimeWithTimestamp:(long)timestamp
{
    if (timestamp == 0){
        return @"很久之前";
    }
    double timeInterval = timestamp;
    return [ValueUtil compareCurrentTimeWithDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
}

+(NSString *) compareCurrentTimeWithDate:(NSDate *)compareDate
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    int temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = @"刚刚";
    }else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%d分钟前",temp];
    } else {
        result = [ValueUtil timeStringWithDate:compareDate];
    }
    
    return  result;
}

+ (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    dateFormatter = nil;
    return destDate;
}

+ (NSString *)stringDateFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
    dateFormatter = nil;
    return destDateString;
}

+ (NSString *)stringTimeFromDate:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *destDateString = [dateFormatter stringFromDate:date];
      dateFormatter = nil;
    return destDateString;
}

+ (NSString *)timeIntervalBeforeNowLongDescription:(int)timestamp {
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    //格式化日期字符串,只保留年、月、日信息
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *selfDateFormatString = [dateFormatter stringFromDate:date];
    NSString *nowDateFormatString = [dateFormatter stringFromDate:[NSDate date]];
    
    //当天
    if ([selfDateFormatString isEqualToString:nowDateFormatString]) {
        [dateFormatter setDateFormat:@"HH:mm"];
        return [dateFormatter stringFromDate:date];
    }else {
        //格式化日期,将日期格式化为日期当天的0时0分0秒
        NSDate *selfDateFormatDate = [dateFormatter dateFromString:selfDateFormatString];
        NSDate *nowDateFormatDate = [dateFormatter dateFromString:nowDateFormatString];
        NSTimeInterval timeInterval = [nowDateFormatDate timeIntervalSinceDate:selfDateFormatDate];
        
        //昨天
        if (timeInterval == 24 * 60 * 60) {
            [dateFormatter setDateFormat:@"HH:mm"];
            return [NSString stringWithFormat:@"昨天 %@",[dateFormatter stringFromDate:date]];
        }
        //一周内
        else if (timeInterval < 7 * 24 * 60 * 60) {
            [dateFormatter setDateFormat:@"EEEE HH:mm"];
            return [dateFormatter stringFromDate:date];
        }
        //一周以前的时间
        else {
            [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
            return [dateFormatter stringFromDate:date];
        }
    }
}

+ ( BOOL )isToday:(NSDate *)createDate
{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    // 1. 获得当前时间的年月日
    NSDateComponents *nowCmps = [calendar components :unit fromDate :[ NSDate date ]];
    // 2. 获得 self 的年月日
    NSDateComponents *selfCmps = [calendar components :unit fromDate : createDate ];
    return
    (selfCmps. year == nowCmps. year ) &&      //直接分别用当前对象和现在的时间进行比较，比较的属性就是年月日
    (selfCmps. month == nowCmps. month ) &&
    (selfCmps. day == nowCmps. day );
}

+ (int)getIntFromStringWithCatch:(NSString *)idString
{
    int intString = 0;
    @try{
        intString = [idString intValue];
    } @catch (NSException *exception) {
    }
    return intString;
}

/**
 * @param fileName 七牛的文件名
 * @param limit 限制的最大or最小边长
 * @param max YES,是限制最大长，NO=限制最小长
 * @return
 */
+ (NSString *)getQiniuUrlByFileName:(NSString *)filename limit:(int)limit max:(BOOL)max
{
    int limitpx = limit * [[UIScreen mainScreen] scale];
    return [ValueUtil getQiniuUrlByParams:filename params:[NSString stringWithFormat:@"?imageView2/%d/w/%d/h/%d",max?3:2,limitpx,limitpx]];
}

/**
 * @param fileName 七牛的文件名
 * @param isThumbnail 是否返回缩略图
 * @return
 */
+ (NSString *)getQiniuUrlByFileName:(NSString *)filename isThumbnail:(BOOL)isThumbnail
{
    return [ValueUtil getQiniuUrlByParams:filename params:(isThumbnail?@"?imageView2/1/w/360/h/360":@"")];
}

/**
 * @param fileName 七牛的文件名
 * @param paramsString 参数
 * @return
 */
+ (NSString *)getQiniuUrlByParams:(NSString *)filename params:(NSString *)paramsString
{
    if ([ValueUtil isEmptyString:filename]) {
        //为null 或者 “” 或者NSNULL（比如从dic里取出来的object）
        return @"";
    } else if([filename hasPrefix:@"http"]){
        return filename;
    } else {
        return [NSString stringWithFormat:@"%@%@%@",QINIU_URL,filename,paramsString];
    }
}

#pragma mark 版本比较
+ (BOOL)compareVesion:(NSString *)targetVersion currentVersion:(NSString *)currentVersion
{
    NSArray *versionArray = [targetVersion componentsSeparatedByString:@"."];//服务器返回版
    NSArray *currentVesionArray = [currentVersion componentsSeparatedByString:@"."];//当前版本
    NSInteger minArrayLength = MIN(versionArray.count, currentVesionArray.count);
    BOOL needUpdate = NO;
    for(int i=0;i<minArrayLength;i++){//以最短的数组长度为遍历次数,防止数组越界
        //取出每个部分的字符串值,比较数值大小
        NSString *localElement = currentVesionArray[i];
        NSString *appElement = versionArray[i];
        NSInteger localValue =  localElement.integerValue;
        NSInteger appValue = appElement.integerValue;
        if(localValue < appValue) {
            //从前往后比较数字大小,一旦分出大小,跳出循环
            needUpdate = YES;
            break;
        } else if(localValue > appValue){
            needUpdate = NO;
            break;
        }
        if (i == minArrayLength - 1) {
            //已经比到最后一位了还是一样，看谁长
            if(versionArray.count > currentVesionArray.count){
                needUpdate = YES;
            }
        }
    }
    return needUpdate;
}

//随机字符串
+(NSString *)ramdomId
{
    CFUUIDRef uuid_ref = CFUUIDCreate(NULL);
    CFStringRef uuid_string_ref= CFUUIDCreateString(NULL, uuid_ref);
    CFRelease(uuid_ref);
    NSString *keyChain = [NSString stringWithString:(__bridge NSString *)uuid_string_ref];
    CFRelease(uuid_string_ref);
    return keyChain;
}


//设备唯一码
+(NSString *)deviceId
{
    NSString *keyChain = [PDKeyChain keyChainLoad];
    if (!keyChain) {
        //没存过东西
        keyChain = [ValueUtil ramdomId];
        [PDKeyChain keyChainSave:keyChain];
    }
    return keyChain;
}


// 将字典或者数组转化为JSON串
+ (NSString*)convertToJSONData:(id)infoDict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData)
    {
        NSLog(@"Got an error: %@", error);
    }else
    {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    
    return [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}



+ (BOOL)isEmptyString:(id)object
{
    if ([object isKindOfClass:[NSNull class]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        NSString *string = object;
        if (string == nil || string == NULL) {
            return YES;
        }
        if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
            return YES;
        }
    } else if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = object;
        if (!number) {
            return YES;
        }
    }
    if (object) {
        return NO;
    } else {
        return YES;
    }
}

//算出价格String. 参数price单位是分
+ (NSString *)findMoneyString:(NSNumber *)money
{
    if(money){
        int moneyint = [money intValue];
        float moneyfloat = moneyint/100.0f;
        if (moneyfloat == (int)moneyfloat) {
            //没小数点
            return [NSString stringWithFormat:@"%d",(int)moneyfloat];
        }else{
            return [NSString stringWithFormat:@"%.2f",moneyfloat];
        }
    } else {
        return @"0";
    }
}

+ (NSString *)findMoneyInt:(int)money
{
    float moneyfloat = money/100.0f;
    if (moneyfloat == (int)moneyfloat) {
        //没小数点
        return [NSString stringWithFormat:@"%d",(int)moneyfloat];
    }else{
        return [NSString stringWithFormat:@"%.2f",moneyfloat];
    }
}

//get time string like 00:10 style
+ (NSString *)getTimeStringWithDuration:(NSInteger)duration {
    int minutes = floor(duration/60);
    int seconds = round(duration - minutes * 60);
    NSString *timeString = [NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
    
    return timeString;
}


+ (NSString *)getVoiceLocalPathWithFileKey:(NSString *)fileKey {
//    NSString *fileExtension = @"amr";
    NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cacheDirectory isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        BOOL isDirectoryCreated = [[NSFileManager defaultManager] createDirectoryAtPath:cacheDirectory
                                                            withIntermediateDirectories:YES
                                                                             attributes:nil
                                                                                  error:&error];
        if (!isDirectoryCreated) {
            NSException *exception = [NSException exceptionWithName:NSInternalInconsistencyException
                                                             reason:@"Failed to crate cache directory"
                                                           userInfo:@{ NSUnderlyingErrorKey : error }];
            @throw exception;
        }
    }
    NSString *temporaryFilePath = [cacheDirectory stringByAppendingPathComponent:fileKey];
    return temporaryFilePath;
}


@end
