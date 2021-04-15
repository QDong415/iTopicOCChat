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

#import "FacialView.h"


#define FaceSize  30


#define GifFaceSize  60

/*
 ** 两边边缘间隔 整个gridlayout的 margin
 */
//#define EdgeDistance 10
/*
 ** 上下边缘间隔 整个gridlayout的 margin
 */
#define EdgeInterVal 12
@interface FacialView ()

@end

//其中一页（一个gridview）
@implementation FacialView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


//加载一页表情
-(void)loadEmotionBoard:(XHEmotionManager *)emotionManager inPage:(int)page
{
    //一个面板有几 行 表情
    int emotionLineCount = emotionManager.isGifEmoji?GIFLines:Lines;
    
    //一个面板有几 列 表情
    int emotionColumnCount = emotionManager.isGifEmoji?GIFNumPerLine:NumPerLine;
    
    //一行表情的高度 （由于没有64 * 64分辨率的表情图片，导致无法做到无缝cell）
    int emotionLineHeight = emotionManager.isGifEmoji?GifFaceSize:FaceSize;
    
    //每一页有几个表情（-1表示不算删除按钮）
    int emotionMAXCountInBoard = emotionColumnCount * emotionLineCount - (emotionManager.isGifEmoji?0:1);
    
    //两个表情上下垂直间隔
    CGFloat verticalInterval = (CGRectGetHeight(self.bounds)-2*EdgeInterVal -emotionLineCount*emotionLineHeight)/(emotionLineCount-1);
    
    //每个小表情的图片imageName<NSString>
    NSMutableArray *emotionImageNames = emotionManager.emotionImageNames;
    
    //每个表情的宽度（小表情宽度铺满 用来解决点到间隙的问题）
     int widthSize = CGRectGetWidth(self.bounds) / emotionColumnCount;
//    int widthSize = emotionManager.isGifEmoji?GifFaceSize:(CGRectGetWidth(self.bounds) / emotionColumnCount);
   
    
    //相邻两个表情 左右水平间隔
    CGFloat horizontalInterval = 0;
//    CGFloat horizontalInterval = emotionManager.isGifEmoji?((CGRectGetWidth(self.bounds) - emotionColumnCount*widthSize) / (emotionColumnCount+1)):0;
    
    int emotionCount = (int)[emotionImageNames count];
    
    for (int i = 0; i<emotionLineCount; i++)
    {
        for (int x = 0;x<emotionColumnCount;x++)
        {
            //当前这个小表情位 理应应该放第几个表情
            int currentIndexInManager = page*emotionMAXCountInBoard+i*emotionColumnCount+x;
            
            if (currentIndexInManager == emotionCount) {
                //最后一个才会出现
                if(emotionManager.isGifEmoji){
                    //如果是gif图，说明已经遍历结束，直接跳出
                    return;
                }
                
                UIImageView *expressionButton =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"faceDelete"]];
                expressionButton.tag = -1;
                [expressionButton setFrame:CGRectMake((emotionColumnCount - 1)*widthSize,
                                                      (emotionLineCount-1)*emotionLineHeight + (emotionLineCount-1)*verticalInterval+EdgeInterVal,
                                                      widthSize,
                                                      emotionLineHeight)];
                expressionButton.contentMode =  UIViewContentModeScaleAspectFit;
                [self addSubview:expressionButton];
                expressionButton.userInteractionEnabled = YES;
                UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceClick:)];
                [expressionButton addGestureRecognizer:singleTap1];
                return;
            }
            
            UIImageView *expressionButton =[[UIImageView alloc] init];
            expressionButton.contentMode =  UIViewContentModeScaleAspectFit;
            [self addSubview:expressionButton];
            [expressionButton setFrame:CGRectMake(x*widthSize + horizontalInterval * (x+1),
                                                  i*emotionLineHeight +i*verticalInterval+EdgeInterVal,
                                                  widthSize,
                                                  emotionLineHeight)];
            
            if(!emotionManager.isGifEmoji){
                //如果不是gif大表情，每页还需要添加删除按钮
                
                // if等号前的 x+1 是因为x是从0开始的 后面的+1 是指删除按钮的位置
                if (i*emotionColumnCount + x + 1 == emotionMAXCountInBoard + 1) {
                    [expressionButton setImage:[UIImage imageNamed:@"faceDelete"]];
                    expressionButton.tag = -1;
                    
                } else {
                    expressionButton.tag = currentIndexInManager;
                    [expressionButton setImage:[UIImage imageNamed:emotionImageNames[expressionButton.tag]]];
                }
                
            } else {
                //gif大表情，不需要删除按钮
                expressionButton.tag = currentIndexInManager;
                [expressionButton setImage:[UIImage imageNamed:emotionImageNames[expressionButton.tag]]];
            }
          
            
            expressionButton.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(faceClick:)];
            [expressionButton addGestureRecognizer:singleTap1];
        }
    }
}

- (void)faceClick:(UITapGestureRecognizer *)singleTap{
    UIImageView *faceImageView =  (UIImageView *)[singleTap view];
    
    if (faceImageView.tag == -1) {
        [_delegate selectedDelete];
        return ;
    }
    
    [_delegate selectedEmotionAtIndex:(int)faceImageView.tag inManagerSection:(int)self.tag];
    
    return;
    
}


@end
