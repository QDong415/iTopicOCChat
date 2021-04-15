//
//  LLMessageVoiceCell.m
//  LLWeChat
//
//  Created by GYJZH on 8/30/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageVoiceCell.h"
#import "ValueUtil.h"

//默认动画时间，单位秒
#define DEFAULT_DURATION 0.25
#define OFFSET_Y 5
#define RECORD_ANIMATION_KEY @"RecordAnimate"
//录音允许的最长时间
#define MAX_RECORD_TIME_ALLOWED 60

@interface LLMessageVoiceCell ()

@property (strong, nonatomic) UIImageView *voiceImageView;
@property (nonatomic) UILabel *durationLabel;
@property (nonatomic) UIView *isMediaPlayedIndicator;
@property (nonatomic) UIImageView *downloadingImageView;

@property (nonatomic,weak) UserModel *myUserModel;

@end

@implementation LLMessageVoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _voiceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, OFFSET_Y + (AVATAR_HEIGHT - 17)/2, 12.5, 17)];
        _voiceImageView.contentMode = UIViewContentModeCenter;
        _voiceImageView.animationDuration = 1;
        [self.contentView addSubview:_voiceImageView];
        
        _durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, OFFSET_Y + 20, 100, 20)];
        _durationLabel.font = [UIFont systemFontOfSize:16];
        _durationLabel.textColor = [UIColor colorWithRed:125/255.0 green:125/255.0 blue:125/255.0 alpha:1];
        _durationLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_durationLabel];
        
        _isMediaPlayedIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
        _isMediaPlayedIndicator.backgroundColor = [UIColor colorWithRed:231/255.0 green:80/255.0 blue:73/255.0 alpha:1];
        _isMediaPlayedIndicator.layer.cornerRadius = 5;
        _isMediaPlayedIndicator.clipsToBounds = YES;
        [self.contentView addSubview:_isMediaPlayedIndicator];
        
        self.bubbleImage.frame = CGRectMake(0, -BUBBLE_TOP_BLANK + OFFSET_Y, 100, AVATAR_HEIGHT + BUBBLE_TOP_BLANK + BUBBLE_BOTTOM_BLANK);
        
        self.myUserModel = [USERMANAGER userModel];
    }
    
    return self;
}

- (void)prepareForUse:(BOOL)isFromMe {
    [super prepareForUse:isFromMe];

    CGRect frame = self.avatarImage.frame;
    frame.origin.y = OFFSET_Y;
    self.avatarImage.frame = frame;

}

- (void)setMessageModel:(ChatModel *)messageModel {
    
    [super setMessageModel:messageModel];
    
    if (messageModel.isMediaPlaying) {
        [self startVoicePlaying];
    }else {
        [self stopVoicePlaying];
    }
    
    self.isMediaPlayedIndicator.hidden = messageModel.issender == 1 || messageModel.isMediaPlayed;
    self.durationLabel.text = [NSString stringWithFormat:@"%.0f''", round(messageModel.mediaDuration)];
    [self.durationLabel sizeToFit];
    
    if (self.messageModel.issender == 1) {
//        if ([messageModel checkNeedsUpdateUploadStatus]){
//            [self updateMessageUploadStatus]; // super里已经做过了
//        }
    }else {
//        if ([messageModel checkNeedsUpdateDownloadStatus]) {
            [self updateMessageDownloadStatus];
//        }
    }
    
    if (messageModel.needAnimateVoiceCell) {
        messageModel.needAnimateVoiceCell = NO;
        [self layoutSubviewsWithAnimation:YES];
    }else {
        [self layoutMessageContentViews:self.messageModel.issender == 1];
        [self layoutMessageStatusViews:self.messageModel.issender == 1];
    }
    
    if (messageModel.issender == 1) {
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName: self.myUserModel.avatar isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    } else {
        [self.avatarImage sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName: messageModel.other_photo isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    }
}

- (BOOL)isVoicePlaying {
    return self.voiceImageView.isAnimating;
}

- (void)stopVoicePlaying {
    self.voiceImageView.image = self.messageModel.issender == 1 ?
    [UIImage imageNamed:@"SenderVoiceNodePlaying"] :
    [UIImage imageNamed:@"ReceiverVoiceNodePlaying"];
    [self.voiceImageView stopAnimating];
    self.voiceImageView.animationImages = nil;
    self.isMediaPlayedIndicator.hidden = YES;
}

- (void)startVoicePlaying {
    self.voiceImageView.animationImages = self.messageModel.issender == 1 ?
    @[[UIImage imageNamed:@"SenderVoiceNodePlaying001"],
      [UIImage imageNamed:@"SenderVoiceNodePlaying002"],
      [UIImage imageNamed:@"SenderVoiceNodePlaying003"]] :
    @[[UIImage imageNamed:@"ReceiverVoiceNodePlaying001"],
      [UIImage imageNamed:@"ReceiverVoiceNodePlaying002"],
      [UIImage imageNamed:@"ReceiverVoiceNodePlaying003"]];
    [self.voiceImageView startAnimating];
    self.isMediaPlayedIndicator.hidden = YES;
}

- (void)updateVoicePlayingStatus {
    if (self.messageModel.isMediaPlaying != self.isVoicePlaying) {
        if (self.messageModel.isMediaPlaying) {
            [self startVoicePlaying];
        }else {
            [self stopVoicePlaying];
        }
    }
}

#pragma mark - 布局 -
//目前只支持发送方动画，接收方在收到语音消息后没有动画
- (void)layoutSubviewsWithAnimation:(BOOL)isFromMe {
    if (!isFromMe)
        return;
    
    CGRect frame = self.bubbleImage.frame;
    frame.size.width = MIN_CELL_WIDTH + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK;
    frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CGRectGetWidth(frame) - CONTENT_AVATAR_MARGIN;
    self.bubbleImage.frame = frame;
    
    frame = self.durationLabel.frame;
    frame.origin.x = CGRectGetMinX(self.bubbleImage.frame) - self.durationLabel.intrinsicContentSize.width;
    frame.origin.y = OFFSET_Y + 10;
    self.durationLabel.frame = frame;
    
    frame = self.voiceImageView.frame;
    frame.origin.x = CGRectGetMaxX(self.bubbleImage.frame) - BUBBLE_LEFT_BLANK - 15 - CGRectGetWidth(frame);
    self.voiceImageView.frame = frame;
    
    [self layoutMessageStatusViews:isFromMe];
    
    [UIView animateWithDuration:DEFAULT_DURATION animations:^{
        CGRect frame = self.bubbleImage.frame;
        frame.size.width = [self cellWidth] + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK;
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CGRectGetWidth(frame) - CONTENT_AVATAR_MARGIN;
        self.bubbleImage.frame = frame;
        
        frame = self.durationLabel.frame;
        frame.origin.x = CGRectGetMinX(self.bubbleImage.frame) - self.durationLabel.intrinsicContentSize.width;
        frame.origin.y = OFFSET_Y + 20;
        self.durationLabel.frame = frame;
        
        frame = self.voiceImageView.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImage.frame) - BUBBLE_LEFT_BLANK - 15 - CGRectGetWidth(frame);
        self.voiceImageView.frame = frame;
        
        [self layoutMessageStatusViews:isFromMe];
        
    }];

}

- (void)layoutMessageContentViews:(BOOL)isFromMe {
    CGRect frame;
    
    if (isFromMe) {
        frame = self.bubbleImage.frame;
        frame.size.width = [self cellWidth] + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK;
        frame.origin.x = CGRectGetMinX(self.avatarImage.frame) - CGRectGetWidth(frame) - CONTENT_AVATAR_MARGIN;
        self.bubbleImage.frame = frame;
        
        frame = self.voiceImageView.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImage.frame) - BUBBLE_LEFT_BLANK - 15 - CGRectGetWidth(frame);
        self.voiceImageView.frame = frame;
        
        frame = self.durationLabel.frame;
        frame.origin.x = CGRectGetMinX(self.bubbleImage.frame) - self.durationLabel.intrinsicContentSize.width;
        frame.origin.y = OFFSET_Y + 20;
        self.durationLabel.frame = frame;
        
    }else {
        frame = self.bubbleImage.frame;
        frame.size.width = [self cellWidth] + BUBBLE_LEFT_BLANK + BUBBLE_RIGHT_BLANK;
        frame.origin.x = CONTENT_AVATAR_MARGIN + CGRectGetMaxX(self.avatarImage.frame);
        self.bubbleImage.frame = frame;

        frame = self.voiceImageView.frame;
        frame.origin.x = CGRectGetMinX(self.bubbleImage.frame) + BUBBLE_LEFT_BLANK + 15;
        self.voiceImageView.frame = frame;
        
        frame = self.durationLabel.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImage.frame);
        frame.origin.y = OFFSET_Y + 20;
        self.durationLabel.frame = frame;
        
        frame = _isMediaPlayedIndicator.frame;
        frame.origin.x = CGRectGetMaxX(self.bubbleImage.frame);
        _isMediaPlayedIndicator.frame = frame;
        
    }
}

- (void)layoutMessageStatusViews:(BOOL)isFromMe {
    if (isFromMe) {
        _indicatorView.center = CGPointMake(CGRectGetMinX(self.bubbleImage.frame) - CGRectGetWidth(_indicatorView.frame)/2 - ACTIVITY_VIEW_X_OFFSET + BUBBLE_LEFT_BLANK, CGRectGetMidY(self.bubbleImage.frame) + ACTIVITY_VIEW_Y_OFFSET);
        
        _statusButton.center = CGPointMake(CGRectGetMinX(self.durationLabel.frame) - CGRectGetWidth(_statusButton.frame)/2 - ACTIVITY_VIEW_X_OFFSET, CGRectGetMidY(self.bubbleImage.frame) + ACTIVITY_VIEW_Y_OFFSET);
    }else {
        _indicatorView.center = CGPointMake(CGRectGetMaxX(self.durationLabel.frame) + CGRectGetWidth(_indicatorView.frame)/2 + ACTIVITY_VIEW_X_OFFSET, CGRectGetMidY(self.bubbleImage.frame) + ACTIVITY_VIEW_Y_OFFSET);
        
        _statusButton.center = CGPointMake(CGRectGetMaxX(self.durationLabel.frame) + CGRectGetWidth(_statusButton.frame)/2 + ACTIVITY_VIEW_X_OFFSET, CGRectGetMidY(self.bubbleImage.frame) + ACTIVITY_VIEW_Y_OFFSET);
    }
}

- (CGFloat)cellWidth {
    return MIN_CELL_WIDTH + (MAX_CELL_WIDTH - MIN_CELL_WIDTH) * sin(self.messageModel.mediaDuration / MAX_RECORD_TIME_ALLOWED * M_PI / 2);
}

- (void)updateMessageUploadStatus {
    switch (self.messageModel.state) {
        case FAIL:
            SHOW_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            self.voiceImageView.hidden = NO;
            self.durationLabel.hidden = NO;;
            break;
            
        case INPROGRESS:
            HIDE_STATUS_BUTTON;
            SHOW_INDICATOR_VIEW;
            self.durationLabel.hidden = YES;
            self.voiceImageView.hidden = YES;
            break;
        case SUCCESS:
            HIDE_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            self.durationLabel.hidden = NO;
            self.voiceImageView.hidden = NO;
            break;
        default:
            break;
    }
}


- (void)updateMessageDownloadStatus {
    switch (self.messageModel.state) {
        case INPROGRESS:
            HIDE_STATUS_BUTTON;
            SHOW_INDICATOR_VIEW;
            break;
        case FAIL:
            SHOW_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            break;
        case SUCCESS:
            HIDE_STATUS_BUTTON;
            HIDE_INDICATOR_VIEW;
            break;

        default:
            break;
    }
}

+ (CGFloat)heightForModel:(ChatModel *)model {
    return AVATAR_HEIGHT + CONTENT_SUPER_BOTTOM + OFFSET_Y;
}


#pragma mark - 手势 -

- (UIView *)hitTestForTapGestureRecognizer:(CGPoint)point {
    CGPoint pointInView = [self.contentView convertPoint:point toView:self.bubbleImage];

    if ([self.bubbleImage pointInside:pointInView withEvent:nil]) {
        return self.bubbleImage;
    }
    
    return nil;
}

- (UIView *)hitTestForlongPressedGestureRecognizer:(CGPoint)point  {
    return [self hitTestForTapGestureRecognizer:point];
}


- (void)contentTouchBeganInView:(UIView *)view {
    self.bubbleImage.highlighted = YES;
}

- (void)contentTouchCancelled {
    self.bubbleImage.highlighted = NO;
}

- (void)contentEventTappedInView:(UIView *)view {
    self.bubbleImage.highlighted = NO;
    
    [self.delegate cellDidTapped:self];
}

- (void)contentLongPressedBeganInView:(UIView *)view {
    self.bubbleImage.highlighted = YES;
    [self showMenuControllerInRect:self.bubbleImage.bounds inView:self.bubbleImage];
}


#pragma mark - 菜单

- (NSArray<NSString *> *)menuItemNames {
    return @[ @"删除"];
}

- (NSArray<NSString *> *)menuItemActionNames {
    return @[@"deleteAction:"];
}

- (void)playAction:(id)sender {
    [self contentEventTappedInView:nil];
}

- (void)translateToWordsAction:(id)sender {
    
}



@end
