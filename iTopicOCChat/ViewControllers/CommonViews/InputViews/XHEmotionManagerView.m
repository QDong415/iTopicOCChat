//
//  XHEmotionManagerView.m
//  MessageDisplayExample
//
//  Created by HUAJIE-1 on 14-5-3.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHEmotionManagerView.h"

#import "XHEmotionSectionBar.h"

#import "HolderTextView.h"
#import "FacialView.h"

@interface XHEmotionManagerView () <UIScrollViewDelegate, XHEmotionSectionBarDelegate, FacialViewDelegate>

/**
 *  最大的UIScrollView
 */
@property (nonatomic, weak) UIScrollView *emotionScrollView;

/**
 *  显示页码的控件
 */
@property (nonatomic, weak) UIPageControl *emotionPageControl;

/**
 *  管理多种类别gif表情的滚动试图
 */
@property (nonatomic, weak) XHEmotionSectionBar *emotionSectionBar;

/**
 *  当前选择了哪类gif表情标识
 */
@property (nonatomic, assign) NSInteger selectedIndex;

/**
 *  配置默认控件
 */
- (void)setup;

/**
 *  表情数据源，从dataSource获取
 */
@property (nonatomic, strong)  NSArray *emotionManagers;

@end

@implementation XHEmotionManagerView

- (void)reloadData {
  
    self.emotionManagers = [self.dataSource emotionManagersAtManager];
    if (!self.emotionManagers) {
          return ;
    }
    self.emotionSectionBar.emotionManagers = _emotionManagers;
    self.emotionSectionBar.hideSendButton = self.hideSendButton;
    [self.emotionSectionBar reloadData];
    
    
    //reloadData 最外层的表情ScrollView
    [self.emotionScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    //最外层的表情ScrollView一共有几页
    int totalPageCount = 0;
    
  
    for (int i = 0; i<[_emotionManagers count]; i++) {
        XHEmotionManager *emotionManager = _emotionManagers[i];

        //当前类型的表情 一共有几页
        int emotionPageCount = emotionManager.emotionPageCount;
        
        if (i == 0) {
            self.emotionPageControl.numberOfPages = emotionPageCount;
        }
        
        for (int j = 0; j < emotionPageCount; j++) {
            FacialView *_facialView = [[FacialView alloc]initWithFrame:CGRectMake((totalPageCount + j) * CGRectGetWidth(self.bounds),0.0f,CGRectGetWidth(self.bounds),CGRectGetHeight(self.emotionScrollView.bounds))];

            [_facialView loadEmotionBoard:emotionManager inPage:j];
            _facialView.tag = i;
            _facialView.delegate = self;
            [self.emotionScrollView addSubview:_facialView];
        }
        
        totalPageCount += emotionPageCount;
        
    }

    [self.emotionScrollView setContentSize:CGSizeMake(CGRectGetWidth(self.emotionScrollView.frame)*totalPageCount,CGRectGetHeight(self.emotionScrollView.frame))];

}

#pragma mark - Life cycle

- (void)setup {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if (!_emotionScrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0f,kXHEmotionSrollViewMarginTop,CGRectGetWidth(self.bounds),CGRectGetHeight(self.bounds)-kXHEmotionPageControlHeight - kXHEmotionSectionBarHeight - kXHEmotionSrollViewMarginTop)];
        scrollView.delegate = self;
        [self addSubview:scrollView];
        [scrollView setPagingEnabled:YES];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        self.emotionScrollView = scrollView;
    }

    if (!_emotionPageControl) {
        UIPageControl *emotionPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emotionScrollView.frame), CGRectGetWidth(self.bounds), kXHEmotionPageControlHeight)];
        emotionPageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.471 alpha:1.000];
        emotionPageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.678 alpha:1.000];
        emotionPageControl.hidesForSinglePage = YES;
        emotionPageControl.defersCurrentPageDisplay = YES;
        [self addSubview:emotionPageControl];
        self.emotionPageControl = emotionPageControl;
    }
    
    if (!_emotionSectionBar) {
        XHEmotionSectionBar *emotionSectionBar = [[XHEmotionSectionBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emotionPageControl.frame), CGRectGetWidth(self.bounds), kXHEmotionSectionBarHeight) hideSendButton:self.hideSendButton];
        emotionSectionBar.delegate = self;
        emotionSectionBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        emotionSectionBar.currentIndex = 0;
        [self addSubview:emotionSectionBar];
        self.emotionSectionBar = emotionSectionBar;
    }
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.emotionPageControl.frame), CGRectGetWidth(self.bounds), 0.5)];
    [self addSubview:lineView];
    
    if (@available(iOS 11.0, *)) {
        lineView.backgroundColor = [UIColor colorNamed:@"border223"];
        self.emotionSectionBar.backgroundColor = [UIColor colorNamed:@"input_gray_bg"];
    } else {
        lineView.backgroundColor = RGBCOLOR(223, 223, 223);
        self.emotionSectionBar.backgroundColor = COLOR_BACKGROUND_RGB;
    }
}

- (void)awakeFromNib {
    [self setup];
    [super awakeFromNib];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.emotionPageControl = nil;
    self.emotionSectionBar = nil;
    self.emotionScrollView.delegate = nil;
//    self.emotionScrollView.dataSource = nil;
    self.emotionScrollView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reloadData];
    }
}


#pragma mark - FacialViewDelegate
/**
 * 选择了一个面板上的小表情， :
 * indexInManager: 这个表情在XHEmotionManager的位置
 * managerIndex: 这个表情所属的XHEmotionManager 在整个表情managers array的位置
 */
-(void)selectedEmotionAtIndex:(int)indexInManager inManagerSection:(int)managerIndex
{
    XHEmotionManager *emotionManager = _emotionManagers[managerIndex];
    
    NSString *emotionImageName = emotionManager.emotionImageNames[indexInManager];
    
    if (emotionManager.isGifEmoji) {
        
        NSString *gifImageName = nil;//dqdebug
        
        //点击的是gif表情，那么发出去的是动态图gif的名字，比如tuzki8，cell显示的时候直接显示gif
        [_delegate didSelectedEmotionKey:gifImageName emotionImageName:emotionImageName isGifEmotion:emotionManager.isGifEmoji];
        
        
    }else{
         //点击的是小表情，那么发出去的是匹配出的汉字key，比如[微笑]，cell显示时候，再匹配出图片

        NSDictionary *plistDic = [FACEMANAGER emojiDictionary] ;
        
        for (int j = 0; j<[[plistDic allKeys]count]; j++)
        {
            if ([[plistDic objectForKey:[[plistDic allKeys]objectAtIndex:j]]
                 isEqualToString:emotionImageName])
            {
                NSString *faceKey = [[plistDic allKeys]objectAtIndex:j];
                [_delegate didSelectedEmotionKey:faceKey emotionImageName:emotionImageName isGifEmotion:emotionManager.isGifEmoji];
                return ;
            }
        }
    }
 
   
}

//选择了一个面板上的删除
-(void)selectedDelete
{
    [_delegate didSelectedDeleted];
}


#pragma mark - XHEmotionSectionBar Delegate
//选择了底部表情bar
- (void)didSelectedEmotionManager:(XHEmotionManager *)emotionManager atSection:(NSInteger)section {
    
    self.emotionSectionBar.currentIndex = (int)section;
    self.emotionPageControl.currentPage = 0;
    
    //最外层的表情ScrollView一共有几页
    int totalPageCount = 0;
    
    for (int i = 0; i<[_emotionManagers count]; i++) {
        XHEmotionManager *emotionManager = _emotionManagers[i];
        
        //当前类型的表情 一共有几页
        int emotionPageCount = emotionManager.emotionPageCount;
        
        if (self.emotionSectionBar.currentIndex == i) {
            //找到了这个表情所在的位置
            [self.emotionScrollView setContentOffset:CGPointMake(totalPageCount* CGRectGetWidth(self.bounds), 0) animated:NO];
            
            self.emotionPageControl.numberOfPages = emotionPageCount;
            
            break;
        }
        
        totalPageCount += emotionPageCount;
    }
}

/**
 * 点击发送按钮
 */
- (void)didSelectedSend
{
    if (_delegate) {
        [_delegate didSelectedSend];
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    
    NSArray *emotionManagers = _emotionManagers;
    
    //最外层的表情ScrollView一共有几页
    int totalPageCount = 0;
    
    for (int i = 0; i<[emotionManagers count]; i++) {
        XHEmotionManager *emotionManager = emotionManagers[i];

        //当前类型的表情 一共有几页
        int emotionPageCount = emotionManager.emotionPageCount;
        
        for (int j = 0; j < emotionPageCount; j++) {
            
            if (currentPage == totalPageCount + j) {
                self.emotionSectionBar.currentIndex = i;
                
                self.emotionPageControl.numberOfPages = emotionPageCount;
                
                self.emotionPageControl.currentPage = j;
                
                return;
            }
          
        }
        
        totalPageCount += emotionPageCount;
    }
}

+ (void)selectedFaceView:(NSString *)str isDelete:(BOOL)isDelete withTextView:(UITextView *)textView
{
    NSMutableAttributedString *content = textView.attributedText.mutableCopy;
    
    if (!isDelete && str.length > 0) {
        
        // 获得光标所在的位置
        int location = (int)textView.selectedRange.location;
        [content insertAttributedString:[[NSAttributedString alloc]initWithString:str attributes:@{NSFontAttributeName:textView.font,NSForegroundColorAttributeName:textView.textColor}] atIndex:location];

        // 将调整后的字符串添加到UITextView上面
        textView.attributedText = content;
        //重新设置光标位置
        NSRange range;
        range.location = location + str.length;
        range.length = 0;
        textView.selectedRange = range;
        
    } else {
        //点的是删除按钮
        // 获得光标所在的位置
        int location = (int)textView.selectedRange.location;
        if(location == 0){
            return;
        }
        // 先获取前半段
        NSString *headresult = [textView.text substringToIndex:location];

        if ([headresult hasSuffix:@"]"]) {
            //最后一位是]
            for (int i = (int)[headresult length]; i>=0 ; i--) {
                //往前找，找到"["
                char tempString = [headresult characterAtIndex:(i-1)];
                if (tempString == '[') {
                    //砍掉[XXX]，重新赋值前半段
//                    headresult = [headresult substringToIndex:i - 1];

                    NSLog(@"start = %d ; i = %d ; location - i = %d",[headresult length],i,location - i );
                    [content deleteCharactersInRange:NSMakeRange(i - 1,location - i + 1)];
                    textView.attributedText = content;
                    //重新设置光标位置
                    NSRange range;

                    range.location = [headresult length];

                    range.length = 0;

                    textView.selectedRange = range;
                    return ;
                }
            }
        }
        //删除文字
        if (content.length > 0) {
            headresult = [headresult substringToIndex:headresult.length-1];
            if ([textView isKindOfClass:[HolderTextView class]]) {
                HolderTextView *holderTextView = (HolderTextView *)textView;
                [holderTextView deleteWords];
                return ;
            }
            
            [textView deleteBackward];
            return ;
        }
    }
}

@end
