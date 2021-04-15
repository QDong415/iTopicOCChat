//
//  XHMessageTableViewController.m
//  MessageDisplayExample
//
//  Copyright (c) 2014年 Q_Dong  QQ:285275534 All rights reserved.
//

#import "FaceManager.h"
#import "InputTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface InputTableViewController ()<XHEmotionManagerViewDataSource,XHEmotionManagerViewDelegate>

/**
 *  判断是否用户手指滚动
 */
@property (nonatomic, assign) BOOL isUserScrolling;

/**
 *  记录旧的textView contentSize Heigth
 */
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;

/**
 *  记录键盘的高度，为了适配iPad和iPhone
 */
@property (nonatomic, assign) CGFloat keyboardViewHeight;

@property (nonatomic, assign) XHInputViewType textViewInputViewType;

@property (nonatomic, weak) XHMessageInputView *messageInputView;
@property (nonatomic, weak) XHShareMenuView *shareMenuView;
@property (nonatomic, weak) XHEmotionManagerView *emotionManagerView;

@property (nonatomic, strong) UIView *headerContainerView;
@property (nonatomic, assign) float safeAreaInsetsBottom;

/**
 *  判断是不是超出了录音最大时长
 */
@property (nonatomic) BOOL isMaxTimeStop;

#pragma mark - DataSource Change
/**
 *  改变数据源需要的子线程
 *
 *  @param queue 子线程执行完成的回调block
 */
- (void)exChangeMessageDataSourceQueue:(void (^)())queue;

/**
 *  执行块代码在主线程
 *
 *  @param queue 主线程执行完成回调block
 */
- (void)exMainQueue:(void (^)())queue;

#pragma mark - Previte Method
/**
 *  判断是否允许滚动
 *
 *  @return 返回判断结果
 */
- (BOOL)shouldAllowScroll;

#pragma mark - Life Cycle
/**
 *  配置默认参数
 */
- (void)setup;



#pragma mark - UITextView Helper Method
/**
 *  获取某个UITextView对象的content高度
 *
 *  @param textView 被获取的textView对象
 *
 *  @return 返回高度
 */
- (CGFloat)getTextViewContentH:(UITextView *)textView;

#pragma mark - Layout Message Input View Helper Method
/**
 *  动态改变TextView的高度
 *
 *  @param textView 被改变的textView对象
 */
- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView;

#pragma mark - Scroll Message TableView Helper Method
/**
 *  根据bottom的数值配置消息列表的内部布局变化
 *
 *  @param bottom 底部的空缺高度
 */
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom;

/**
 *  根据底部高度获取UIEdgeInsets常量
 *
 *  @param bottom 底部高度
 *
 *  @return 返回UIEdgeInsets常量
 */
- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom;

#pragma mark - Message Send helper Method
/**
 *  根据文本开始发送文本消息
 *
 *  @param text 目标文本
 */
- (void)didSendMessageWithText:(NSString *)text;
/**
 *  根据图片开始发送图片消息
 *
 *  @param photo 目标图片
 */
- (void)didSendMessageWithPhoto:(UIImage *)photo;
/**
 *  根据录音路径开始发送语音消息
 *
 *  @param voicePath        目标语音路径
 *  @param voiceDuration    目标语音时长
 */
- (void)didSendMessageWithVoice:(NSString *)voicePath voiceDuration:(NSString*)voiceDuration;
/**
 *  根据第三方gif表情路径开始发送表情消息
 *
 *  @param emotionPath 目标gif表情路径
 */
- (void)didSendEmotionMessageWithEmotionPath:(NSString *)emotionPath;

#pragma mark - Other Menu View Frame Helper Mehtod
/**
 *  根据显示或隐藏的需求对所有第三方Menu进行管理
 *
 *  @param hide 需求条件
 */
- (void)layoutOtherMenuViewHiden:(BOOL)hide;

@end

@implementation InputTableViewController
{
    BOOL isPulling;
}

#pragma mark - DataSource Change
- (void)exChangeMessageDataSourceQueue:(void (^)())queue {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), queue);
}

- (void)exMainQueue:(void (^)())queue {
    dispatch_async(dispatch_get_main_queue(), queue);
}

#pragma mark - Propertys
- (UIView *)headerContainerView {
    if (!_headerContainerView) {
        _headerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        UIActivityIndicatorView *loadMoreActivityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadMoreActivityIndicatorView.center = CGPointMake(CGRectGetWidth(_headerContainerView.bounds) / 2.0, CGRectGetHeight(_headerContainerView.bounds) / 2.0);
        
        [_headerContainerView addSubview:loadMoreActivityIndicatorView];
    }
    return _headerContainerView;
}

- (XHShareMenuView *)shareMenuView {
    if (!_shareMenuView) {
        XHShareMenuView *shareMenuView = [[XHShareMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), SCREEN_WIDTH, self.keyboardViewHeight)];
        shareMenuView.delegate = self;
        if (@available(iOS 11.0, *)) {
            shareMenuView.backgroundColor = [UIColor colorNamed:@"input_extend_bg"];
        } else {
            shareMenuView.backgroundColor = RGBCOLOR(246,246,246);
        }
        shareMenuView.alpha = 0.0;
        shareMenuView.shareMenuItems = self.shareMenuItems;
        [self.view addSubview:shareMenuView];
        _shareMenuView = shareMenuView;
    }
    [self.view bringSubviewToFront:_shareMenuView];
    return _shareMenuView;
}

- (XHEmotionManagerView *)emotionManagerView {
    if (!_emotionManagerView) {
        XHEmotionManagerView *emotionManagerView = [[XHEmotionManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), self.keyboardViewHeight)];
        emotionManagerView.delegate = self;
        emotionManagerView.dataSource = self;
        if (@available(iOS 11.0, *)) {
            emotionManagerView.backgroundColor = [UIColor colorNamed:@"input_extend_bg"];
        } else {
            emotionManagerView.backgroundColor = RGBCOLOR(246,246,246);
        }
        emotionManagerView.alpha = 0.0;
        [self.view addSubview:emotionManagerView];
        _emotionManagerView = emotionManagerView;
    }
    [self.view bringSubviewToFront:_emotionManagerView];
    return _emotionManagerView;
}


#pragma mark - XHEmotionManagerView Delegate
/**
 *  表情被点击的回调事件
 *
 *  @param keyString 根据选择的表情，匹配出的显示的 [微笑]
 *  @param imageName 表情图片id ，Expression_1
 *  @param isGifEmotion 是不是gif大表情
 */
- (void)didSelectedEmotionKey:(NSString *)keyString emotionImageName:(NSString *)imageName isGifEmotion:(BOOL)isGifEmotion
{
    if(isGifEmotion){
        [self clickSendTextAciton:keyString isGIFEmotion:YES];
    } else {
        [XHEmotionManagerView selectedFaceView:keyString isDelete:NO withTextView:self.messageInputView.inputTextView];
    }
}

/**
 * 点击删除按钮
 */
- (void)didSelectedDeleted
{
    [XHEmotionManagerView selectedFaceView:nil isDelete:YES withTextView:self.messageInputView.inputTextView];
}

/**
 * 点击发送按钮
 */
- (void)didSelectedSend
{
    NSString *chatText = self.messageInputView.inputTextView.text;
    if (chatText.length > 0) {
        [self clickSendTextAciton:chatText];
    }
}

#pragma mark - XHEmotionManagerView DataSource
- (NSArray *)emotionManagersAtManager {
    FaceManager *faceManager = FACEMANAGER;
    return faceManager.emotionManagerArray;
}

- (void)setBackgroundColor:(UIColor *)color {
    self.view.backgroundColor = color;
    self.tableView.backgroundColor = color;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    self.tableView.backgroundView = nil;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
}

/** 键盘弹出，或者表情弹出都回调用这个方法，默认是scrollToBottomAnimated滚到底部
 * 子类可以重新该方法让他不滚到底部
 */
- (void)keyboardEmojiDidShowing{
    [self scrollToBottomAnimated:NO];
}

/** 输入框输入文字折行导致的输入库高度变化，会回调用这个方法，默认是scrollToBottomAnimated滚到底部
 * 子类可以重新该方法让他不滚到底部
 */
- (void)inputTextViewHeightChanged{
    [self scrollToBottomAnimated:NO];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    if (![self shouldAllowScroll])
        return;
    
    NSInteger rows = [self.tableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)position
                      animated:(BOOL)animated {
    if (![self shouldAllowScroll])
        return;
    
    [self.tableView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:position
                                         animated:animated];
}

#pragma mark - Previte Method
- (BOOL)shouldAllowScroll {
    if (self.isUserScrolling) {
        if ([self.delegate respondsToSelector:@selector(shouldPreventScrollToBottomWhileUserScrolling)]
            && [self.delegate shouldPreventScrollToBottomWhileUserScrolling]) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - Life Cycle
- (void)setup {
    // iPhone or iPad keyboard view height set here.
    self.keyboardViewHeight = (kIsiPad ? 264 : 216);
    _allowsPanToDismissKeyboard = NO;
    _allowsSendVoice = YES;
    _allowsSendMultiMedia = YES;
    _allowsSendFace = YES;
    
    self.delegate = self;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
    [super awakeFromNib];
}

- (void)initilzer {
    // 默认设置用户滚动为NO
    _isUserScrolling = NO;

//        self.fd_interactivePopDisabled = YES;
    
    // 设置Message TableView 的bottom edg
    CGFloat inputViewHeight = kInputViewHeight;
    [self setTableViewInsetsWithBottomValue:inputViewHeight];
    
    BOOL shouldLoadMoreMessagesScrollToTop = NO;
    if ([self.delegate respondsToSelector:@selector(shouldLoadMoreMessagesScrollToTop)]) {
        shouldLoadMoreMessagesScrollToTop = [self.delegate shouldLoadMoreMessagesScrollToTop];
    }
    if (shouldLoadMoreMessagesScrollToTop) {
        self.tableView.tableHeaderView = self.headerContainerView;
    }
    
    if (@available(iOS 11.0, *)) {
        _safeAreaInsetsBottom = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        if(_safeAreaInsetsBottom > 0){
            UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - _safeAreaInsetsBottom , SCREEN_WIDTH, _safeAreaInsetsBottom)];
            if (@available(iOS 11.0, *)) {
                bottomView.backgroundColor = [UIColor colorNamed:@"input_gray_bg"];
            } else {
                bottomView.backgroundColor = RGBCOLOR(246,246,246);
            }
            [self.view addSubview:bottomView];
            [self.view bringSubviewToFront:bottomView];
        }
    }
    
//    self.fd_interactivePopMaxAllowedInitialDistanceToBottomEdge = _safeAreaInsetsBottom + kInputViewHeight;

    
    // 输入工具条的frame
    CGRect inputFrame = CGRectMake(0.0f,
                                   self.view.frame.size.height - inputViewHeight - _safeAreaInsetsBottom ,
                                   self.view.frame.size.width,
                                   inputViewHeight);
    
    WEAKSELF
    if (self.allowsPanToDismissKeyboard) {
        // 控制输入工具条的位置块
        void (^AnimationForMessageInputViewAtPoint)(CGPoint point) = ^(CGPoint point) {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            CGPoint keyboardOrigin = [weakSelf.view convertPoint:point fromView:nil];
            inputViewFrame.origin.y = keyboardOrigin.y - inputViewFrame.size.height - weakSelf.safeAreaInsetsBottom;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
        
        weakSelf.tableView.keyboardDidScrollToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        weakSelf.tableView.keyboardWillSnapBackToPoint = ^(CGPoint point) {
            if (weakSelf.textViewInputViewType == XHInputViewTypeText)
                AnimationForMessageInputViewAtPoint(point);
        };
        
        weakSelf.tableView.keyboardWillBeDismissed = ^() {
            CGRect inputViewFrame = weakSelf.messageInputView.frame;
            inputViewFrame.origin.y = weakSelf.view.bounds.size.height - inputViewFrame.size.height - weakSelf.safeAreaInsetsBottom;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
    }
    
    // block回调键盘通知
    self.tableView.keyboardWillChange = ^(CGRect keyboardRect, UIViewAnimationOptions options, double duration, BOOL showKeyboard) {
        if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
            [UIView animateWithDuration:duration
                                  delay:0.0
                                options:options
                             animations:^{
                                 CGFloat keyboardY = [weakSelf.view convertRect:keyboardRect fromView:nil].origin.y;
                                 CGRect inputViewFrame = weakSelf.messageInputView.frame;
                                 CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height ;
                                 // for ipad modal form presentations
                                 CGFloat messageViewFrameBottom = weakSelf.view.frame.size.height - inputViewFrame.size.height - weakSelf.safeAreaInsetsBottom;
                                 if (inputViewFrameY > messageViewFrameBottom)
                                     inputViewFrameY = messageViewFrameBottom;
                                 
                                 weakSelf.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                                              inputViewFrameY,
                                                                              inputViewFrame.size.width,
                                                                              inputViewFrame.size.height);
                                 [weakSelf setTableViewInsetsWithBottomValue:weakSelf.view.frame.size.height
                                  - weakSelf.messageInputView.frame.origin.y - weakSelf.safeAreaInsetsBottom];
                                 if (showKeyboard){
                                     [weakSelf keyboardEmojiDidShowing];
                                 }
                             }
                             completion:nil];
        }
    };
    
    self.tableView.keyboardDidChange = ^(BOOL didShowed) {
        if ([weakSelf.messageInputView.inputTextView isFirstResponder]) {
            if (didShowed) {
                if (weakSelf.textViewInputViewType == XHInputViewTypeText) {
                    weakSelf.shareMenuView.alpha = 0.0;
                    weakSelf.emotionManagerView.alpha = 0.0;
                }
            }
        }
    };
    
    self.tableView.keyboardDidHide = ^() {
        [weakSelf.messageInputView.inputTextView resignFirstResponder];
    };
    
    // 初始化输入工具条
    XHMessageInputView *inputView = [[XHMessageInputView alloc] initWithFrame:inputFrame];
    inputView.allowsSendFace = self.allowsSendFace;
    inputView.allowsSendVoice = self.allowsSendVoice;
    inputView.allowsSendMultiMedia = self.allowsSendMultiMedia;
    inputView.delegate = self;
    [self.view addSubview:inputView];
    [self.view bringSubviewToFront:inputView];
    _messageInputView = inputView;
    
    self.previousTextViewContentHeight = [self getTextViewContentH:inputView.inputTextView];
    
    // 设置手势滑动，默认添加一个bar的高度值
    self.tableView.messageInputBarHeight = CGRectGetHeight(_messageInputView.bounds);
    
    [self.messageInputView.inputTextView addObserver:self
                                          forKeyPath:@"contentSize"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
    return  UIRectEdgeBottom;//该参数表示底部，根据需要修改
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 设置键盘通知或者手势控制键盘消失
    [self.tableView setupPanGestureControlKeyboardHide:self.allowsPanToDismissKeyboard];
    
    // dq 2021-02-18 原本代码在这里addObserver，但是友盟后台有崩溃日志，这里代码移到viewDidLoad了
//    [self.messageInputView.inputTextView addObserver:self
//                                          forKeyPath:@"contentSize"
//                                             options:NSKeyValueObservingOptionNew
//                                             context:nil];
    
    [self.messageInputView.inputTextView setEditable:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.textViewInputViewType != XHInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
    
    // remove键盘通知或者手势
    [self.tableView disSetupPanGestureControlKeyboardHide:self.allowsPanToDismissKeyboard];
    
    // remove KVO
//    [self.messageInputView.inputTextView removeObserver:self forKeyPath:@"contentSize"];
    [self.messageInputView.inputTextView setEditable:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initilzer];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    _messageInputView = nil;
    [self.messageInputView.inputTextView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - UITextView Helper Method

- (CGFloat)getTextViewContentH:(UITextView *)textView {
    return ceilf([textView sizeThatFits:textView.frame.size].height);
}


#pragma mark - Layout Message Input View Helper Method

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = [XHMessageInputView maxHeight];
    
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - _previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        WEAKSELF
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [weakSelf setTableViewInsetsWithBottomValue:weakSelf.tableView.contentInset.bottom + changeInHeight];
                             
                             [weakSelf inputTextViewHeightChanged];
                             
                             if (isShrinking) {
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [weakSelf.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = weakSelf.messageInputView.frame;
                             weakSelf.messageInputView.frame = CGRectMake(0.0f,
                                                                          inputViewFrame.origin.y - changeInHeight,//dqdebug
                                                                          inputViewFrame.size.width,
                                                                          inputViewFrame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 [weakSelf.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
  
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
//    self.tableViewInitialContentInset = insets;
//    self.tableViewInitialScrollIndicatorInsets = insets;
    
    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    insets.top = [self tableViewContentInset];
    insets.bottom = bottom;
    return insets;
}

- (int)tableViewContentInset
{
    return 0;
}

#pragma mark - Other Menu View Frame Helper Mehtod
//表情\menu切换也会调用
- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    [self.messageInputView.inputTextView resignFirstResponder];
    //初始化一下表情view。如果在下面的动画代码里才初始化，会导致从左下角飘移进入
    [self emotionManagerView];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.messageInputView.frame;
        __block CGRect otherMenuViewFrame;
        WEAKSELF
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(weakSelf.view.bounds) - CGRectGetHeight(inputViewFrame)  - weakSelf.safeAreaInsetsBottom) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame))) ;
            weakSelf.messageInputView.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = weakSelf.emotionManagerView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(weakSelf.view.frame) : (CGRectGetHeight(weakSelf.view.frame) - CGRectGetHeight(otherMenuViewFrame)))  - weakSelf.safeAreaInsetsBottom;
            weakSelf.emotionManagerView.alpha = !hide;
            weakSelf.emotionManagerView.frame = otherMenuViewFrame;
        };
        
        void (^ShareMenuViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = weakSelf.shareMenuView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(weakSelf.view.frame) : (CGRectGetHeight(weakSelf.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            weakSelf.shareMenuView.alpha = !hide;
            weakSelf.shareMenuView.frame = otherMenuViewFrame;
        };
        
        if (hide) {
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (self.textViewInputViewType) {
                case XHInputViewTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    ShareMenuViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [self setTableViewInsetsWithBottomValue:self.view.frame.size.height
         - self.messageInputView.frame.origin.y - self.safeAreaInsetsBottom];
        
        [self keyboardEmojiDidShowing];
    } completion:^(BOOL finished) {
        if (hide) {
            self.textViewInputViewType = XHInputViewTypeNormal;
        }
    }];
}

#pragma mark - XHMessageInputView Delegate

- (void)inputTextViewWillBeginEditing:(HolderTextView *)messageInputTextView {
    self.textViewInputViewType = XHInputViewTypeText;
}

- (void)inputTextViewDidBeginEditing:(HolderTextView *)messageInputTextView {
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = [self getTextViewContentH:messageInputTextView];
}

- (void)didChangeSendVoiceAction:(BOOL)changed {
    if (changed) {
        if (self.textViewInputViewType == XHInputViewTypeText)
            return;
        // 在这之前，textViewInputViewType已经不是XHTextViewTextInputType
        [self layoutOtherMenuViewHiden:YES];
    }
}

- (void)didSendTextAction:(NSString *)text {
    [self clickSendTextAciton:text];
}

//点击+按钮
- (void)didSelectedMultipleMediaAction {
    self.textViewInputViewType = XHInputViewTypeShareMenu;
    [self layoutOtherMenuViewHiden:NO];
}

- (void)toggleEmotionInput:(BOOL)sendFace {
    if (sendFace) {
        self.textViewInputViewType = XHInputViewTypeEmotion;
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
}

- (void)didStartRecordingVoiceAction {
}

- (void)didCancelRecordingVoiceAction {
}

- (void)didFinishRecoingVoiceAction {
}

- (void)didDragOutsideAction {
}

- (void)didDragInsideAction {
}

#pragma mark - XHShareMenuView Delegate
//点击menu菜单中的一项
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index {
    DLog(@"title : %@   index:%ld", shareMenuItem.title, (long)index);
    
}

#pragma mark - DXFaceDelegate

- (void)selectedFacialView:(NSString *)str isDelete:(BOOL)isDelete
{
    //    [XHEmotionManagerView selectedFaceView:str isDelete:isDelete withTextView:self.messageInputView.inputTextView];
}

//发消息
- (void)sendFace
{
    NSString *chatText = self.messageInputView.inputTextView.text;
    if (chatText.length > 0) {
        [self clickSendTextAciton:chatText];
    }
}

/**
 * 点击发送按钮，子类一定要重写该方法
 */
-(void)clickSendTextAciton:(NSString *)textMessage isGIFEmotion:(BOOL)isGIFEmotion
{
    
}

//点击发送按钮
-(void)clickSendTextAciton:(NSString *)textMessage
{
    
}

#pragma mark - Messages View Controller

- (void)finishSendMessageWithBubbleMessageType:(int)subType {
    [self.messageInputView.inputTextView setText:nil];
    self.messageInputView.inputTextView.enablesReturnKeyAutomatically = NO;
    WEAKSELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        weakSelf.messageInputView.inputTextView.enablesReturnKeyAutomatically = YES;
        [weakSelf.messageInputView.inputTextView reloadInputViews];
    });
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableView.tableHeaderView && !_loadingMoreMessage && !isPulling && (scrollView.isDragging || scrollView.isDecelerating) && scrollView.contentOffset.y <= 20 - scrollView.contentInset.top && [self.delegate respondsToSelector:@selector(shouldLoadMoreMessagesScrollToTop)]) {
        isPulling = YES;
        UIActivityIndicatorView *indicator = self.headerContainerView.subviews[0];
        if (![indicator isAnimating]) {
            [indicator startAnimating];
        }
    }
}



- (void)pullToRefresh {
    isPulling = NO;
    if ([self.delegate respondsToSelector:@selector(loadMoreMessagesScrollTotop)]) {
        [self.delegate loadMoreMessagesScrollTotop];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!_loadingMoreMessage && isPulling) {
        [self pullToRefresh];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isUserScrolling = NO;
    if (isPulling) {
        [self pullToRefresh];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isUserScrolling = YES;
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    
    if (self.textViewInputViewType != XHInputViewTypeNormal) {
        [self layoutOtherMenuViewHiden:YES];
    }
}

#pragma mark - XHMessageTableViewController Delegate

- (BOOL)shouldPreventScrollToBottomWhileUserScrolling {
    return YES;
}



#pragma mark - Key-value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.messageInputView.inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

@end

