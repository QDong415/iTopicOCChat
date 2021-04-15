//
//  XHEmotionManager.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionManager.h"

@implementation XHEmotionManager

- (void)dealloc {
    [self.emotions removeAllObjects];
    self.emotions = nil;
}

//当前类型的表情 一页能显示多少个小表情， -1是因为如果不是gif，最后要有个删除按钮
- (int)emotionCountPrePage
{
    return [self isGifEmoji]? (GIFNumPerLine * GIFLines):((NumPerLine * Lines) - 1);
}


//当前类型的表情 一共有几页
- (int)emotionPageCount
{
    return (int)[self.emotionImageNames count] / self.emotionCountPrePage +  ([self.emotionImageNames count] % self.emotionCountPrePage == 0 ? 0:1) ;
}
@end
