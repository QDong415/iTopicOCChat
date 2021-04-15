//
//  QMUICommonTableViewController.m
//  qmui
//
//  Created by QQMail on 14-6-24.
//  Copyright (c) 2014年 QMUI Team. All rights reserved.
//

#import "QMUICommonTableViewController.h"
#import "QMUIEmptyView.h"


const UIEdgeInsets QMUICommonTableViewControllerInitialContentInsetNotSet = {-1, -1, -1, -1};
const NSInteger kSectionHeaderFooterLabelTag = 1024;

@interface QMUICommonTableViewController ()

@property(nonatomic, strong, readwrite) UITableView *tableView;
@property(nonatomic, assign) BOOL hasSetInitialContentInset;
@property(nonatomic, assign) BOOL hasHideTableHeaderViewInitial;

@end


@implementation QMUICommonTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithNibName:nil bundle:nil]) {
        [self didInitializedWithStyle:style];
    }
    return self;
}

- (instancetype)init {
    return [self initWithStyle:UITableViewStylePlain];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self init];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self didInitializedWithStyle:UITableViewStylePlain];
    }
    return self;
}

- (void)didInitializedWithStyle:(UITableViewStyle)style {
    _style = style;
    self.hasHideTableHeaderViewInitial = NO;
    self.tableViewInitialContentInset = QMUICommonTableViewControllerInitialContentInsetNotSet;
    self.tableViewInitialScrollIndicatorInsets = QMUICommonTableViewControllerInitialContentInsetNotSet;
}

- (BOOL)refreshEnable{
    //是否支持下拉刷新，由子类重写
    return YES;
}

- (BOOL)loadMoreEnable{
    //是否支持底部自动加载更多，由子类重写
    return YES;
}

- (void)dealloc {
    // 用下划线而不是self.xxx来访问tableView，避免dealloc时self.view尚未被加载，此时调用self.tableView反而会触发loadView
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    BOOL shouldChangeTableViewFrame = !CGRectEqualToRect(self.view.bounds, self.tableView.frame);
    if (shouldChangeTableViewFrame) {
        self.tableView.frame = self.view.bounds;
    }
    
    if ([self shouldAdjustTableViewContentInsetsInitially] && !self.hasSetInitialContentInset) {
        self.tableView.contentInset = self.tableViewInitialContentInset;
        if ([self shouldAdjustTableViewScrollIndicatorInsetsInitially]) {
            self.tableView.scrollIndicatorInsets = self.tableViewInitialScrollIndicatorInsets;
        } else {
            // 默认和tableView.contentInset一致
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
        }
        
        if ([self tableViewCanScroll]) {
            CGPoint contentOffset = CGPointMake(-self.tableView.contentInset.left, -self.tableView.contentInset.top);
            if (@available(ios 11, *)) {
                if (self.tableView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
                    contentOffset = CGPointMake(-self.tableView.adjustedContentInset.left, -self.tableView.adjustedContentInset.top);
                }
            }
            [self.tableView setContentOffset:contentOffset animated:NO];
        }
        
        self.hasSetInitialContentInset = YES;
    }
    
    [self hideTableHeaderViewInitialIfCanWithAnimated:NO force:NO];
    
    [self layoutEmptyView];
}


- (BOOL)tableViewCanScroll {
    // 没有高度就不用算了，肯定不可滚动，这里只是做个保护
    if (self.tableView.bounds.size.height <= 0 || self.tableView.bounds.size.width <= 0) {
        return NO;
    }
    BOOL canVerticalScroll = self.tableView.contentSize.height + [self UIEdgeInsetsGetVerticalValue : self.tableView.contentInset] > CGRectGetHeight(self.tableView.bounds);
    BOOL canHorizontalScoll = self.tableView.contentSize.width + [self UIEdgeInsetsGetHorizontalValue : self.tableView.contentInset] > CGRectGetWidth(self.tableView.bounds);
    return canVerticalScroll || canHorizontalScoll;
}

- (CGFloat)UIEdgeInsetsGetVerticalValue:(UIEdgeInsets )insets {
    return insets.top + insets.bottom;
}

- (CGFloat)UIEdgeInsetsGetHorizontalValue:(UIEdgeInsets )insets {
    return insets.left + insets.right;
}

#pragma mark - 空列表视图 QMUIEmptyView
- (BOOL)isEmptyViewShowing {
    return self.emptyView && self.emptyView.superview;
}

- (void)showEmptyViewWithLoading {
    [self showEmptyView];
    [self.emptyView setImage:nil];
    [self.emptyView setLoadingViewHidden:NO];
    [self.emptyView setTextLabelText:nil];
    [self.emptyView setDetailTextLabelText:nil];
    [self.emptyView setActionButtonTitle:nil];
}

- (void)showEmptyViewWithText:(NSString *)text
                   detailText:(NSString *)detailText
                  buttonTitle:(NSString *)buttonTitle
                 buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:nil text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithImage:(UIImage *)image
                          text:(NSString *)text
                    detailText:(NSString *)detailText
                   buttonTitle:(NSString *)buttonTitle
                  buttonAction:(SEL)action {
    [self showEmptyViewWithLoading:NO image:image text:text detailText:detailText buttonTitle:buttonTitle buttonAction:action];
}

- (void)showEmptyViewWithLoading:(BOOL)showLoading
                           image:(UIImage *)image
                            text:(NSString *)text
                      detailText:(NSString *)detailText
                     buttonTitle:(NSString *)buttonTitle
                    buttonAction:(SEL)action {
    [self showEmptyView];
    [self.emptyView setLoadingViewHidden:!showLoading];
    [self.emptyView setImage:image];
    [self.emptyView setTextLabelText:text];
    [self.emptyView setDetailTextLabelText:detailText];
    [self.emptyView setActionButtonTitle:buttonTitle];
    [self.emptyView.actionButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.emptyView.actionButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

//之类直接调用这个方法，显示 or 隐藏emptyview
- (void)needShowEmptyView:(NSArray *)array emptyImage:(UIImage *)image emptyTitle:(NSString *)title
{
    if (array.count == 0) {
        [self showEmptyViewWithImage:image?:[UIImage imageNamed:@"tips_empty_nothing"] text:nil detailText:title?:@"没有内容哦" buttonTitle:nil buttonAction:NULL];
    } else {
        [self hideEmptyView];
    }
}

#pragma mark - 工具方法

- (UITableView *)tableView {
    if (!_tableView) {
        [self loadViewIfNeeded];
    }
    return _tableView;
}

- (void)hideTableHeaderViewInitialIfCanWithAnimated:(BOOL)animated force:(BOOL)force {
    if (self.tableView.tableHeaderView && [self shouldHideTableHeaderViewInitial] && (force || !self.hasHideTableHeaderViewInitial)) {
        CGPoint contentOffset = CGPointMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y + CGRectGetHeight(self.tableView.tableHeaderView.frame));
        [self.tableView setContentOffset:contentOffset animated:animated];
        self.hasHideTableHeaderViewInitial = YES;
    }
}

- (void)setTableViewInitialContentInset:(UIEdgeInsets)tableViewInitialContentInset {
    _tableViewInitialContentInset = tableViewInitialContentInset;
    if (UIEdgeInsetsEqualToEdgeInsets(tableViewInitialContentInset, QMUICommonTableViewControllerInitialContentInsetNotSet)) {
        self.automaticallyAdjustsScrollViewInsets = YES;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (BOOL)shouldAdjustTableViewContentInsetsInitially {
    BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.tableViewInitialContentInset, QMUICommonTableViewControllerInitialContentInsetNotSet);
    return shouldAdjust;
}

- (BOOL)shouldAdjustTableViewScrollIndicatorInsetsInitially {
    BOOL shouldAdjust = !UIEdgeInsetsEqualToEdgeInsets(self.tableViewInitialScrollIndicatorInsets, QMUICommonTableViewControllerInitialContentInsetNotSet);
    return shouldAdjust;
}

#pragma mark - 空列表视图 QMUIEmptyView

- (void)showEmptyView {
    if (!self.emptyView) {
        self.emptyView = [[QMUIEmptyView alloc] init];
    }
    [self.tableView addSubview:self.emptyView];
    [self layoutEmptyView];
}

- (void)hideEmptyView {
    [self.emptyView removeFromSuperview];
}

- (BOOL)layoutEmptyView {
    if (!self.emptyView || !self.emptyView.superview) {
        return NO;
    }
    
    UIEdgeInsets insets = self.tableView.contentInset;
    if (@available(ios 11, *)) {
        if (self.tableView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            insets = self.tableView.adjustedContentInset;
        }
    }
    float emptyViewY = [self emptyViewNeedPaddingTop];
//
//     NSLog(@"height = %f", CGRectGetHeight(self.tableView.bounds));
//    NSLog(@"insetHeight = %f", [self UIEdgeInsetsGetVerticalValue:insets]);
    
    if (emptyViewY > 0) {
        self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds) - [self UIEdgeInsetsGetHorizontalValue:insets], CGRectGetHeight(self.tableView.bounds) - [self UIEdgeInsetsGetVerticalValue:insets] - emptyViewY);
    } else if (self.tableView.tableHeaderView) {
         // 当存在 tableHeaderView 时，emptyView 的高度为 tableView 的高度减去 headerView 的高度
        self.emptyView.frame = CGRectMake(0, CGRectGetMaxY(self.tableView.tableHeaderView.frame), CGRectGetWidth(self.tableView.bounds) - [self UIEdgeInsetsGetHorizontalValue:insets], CGRectGetHeight(self.tableView.bounds) - [self UIEdgeInsetsGetVerticalValue:insets] - CGRectGetMaxY(self.tableView.tableHeaderView.frame));
    } else {
        self.emptyView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds) - [self UIEdgeInsetsGetHorizontalValue:insets], CGRectGetHeight(self.tableView.bounds) - [self UIEdgeInsetsGetVerticalValue:insets]);
    }
    return YES;
}

#pragma mark - can override
- (float)emptyViewNeedPaddingTop{
    return 0;
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

//默认拿title来构建一个view然后添加到viewForHeaderInSection里面，如果业务重写了viewForHeaderInSection，则titleForHeaderInSection被覆盖
// viewForFooterInSection同上
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return nil;
}

// 同viewForHeaderInSection
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (UITableViewHeaderFooterView *)tableHeaderFooterLabelInTableView:(UITableView *)tableView identifier:(NSString *)identifier {
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!headerFooterView) {
        UILabel *label = [[UILabel alloc] init];
        label.tag = kSectionHeaderFooterLabelTag;
        label.numberOfLines = 0;
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:identifier];
        [headerFooterView.contentView addSubview:label];
    }
    return headerFooterView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForHeaderInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([tableView.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)]) {
        UIView *view = [tableView.delegate tableView:tableView viewForFooterInSection:section];
        if (view) {
            CGFloat height = [view sizeThatFits:CGSizeMake(CGRectGetWidth(tableView.bounds), CGFLOAT_MAX)].height;
            return height;
        }
    }
    // 分别测试过 iOS 11 前后的系统版本，最终总结，对于 Plain 类型的 tableView 而言，要去掉 header / footer 请使用 0，对于 Grouped 类型的 tableView 而言，要去掉 header / footer 请使用 CGFLOAT_MIN
    return tableView.style == UITableViewStylePlain ? 0 : 8;
}

// 是否有定义某个section的header title
- (NSString *)tableView:(UITableView *)tableView realTitleForHeaderInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        NSString *sectionTitle = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if (sectionTitle && sectionTitle.length > 0) {
            return sectionTitle;
        }
    }
    return nil;
}

// 是否有定义某个section的footer title
- (NSString *)tableView:(UITableView *)tableView realTitleForFooterInSection:(NSInteger)section {
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        NSString *sectionFooter = [tableView.dataSource tableView:tableView titleForFooterInSection:section];
        if (sectionFooter && sectionFooter.length > 0) {
            return sectionFooter;
        }
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (@available(iOS 11.0, *)) {
        cell.backgroundColor = [UIColor colorNamed:@"cell"];
    }
}

//触发了下拉刷新，子类需要重写，一般在这里请求第一页数据
- (void)headerRefreshingBlock {}

//触发了底部下载更多，子类需要重写，一般在这里请求第n页数据
- (void)footerLoadmoreBlock {}


- (void)initTableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:self.style];
        if(self.style == UITableViewStylePlain){
            UIView *footerView = [[UIView alloc]init];
            _tableView.tableFooterView = footerView;
        }
        if (@available(iOS 11.0, *)) {
            _tableView.backgroundColor = [UIColor colorNamed:@"background"];
            _tableView.separatorColor = [UIColor colorNamed:@"separator"];
        } else {
            _tableView.backgroundColor = COLOR_BACKGROUND_RGB;
            _tableView.separatorColor = RGBCOLOR(227,227,227);
        }
        
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:self.tableView];
        
        __weak QMUICommonTableViewController *weakSelf = self;
        
        if ([self loadMoreEnable]){
            self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [weakSelf footerLoadmoreBlock];
            }];
        }
        
        if ([self refreshEnable]) {
            
            MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                [weakSelf headerRefreshingBlock];
            }];
            //隐藏mj下拉刷新的时间和状态
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
            header.automaticallyChangeAlpha = YES;
            self.tableView.mj_header = header;

            //先设置为没有下一页
            self.tableView.mj_footer.hidden = YES;
        }
    }
}

- (BOOL)shouldHideTableHeaderViewInitial {
    return NO;
}

- (void)setCellSelectedBackgroundView:(UITableViewCell *)cell {
    cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
    if (@available(iOS 11.0, *)) {
        cell.selectedBackgroundView.backgroundColor = [UIColor colorNamed:@"background"];
    } else {
        cell.selectedBackgroundView.backgroundColor = COLOR_BACKGROUND_RGB;
    }
}

@end
