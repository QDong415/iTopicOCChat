/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <UIKit/UIKit.h>
#import "XHEmotionManager.h"
#import "FaceManager.h"

//表情其中一个collent面板
@protocol FacialViewDelegate

@optional

/** 
 * 选择了一个面板上的小表情， :
 * indexInManager: 这个表情在XHEmotionManager的位置
 * managerIndex: 这个表情所属的XHEmotionManager 在整个表情managers array的位置
 */
-(void)selectedEmotionAtIndex:(int)indexInManager inManagerSection:(int)managerIndex;

//选择了一个面板上的删除
-(void)selectedDelete;

@end


@interface FacialView : UIView
{
}

@property(nonatomic,weak) id<FacialViewDelegate> delegate;

//加载一页表情
-(void)loadEmotionBoard:(XHEmotionManager *)emotionManager inPage:(int)page;

@end
