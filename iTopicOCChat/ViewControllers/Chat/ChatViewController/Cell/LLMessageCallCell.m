//
//  LLMessageCallCell.m
//  LLWeChat
//
//  Created by GYJZH on 7/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageCallCell.h"
#import "LLSimpleTextLabel.h"
#import "ValueUtil.h"

//聊天界面bubble最宽可以占据屏幕宽度的百分比
#define CHAT_BUBBLE_MAX_WIDTH_FACTOR 0.58

//Label的约束
#define LABEL_BUBBLE_LEFT 12
#define LABEL_BUBBLE_RIGHT 12
#define LABEL_BUBBLE_TOP 14
#define LABEL_BUBBLE_BOTTOM 12

#define CONTENT_MIN_WIDTH  53
#define CONTENT_MIN_HEIGHT 41

#define IMAGE_LEFT_MARGIN 12
#define IMAGE_RIGHT_MARGIN 12
#define IMAGE_SIZE 20

static CGFloat preferredMaxTextWidth;

@interface LLMessageCallCell ()

@property (nonatomic,strong) UIImageView *logoImageView;
@property (nonatomic,strong) LLSimpleTextLabel *contentLabel;
@property (nonatomic,weak) UserModel *myUserModel;
@end

@implementation LLMessageCallCell {
}

+ (void)initialize {
    if (self == [LLMessageCallCell class]) {
        preferredMaxTextWidth = SCREEN_WIDTH * CHAT_BUBBLE_MAX_WIDTH_FACTOR;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentLabel = [[LLSimpleTextLabel alloc] init];
        self.contentLabel.scrollEnabled = NO;
        self.contentLabel.scrollsToTop = NO;
        self.contentLabel.editable = NO;
        self.contentLabel.selectable = NO;
        self.contentLabel.textContainerInset = UIEdgeInsetsZero;
        self.contentLabel.textContainer.lineFragmentPadding = 0;
        self.contentLabel.font = [self.class font];
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.backgroundColor = [UIColor clearColor];
//        self.contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.logoImageView = [[UIImageView alloc]init];
        [self.contentView addSubview:self.logoImageView];
 
        [self.contentView addSubview:self.contentLabel];

        self.myUserModel = [USERMANAGER userModel];
    }
    
    return self;
}

- (void)setMessageModel:(ChatModel *)messageModel {
    //dqdebug
//    BOOL needUpdateText = [messageModel checkNeedsUpdateForReuse];
    [super setMessageModel:messageModel];
    
    if (messageModel.issender == 1) {
        self.logoImageView.image = messageModel.subtype == SUBTYPE_CALL_AUDIO?[UIImage imageNamed:@"audio_receiver_right"]:[UIImage imageNamed:@"video_right"];
    } else {
        self.logoImageView.image = messageModel.subtype == SUBTYPE_CALL_AUDIO?[UIImage imageNamed:@"audio_receiver_left"]:[UIImage imageNamed:@"video_left"];
    }
     
//    if (needUpdateText) {
        self.contentLabel.attributedText = messageModel.attributedText;
//    }
    [self layoutMessageContentViews:messageModel.issender == 1];//dqdebug
    
    [self layoutMessageStatusViews:messageModel.issender == 1];
    
    if (messageModel.issender == 1) {
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName: self.myUserModel.avatar isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    } else {
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName: messageModel.other_photo isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    }
}


- (void)layoutMessageContentViews:(BOOL)isFromMe {
    CGSize textSize = [self.class sizeForLabel:self.messageModel.attributedText];
    CGSize size = textSize;
    size.width += LABEL_BUBBLE_LEFT + LABEL_BUBBLE_RIGHT;
    size.height += LABEL_BUBBLE_TOP + LABEL_BUBBLE_BOTTOM;
    if (size.width < CONTENT_MIN_WIDTH) {
        size.width = CONTENT_MIN_WIDTH;
    }else {
        size.width = ceil(size.width);
    }
    
    if (size.height < CONTENT_MIN_HEIGHT) {
        size.height = CONTENT_MIN_HEIGHT;
    }else {
        size.height = ceil(size.height);
    }

    if (isFromMe) {//右边
        CGRect frame = CGRectMake(0,
                  CONTENT_SUPER_TOP - BUBBLE_TOP_BLANK,
                  size.width + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK + IMAGE_SIZE + IMAGE_RIGHT_MARGIN,
                  size.height + BUBBLE_TOP_BLANK + BUBBLE_BOTTOM_BLANK);
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CGRectGetWidth(frame) - CONTENT_AVATAR_MARGIN;
        self.bubbleImage.frame = frame;

        self.contentLabel.frame = CGRectMake(CGRectGetMinX(self.bubbleImage.frame) + LABEL_BUBBLE_RIGHT + BUBBLE_LEFT_BLANK,
                    CGRectGetMinY(self.bubbleImage.frame) + LABEL_BUBBLE_TOP + BUBBLE_TOP_BLANK,
                                             textSize.width, textSize.height);
        
        self.logoImageView.frame = CGRectMake(CGRectGetMaxX(self.contentLabel.frame) + IMAGE_LEFT_MARGIN ,
                                              CGRectGetMinY(self.contentLabel.frame), IMAGE_SIZE,IMAGE_SIZE);
        
    } else {
        self.bubbleImage.frame = CGRectMake(CONTENT_AVATAR_MARGIN + CGRectGetMaxX(self.avatarImage.frame),
                    CONTENT_SUPER_TOP - BUBBLE_TOP_BLANK,
                    size.width + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK + IMAGE_SIZE + IMAGE_RIGHT_MARGIN,
                                            size.height + BUBBLE_TOP_BLANK + BUBBLE_BOTTOM_BLANK);

        self.logoImageView.frame = CGRectMake(CGRectGetMinX(self.bubbleImage.frame) + LABEL_BUBBLE_LEFT + BUBBLE_LEFT_BLANK,
                                              CGRectGetMinY(self.bubbleImage.frame) + LABEL_BUBBLE_TOP + BUBBLE_TOP_BLANK, IMAGE_SIZE,IMAGE_SIZE);
        
        self.contentLabel.frame = CGRectMake(CGRectGetMaxX(self.logoImageView.frame) + IMAGE_LEFT_MARGIN,
                    CGRectGetMinY(self.bubbleImage.frame) + LABEL_BUBBLE_TOP + BUBBLE_TOP_BLANK,
                                             textSize.width, textSize.height);
        
    }
}

+ (CGSize)sizeForLabel:(NSAttributedString *)text {
    CGRect frame = [text boundingRectWithSize:CGSizeMake(preferredMaxTextWidth, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    return frame.size;
}

+ (UIFont *)font {
    static UIFont *_font;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _font = [UIFont systemFontOfSize:17];
    });
    return _font;
}


+ (CGFloat)heightForModel:(ChatModel *)model {
    CGSize size = [self sizeForLabel:model.attributedText];
    
    CGFloat bubbleHeight = size.height + LABEL_BUBBLE_TOP + LABEL_BUBBLE_BOTTOM;
    if (bubbleHeight < CONTENT_MIN_HEIGHT)
        bubbleHeight = CONTENT_MIN_HEIGHT;
    else
        bubbleHeight = ceil(bubbleHeight);
    
    return bubbleHeight + CONTENT_SUPER_BOTTOM;
}

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint bubblePoint = [self.contentView convertPoint:point toView:self.bubbleImage];
    
    if (CGRectContainsPoint(self.bubbleImage.bounds, bubblePoint) && ![self.contentLabel shouldReceiveTouchAtPoint:[self.contentView convertPoint:point toView:self.contentLabel]]) {
        return self.bubbleImage;
    }
    return nil;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point {
    return [self hitTestForTapGestureRecognizer:point];
}

- (void)contentLongPressedBeganInView:(UIView *)view {
    self.bubbleImage.highlighted = YES;
    [self showMenuControllerInRect:self.bubbleImage.bounds inView:self.bubbleImage];
    
}

- (void)contentTouchCancelled {
    self.bubbleImage.highlighted = NO;
}

- (void)willBeginScrolling {
    self.bubbleImage.highlighted = NO;
    [self.contentLabel clearLinkBackground];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.hidden || !self.userInteractionEnabled || self.alpha <= 0.01)
        return nil;
    
    if (LLMessageCell_isEditing) {
        if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
            return self.contentView;
        }
    }else {
        if ([self.contentLabel pointInside:[self convertPoint:point toView:self.contentLabel] withEvent:event]) {
            return self.contentLabel;
        }else if ([self.contentView pointInside:[self convertPoint:point toView:self.contentView] withEvent:event]) {
            return self.contentView;
        }
    }

    return nil;
}

#pragma mark - 弹出菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[@"删除"];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"deleteAction:"];
}

- (void)copyAction:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.messageModel.content;
}

- (void)transforAction:(id)sender {
    
}

- (void)favoriteAction:(id)sender {
    
}

- (void)translateAction:(id)sender {
    
}




@end
