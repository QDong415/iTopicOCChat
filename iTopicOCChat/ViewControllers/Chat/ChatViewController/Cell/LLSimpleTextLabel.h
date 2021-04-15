//
//  LLSimpleTextLabel.h
//  LLWeChat
//
//  Created by GYJZH on 8/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLLabelRichTextData;

typedef void (^LLLabelTapAction)(LLLabelRichTextData *data);

typedef void (^LLLabelLongPressAction)(LLLabelRichTextData *data, UIGestureRecognizerState state);


typedef NS_ENUM(NSInteger, LLLabelRichTextType) {
    kLLLabelRichTextTypeURL = 0,
    kLLLabelRichTextTypePhoneNumber,
    kLLLabelRichTextTypeUser,
    kLLLabelRichTextTypeAt
};

@class LLSimpleTextLabel;

@interface LLLabelRichTextData : NSObject

@property (nonatomic) NSRange range;

@property (nonatomic) LLLabelRichTextType type;

@property (nonatomic) NSURL *url;

@property (nonatomic, copy) NSString *phoneNumber;

- (instancetype)initWithType:(LLLabelRichTextType)type;

@end


/**
 *  实现的功能：
 *  1、可以识别电话号码、WebURL、邮件
 *  2、以上链接支持点击、长按两种操作
 *  3、可以显示Emotion，可以设置字体、行间距
 */
@interface LLSimpleTextLabel : UITextView

//派发longPress事件需要的最短事件，默认为0.8秒
@property (nonatomic) CGFloat longPressDuration;

//自定义的LLLabelRichTextData，目前用于回复xxx，由外界传进来
@property (nonatomic, strong) NSMutableArray<LLLabelRichTextData *> *customerRichTextDatas;

//是否支持@人的正则，由外界传进来，和上面的customerRichTextDatas一起传入
@property (nonatomic, assign) BOOL atRegexEnable;

@property (nonatomic, copy) LLLabelTapAction tapAction;

@property (nonatomic, copy) LLLabelLongPressAction longPressAction;

- (BOOL)shouldReceiveTouchAtPoint:(CGPoint)point;

- (void)swallowTouch;

- (void)clearLinkBackground;

- (UITapGestureRecognizer *)addTapGestureRecognizer:(SEL)action;

+ (NSMutableAttributedString *)createAttributedStringWithEmotionString:(NSString *)emotionString font:(UIFont *)font lineSpacing:(NSInteger)lineSpacing;

+ (NSMutableAttributedString *)createAttributedStringWithEmotionString:(NSString *)emotionString font:(UIFont *)font lineSpacing:(NSInteger)lineSpacing textColor:(UIColor *)textColor;

@end
