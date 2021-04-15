//
//  XHMessageTableViewController.h
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-4-24.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "XHMessageInputView.h"
#import "XHShareMenuView.h"
#import "XHEmotionManagerView.h"
#import "UIScrollView+XHkeyboardControl.h"

#import "QMUICommonTableViewController.h"

@protocol XHMessageTableViewControllerDelegate <NSObject>

@optional
/**
 *  协议回掉是否支持用户手动滚动
 *
 *  @return 返回YES or NO
 */
- (BOOL)shouldPreventScrollToBottomWhileUserScrolling;

/**
 *  判断是否支持下拉加载更多消息
 *
 *  @return 返回BOOL值，判定是否拥有这个功能
 */
- (BOOL)shouldLoadMoreMessagesScrollToTop;

/**
 *  下拉加载更多消息，只有在支持下拉加载更多消息的情况下才会调用。
 */
- (void)loadMoreMessagesScrollTotop;

@end

@interface InputTableViewController : QMUICommonTableViewController < XHMessageTableViewControllerDelegate, XHMessageInputViewDelegate, XHShareMenuViewDelegate>

@property (nonatomic, weak) id <XHMessageTableViewControllerDelegate> delegate;


/**
 *  第三方接入的功能，也包括系统自身的功能，比如拍照、发送地理位置
 */
@property (nonatomic, strong) NSArray *shareMenuItems;


/**
 *  用于显示发送消息类型控制的工具条，在底部
 */
@property (nonatomic, weak, readonly) XHMessageInputView *messageInputView;

/**
 *  替换键盘的位置的第三方功能控件
 */
@property (nonatomic, weak, readonly) XHShareMenuView *shareMenuView;


/**
 *  管理第三方gif表情的控件
 */
@property (nonatomic, weak, readonly) XHEmotionManagerView *emotionManagerView;

/**
 *  是否正在加载更多旧的消息数据
 */
@property (nonatomic, assign) BOOL loadingMoreMessage;

#pragma mark - Message View Controller Default stup
/**
 *  是否允许手势关闭键盘，默认是允许
 */
@property (nonatomic, assign) BOOL allowsPanToDismissKeyboard; // default is YES

/**
 *  是否允许发送语音
 */
@property (nonatomic, assign) BOOL allowsSendVoice; // default is YES

/**
 *  是否允许发送多媒体
 */
@property (nonatomic, assign) BOOL allowsSendMultiMedia; // default is YES

/**
 *  是否支持发送表情
 */
@property (nonatomic, assign) BOOL allowsSendFace; // default is YES


#pragma mark - DataSource Change
///**
// *  添加一条新的消息
// *
// *  @param addedMessage 添加的目标消息对象
// */
//- (void)addMessage:(XHMessage *)addedMessage;

/**
 *  删除一条已存在的消息
 *
 *  @param reomvedMessage 删除的目标消息对象
 */
//- (void)removeMessageAtIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Messages view controller
/**
 *  完成发送消息的函数
 */
- (void)finishSendMessageWithBubbleMessageType:(int)subType;

/**
 *  设置View、tableView的背景颜色
 *
 *  @param color 背景颜色
 */
- (void)setBackgroundColor:(UIColor *)color;

/**
 *  设置消息列表的背景图片
 *
 *  @param backgroundImage 目标背景图片
 */
- (void)setBackgroundImage:(UIImage *)backgroundImage;

/**
 *  是否滚动到底部
 *
 *  @param animated YES Or NO
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

/**
 *  滚动到哪一行
 *
 *  @param indexPath 目标行数变量
 *  @param position  UITableViewScrollPosition 整形常亮
 *  @param animated  是否滚动动画，YES or NO
 */
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
              atScrollPosition:(UITableViewScrollPosition)position
                      animated:(BOOL)animated;
/**
 *  隐藏键盘\表情\菜单
 */
- (void)layoutOtherMenuViewHiden:(BOOL)hide;



@end

