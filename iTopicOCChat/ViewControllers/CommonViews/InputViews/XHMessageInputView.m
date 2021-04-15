//
//  XHMessageInputView.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-24.
//


#define kButtonWidth 36

#import <QuartzCore/QuartzCore.h>
#import "XHMessageInputView.h"
#import "LLAudioManager.h"
#import "XHMacro.h"

@interface XHMessageInputView () <HolderTextViewDelegate>
{
    dispatch_block_t _block;
}
@property (nonatomic, weak, readwrite) HolderTextView *inputTextView;

@property (nonatomic, weak, readwrite) UIButton *voiceChangeButton;

@property (nonatomic, weak, readwrite) UIButton *multiMediaSendButton;

@property (nonatomic, weak, readwrite) UIButton *faceSendButton;

@property (nonatomic, weak, readwrite) UIButton *chatRecordBtn;

/**
 *  在切换语音和文本消息的时候，需要保存原本已经输入的文本，这样达到一个好的UE
 */
@property (nonatomic, copy) NSString *inputedText;


@property (nonatomic) BOOL recordPermissionGranted;
@property (nonatomic) CFTimeInterval touchDownTime;
@property (nonatomic, strong) UIEvent *recordEvent;

@end

@implementation XHMessageInputView

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (index) {
        case 0: {
            sender.selected = !sender.selected;
            if (sender.selected) {
                self.inputedText = self.inputTextView.text;
                self.inputTextView.text = @"";
                [self.inputTextView resignFirstResponder];
            } else {
                self.inputTextView.text = self.inputedText;
                self.inputedText = nil;
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.chatRecordBtn.alpha = sender.selected;
                self.inputTextView.alpha = !sender.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didChangeSendVoiceAction:)]) {
                [self.delegate didChangeSendVoiceAction:sender.selected];
            }
            
            break;
        }
        case 1: {
            sender.selected = !sender.selected;
            self.voiceChangeButton.selected = !sender.selected;
            
            if (!sender.selected) {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.chatRecordBtn.alpha = sender.selected;
                    self.inputTextView.alpha = !sender.selected;
                } completion:^(BOOL finished) {
                    
                }];
            } else {
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.chatRecordBtn.alpha = !sender.selected;
                    self.inputTextView.alpha = sender.selected;
                } completion:^(BOOL finished) {
                    
                }];
            }
            
            if ([self.delegate respondsToSelector:@selector(toggleEmotionInput:)]) {
                [self.delegate toggleEmotionInput:sender.selected];
            }
            break;
        }
        case 2: {
            self.faceSendButton.selected = NO;
            if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction)]) {
                [self.delegate didSelectedMultipleMediaAction];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - 录音

- (BOOL)recordButtonTouchEventEnded {
    UITouch *touch = [_recordEvent.allTouches anyObject];
    if (touch == nil || touch.phase == UITouchPhaseCancelled || touch.phase == UITouchPhaseEnded) {
        return YES;
    }
    
    return NO;
}

- (IBAction)recordButtonTouchDown:(id)sender {
    WEAKSELF;
    self.recordPermissionGranted = NO;
    __block BOOL firstUseMicrophone = NO;
    [[LLAudioManager sharedManager] requestRecordPermission:^(AVAudioSessionRecordPermission recordPermission) {
        if (recordPermission == AVAudioSessionRecordPermissionUndetermined) {
            firstUseMicrophone = YES;
        }else if (recordPermission == AVAudioSessionRecordPermissionGranted) {
        //第一次录音时，会请求麦克风权限。
        //1、用户抬离手指后同意访问麦克风，这种情况不继续录音，因为用户已经离开录音按钮了
        //2、用户保持手指按压录音按钮，用其他手指同意访问麦克风，则从获取授权的时间点开始录音
            if (!firstUseMicrophone || ![weakSelf recordButtonTouchEventEnded]) {
                weakSelf.recordPermissionGranted = YES;
                [weakSelf setRecordButtonBackground:YES];
                STRONGSELF;
                
                strongSelf->_touchDownTime = CACurrentMediaTime();
                if ([weakSelf.delegate respondsToSelector:@selector(voiceRecordingShouldStart)]) {
                    strongSelf->_block = dispatch_block_create(0, ^{
                        [weakSelf setRecordButtonTitle:YES];
                        [weakSelf.delegate voiceRecordingShouldStart];
                    });
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), strongSelf->_block);
                }
            }
        }
    }];
    
}

//松手直接进入这里
- (IBAction)recordButtonTouchUpinside:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    CFTimeInterval currentTime = CACurrentMediaTime();
    if (currentTime - _touchDownTime < MIN_RECORD_TIME_REQUIRED + 0.25) {
        self.chatRecordBtn.enabled = NO;
        if (_block && !dispatch_block_testcancel(_block))
            dispatch_block_cancel(_block);
        _block = nil;
        
        if ([self.delegate respondsToSelector:@selector(voiceRecordingTooShort)]) {
            [self.delegate voiceRecordingTooShort];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MIN_RECORD_TIME_REQUIRED * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.chatRecordBtn.enabled = YES;
            [self recordActionEnd];
        });
        
    }else {
        [self recordActionEnd];
        if ([self.delegate respondsToSelector:@selector(voicRecordingShouldFinish)]) {
            [self.delegate voicRecordingShouldFinish];
        }
    }

}

- (IBAction)recordButtonTouchUpoutside:(id)sender {
        NSLog(@"IBAction recordButtonTouchUpoutside");
    if (!self.recordPermissionGranted)
        return;
    
    [self recordActionEnd];
    
    if (_block && !dispatch_block_testcancel(_block))
        dispatch_block_cancel(_block);
    _block = nil;
    
    if ([self.delegate respondsToSelector:@selector(voiceRecordingShouldCancel)]) {
        [self.delegate voiceRecordingShouldCancel];
    }

}

- (IBAction)recordButtonTouchCancelled:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    [self recordButtonTouchUpinside:sender];
}

- (void)cancelRecordButtonTouchEvent {
    [self.chatRecordBtn cancelTrackingWithEvent:nil];
    [self recordActionEnd];
}

- (IBAction)recordButtonDragEnter:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    if ([self.delegate respondsToSelector:@selector(voiceRecordingDidDraginside)]) {
        [self.delegate voiceRecordingDidDraginside];
    }
}

- (IBAction)recordButtonDragExit:(id)sender {
    if (!self.recordPermissionGranted)
        return;
    
    if ([self.delegate respondsToSelector:@selector(voiceRecordingDidDragoutside)]) {
        [self.delegate voiceRecordingDidDragoutside];
    }
}

- (void)recordActionEnd {
    [self setRecordButtonTitle:NO];
    [self setRecordButtonBackground:NO];
    _recordEvent = nil;
}

- (void)setRecordButtonBackground:(BOOL)isRecording {
//    if (isRecording) {
//        _chatRecordBtn.backgroundColor = UIColorHexRGB(@"#C6C7CB");
//    }else {
//        _chatRecordBtn.backgroundColor = UIColorHexRGB(@"#F3F4F8");
//    }
}

- (void)setRecordButtonTitle:(BOOL)isRecording {
    if (isRecording) {
        [_chatRecordBtn setTitle:@"松开 结束" forState:UIControlStateNormal];
    }else {
        [_chatRecordBtn setTitle:@"按住 说话" forState:UIControlStateNormal];
    }
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.chatRecordBtn) {
        _recordEvent = event;
    }
    return view;
}


#pragma mark - layout subViews UI

- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, kButtonWidth)];
    if (image)
        [button setBackgroundImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupMessageInputViewBarWithStyle {
    // 配置输入工具条的样式和布局
    
    // 需要显示按钮的总宽度，包括间隔在内
    CGFloat allButtonWidth = 0.0;
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = (kInputViewHeight - kButtonWidth )/2;
    
    // 输入框
    CGFloat textViewLeftMargin = 6.0;
    
    // 每个按钮统一使用的frame变量
    CGRect buttonFrame;
    
    // 按钮对象消息
    UIButton *button;
    
    // 允许发送语音
    if (self.allowsSendVoice) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"chat_icon_voice"] HLImage:nil];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_icon_keyboard_black_l_normal"] forState:UIControlStateSelected];
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(horizontalPadding, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetMaxX(buttonFrame);
        textViewLeftMargin += CGRectGetMaxX(buttonFrame);
        
        self.voiceChangeButton = button;
    }
    
    // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要！
    if (self.allowsSendMultiMedia) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"chat_icon_more_black_l_normal"] HLImage:nil];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2;
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        
        self.multiMediaSendButton = button;
    }
    
    // 允许发送表情
    if (self.allowsSendFace) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"chat_icon_emoji_black_l_normal"] HLImage:nil];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"chat_icon_keyboard_black_l_normal"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        buttonFrame = button.frame;
        if (self.allowsSendMultiMedia) {
            buttonFrame.origin = CGPointMake(CGRectGetMinX(self.multiMediaSendButton.frame) - CGRectGetWidth(buttonFrame) - horizontalPadding, verticalPadding);
            allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 1.5;
        } else {
            buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
            allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        }
        button.frame = buttonFrame;
        [self addSubview:button];
        
        self.faceSendButton = button;
    }
    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : (textViewLeftMargin * 2));
    CGFloat height = [XHMessageInputView textViewLineHeight];
    
    // 初始化输入框
    HolderTextView *textView = [[HolderTextView alloc] initWithFrame:CGRectZero];
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.font = [UIFont systemFontOfSize:17];
    textView.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    textView.returnKeyType = UIReturnKeySend;
    textView.scrollsToTop = NO;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.myDelegate = self;
    textView.layer.cornerRadius = 6.0f;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    [self addSubview:textView];
	self.inputTextView = textView;
    
    _inputTextView.frame = CGRectMake(textViewLeftMargin, (kInputViewHeight - height)/2, width, height);
    
    // 如果是可以发送语言的，那就需要一个按钮录音的按钮，事件可以在外部添加
    if (self.allowsSendVoice) {
//        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
        button = [self createButtonWithImage:[UIImage imageNamed:@"white_input_btn"] HLImage:[UIImage imageNamed:@"white_input_press_btn"]];
       
        [button setTitle:NSLocalizedStringFromTable(@"HoldToTalk", @"MessageDisplayKitString", nil) forState:UIControlStateNormal];
//        [button setTitle:NSLocalizedStringFromTable(@"ReleaseToSend", @"MessageDisplayKitString", nil)  forState:UIControlStateHighlighted];
//        buttonFrame = CGRectMake(textViewLeftMargin-5, 0, width+10, self.frame.size.height);
        button.frame = CGRectMake(textViewLeftMargin, (kInputViewHeight - height)/2, width, height);
        button.alpha = self.voiceChangeButton.selected;
        [button addTarget:self action:@selector(recordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(recordButtonTouchUpoutside:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(recordButtonTouchUpinside:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(recordButtonDragExit:) forControlEvents:UIControlEventTouchDragExit];
        [button addTarget:self action:@selector(recordButtonDragEnter:) forControlEvents:UIControlEventTouchDragEnter];
        [button addTarget:self action:@selector(recordButtonTouchCancelled:) forControlEvents:UIControlEventTouchCancel];
        [self addSubview:button];
        self.chatRecordBtn = button;
    }
    
    if (@available(iOS 11.0, *)) {
        self.layer.borderColor = [UIColor colorNamed:@"border223"].CGColor;
        self.backgroundColor = [UIColor colorNamed:@"input_gray_bg"];
        _inputTextView.textColor = [UIColor colorNamed:@"black_gray"];
        _inputTextView.backgroundColor = [UIColor colorNamed:@"input"];
        [self.chatRecordBtn setTitleColor:[UIColor colorNamed:@"black_white"] forState:UIControlStateNormal];
    } else {
        self.layer.borderColor = RGBCOLOR(223, 223, 223).CGColor;
        self.backgroundColor = RGBCOLOR(242, 242, 242);
        _inputTextView.textColor = [UIColor blackColor];
        _inputTextView.backgroundColor = [UIColor whiteColor];
        [self.chatRecordBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    self.layer.borderWidth = 0.6f;
}

//dq 2016-07-07 切换到红色框，为了做阅后即焚
- (void)swipBackgroundImage:(BOOL)toRedImage{

}

#pragma mark - Life cycle

- (void)setup {
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
    
    // 默认设置
    _allowsSendVoice = YES;
    _allowsSendFace = YES;
    _allowsSendMultiMedia = YES;
}

- (void)awakeFromNib {
    [self setup];
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.inputedText = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _voiceChangeButton = nil;
    _multiMediaSendButton = nil;
    _faceSendButton = nil;
    _chatRecordBtn = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupMessageInputViewBarWithStyle];
    }
}

#pragma mark - Message input view
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;

    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
}

+ (CGFloat)textViewLineHeight {
   return kInputViewHeight - 18;
}

+ (CGFloat)maxHeight {
    return 4 * [XHMessageInputView textViewLineHeight];
}

#pragma mark - Text view delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    self.faceSendButton.selected = NO;
    self.voiceChangeButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:textView.text];
        }
        return NO;
    }
    return YES;
}

@end
