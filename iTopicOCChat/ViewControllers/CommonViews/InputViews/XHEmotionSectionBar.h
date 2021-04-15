//
//  XHEmotionSectionBar.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHEmotionManager.h"

@protocol XHEmotionSectionBarDelegate <NSObject>

/**
 *  点击某一类gif表情的回调方法
 *
 *  @param emotionManager 被点击的管理表情Model对象
 *  @param section        被点击的位置
 */
- (void)didSelectedEmotionManager:(XHEmotionManager *)emotionManager atSection:(NSInteger)section;

/**
 * 点击发送按钮
 */
- (void)didSelectedSend;

@end

@interface XHEmotionSectionBar : UIView

@property (nonatomic, weak) id <XHEmotionSectionBarDelegate> delegate;

/**
 *  数据源
 */
@property (nonatomic, weak) NSArray *emotionManagers;

/**
 * 当前选中的表情栏目index
 */
@property (nonatomic, assign) int currentIndex;


/**
 *  是否显示发送的按钮
 */
@property (nonatomic, assign) BOOL hideSendButton; // default is NO


- (instancetype)initWithFrame:(CGRect)frame hideSendButton:(BOOL)hideSendButton;


/**
 *  根据数据源刷新UI布局和数据
 */
- (void)reloadData;

@end
