//
//  XHEmotionManager.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>



#define NumPerLine 7
#define Lines    3

#define GIFNumPerLine 4
#define GIFLines    2


//一种表情的实体类，其中包含了一个array，存了他的每个表情
@interface XHEmotionManager : NSObject


@property (nonatomic, assign) BOOL isGifEmoji;
/**
 * 显示在最底部的表情条里的logo图标的imagename
 */
@property (nonatomic, strong) NSString *emotionBarLogoImageName;

/**
 *  某一类 每个小表情的图片imageName<NSString>
 */
@property (nonatomic, strong) NSMutableArray *emotionImageNames;


//当前类型的表情 一页能显示多少个小表情， -1是因为如果不是gif，最后要有个删除按钮
@property (nonatomic, assign, readonly) int emotionCountPrePage;

//当前类型的表情 一共有几页
@property (nonatomic, assign, readonly) int emotionPageCount;

/**
 *  某一类表情的数据源<XHEmotion> debug废弃
 */
@property (nonatomic, strong) NSMutableArray *emotions;

@end
