//
//  ConversationViewController.m
//  pinpin
//
//  Created by DongJin on 15-4-5.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#define CELL_TYPE_REMIND 10000

#define REMIND_TYPE_COMMENT 0x100//被评论
#define REMIND_TYPE_PRAISE 0x200//被点赞
#define REMIND_TYPE_FANS 0x300// 被粉
#define REMIND_SUBTYPE_SYSYEM 0x400// 系统消息

#import "ConversationViewController.h"
#import "ValueUtil.h"
#import "ConversationCell.h"
#import "UITableView+EmptyFooterView.h"
#import "EmptyView.h"
#import "DBHelper.h"
#import "ChatViewController.h"
#import "FormNotityCell.h"

@interface ConversationViewController ()
{
    BOOL _isFirstReloadData;
}
@property (nonatomic, strong) ChatModel *commentChatModel;
@property (nonatomic, strong) ChatModel *praiseChatModel;
@property (nonatomic, strong) ChatModel *fansChatModel;
@property (nonatomic, strong) ChatModel *atChatModel;

@property (nonatomic, strong) EmptyView *dataEmptyView;
@property (nonatomic, strong) EmptyView *unLoginView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@end

static NSString *identifier = @"ConversationCell";
static NSString *remind_identifier = @"FormNotityCell";

@implementation ConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [[NSMutableArray alloc]init];
    
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    [self.tableView registerNib:[UINib nibWithNibName:remind_identifier bundle:nil] forCellReuseIdentifier:remind_identifier];
    
    _commentChatModel = [[ChatModel alloc]init];
    _commentChatModel.type = CELL_TYPE_REMIND;
    _commentChatModel.subtype = PUSH_TYPE_REMIND_COMMENT;
    _commentChatModel.other_photo = @"messagescenter_comments";
    _commentChatModel.content = @"新评论";
    
    _praiseChatModel = [[ChatModel alloc]init];
    _praiseChatModel.type = CELL_TYPE_REMIND;
    _praiseChatModel.subtype = PUSH_TYPE_REMIND_PRAISE;
    _praiseChatModel.other_photo = @"messagescenter_praise";
    _praiseChatModel.content = @"赞";
    
    _fansChatModel = [[ChatModel alloc]init];
    _fansChatModel.type = CELL_TYPE_REMIND;
    _fansChatModel.subtype = PUSH_TYPE_REMIND_FANS;
    _fansChatModel.other_photo = @"messagescenter_fans";
    _fansChatModel.content = @"新粉丝";
    
    _atChatModel = [[ChatModel alloc]init];
    _atChatModel.type = CELL_TYPE_REMIND;
    _atChatModel.subtype = PUSH_TYPE_REMIND_AT;
    _atChatModel.other_photo = @"messagescenter_at";
    _atChatModel.content = @"@我";
    
    //监听新消息已拉（pull/msg接口）
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessages:) name:NOTIFICATION_MESSAGES_RECEIVE object:nil];
    
    _isFirstReloadData = NO;
}

- (BOOL)refreshEnable{
    //是否支持下拉刷新，由子类重写
    return NO;
}

- (BOOL)loadMoreEnable{
    //是否支持底部自动加载更多，由子类重写
    return NO;
}

//这里和另外两个消息界面不同的地方是，我主动发消息也会触发数据变动
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self userLoginChanged:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)userLoginChanged:(NSNotification *)notification
{
    UserModel *_userModel = [USERMANAGER userModel];
    
    if (_userModel) {
        [self reloadConversationList];
        [self removeAllEmptyView];
    } else {
        [self.tableView reloadData];
        [self showUnLoginView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)receiveMessages:(NSNotification *)notification
{
    NSMutableArray *newMessagesTypes = (NSMutableArray *)notification.object;
    if (!newMessagesTypes) {
        return;
    }
    [self reloadConversationList];
}

- (void)reloadConversationList
{
    [self.dataArray removeAllObjects];
      
    [self.dataArray addObject:_praiseChatModel];
    [self.dataArray addObject:_commentChatModel];
    [self.dataArray addObject:_atChatModel];
    [self.dataArray addObject:_fansChatModel];
    [self.dataArray addObjectsFromArray:[DBHELPER getConversationList]];
    [self.tableView reloadData];
    
    if (!_isFirstReloadData) { //不是第一次加载
        _isFirstReloadData = YES;
    }

//    self.dataArray.count == 0?[self showEmptyDataView]:
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_MESSAGES_RECEIVE object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.type == CELL_TYPE_REMIND) {
        FormNotityCell *cell = [tableView dequeueReusableCellWithIdentifier:remind_identifier];
        [cell setModel:model];
        return cell;
    } else {
        ConversationCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        [cell setModel:model];
        return cell;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.type == CELL_TYPE_REMIND) {
        switch (model.subtype) {
            case PUSH_TYPE_REMIND_PRAISE:{
                
            }
                break;
            case PUSH_TYPE_REMIND_COMMENT:{
               
            }
                break;
            case PUSH_TYPE_REMIND_AT:{
                
            }
                break;
            case PUSH_TYPE_REMIND_FANS:{

            }
                break;
            case PUSH_TYPE_REMIND_SYSYEM:{

            }
                break;
            default:
                break;
        }
    } else if (model.type == TYPE_CHAT_SINGLE || model.type == TYPE_CHAT_GROUP) {
        [ChatViewController pushChatViewController:self targetid:model.other_userid userId:model.other_userid userName:model.other_name userPhoto:model.other_photo type:model.type];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ChatModel *model = [self.dataArray objectAtIndex:indexPath.row];
        [DBHELPER clearChatWithTargetid:model.targetid];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //让main 和 root重新计算未读数量
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MESSAGE_READED object:nil];
        
    }
}

//是否可以侧滑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.type == CELL_TYPE_REMIND){
        return NO;
    } else {
        return YES;
    }
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets insets = self.tableView.contentInset;
    if (@available(ios 11, *)) {
        if (self.tableView.contentInsetAdjustmentBehavior != UIScrollViewContentInsetAdjustmentNever) {
            insets = self.tableView.adjustedContentInset;
        }
    }
    _unLoginView.frame = CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(self.tableView.bounds) - (insets.top + insets.bottom));
    _dataEmptyView.frame = _unLoginView.bounds;
}


- (EmptyView *)unLoginView
{
    if (!_unLoginView) {
        EmptyView *view = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        view.contentLabel.text = @"需要登录后才能查看";
        view.contentImageView.image = [UIImage imageNamed:@"tips_empty_ban"];
        _unLoginView = view;
    }
    return _unLoginView;
}

- (EmptyView *)dataEmptyView
{
    if (!_dataEmptyView) {
        EmptyView *view = [[[UINib nibWithNibName:@"EmptyView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        view.contentImageView.image = [UIImage imageNamed:@"tips_empty_nothing"];
        _dataEmptyView = view;
    }
    return _dataEmptyView;
}

- (void)showUnLoginView
{
    if ([[self dataEmptyView] superview]) {
        [[self dataEmptyView] removeFromSuperview];
    }
    
    if (![[self unLoginView] superview]) {
        [self.tableView addSubview:[self unLoginView]];
    }
}

- (void)showEmptyDataView
{
    if ([[self unLoginView] superview]) {
        [[self unLoginView] removeFromSuperview];
    }
    
    if (![[self dataEmptyView] superview]) {
        [self.tableView addSubview:[self dataEmptyView]];
    }
}

#pragma mark private
- (void)removeAllEmptyView
{
    if ([[self dataEmptyView] superview]) {
        [[self dataEmptyView] removeFromSuperview];
    }
    
    if ([[self unLoginView] superview]) {
        [[self unLoginView] removeFromSuperview];
    }
}

@end
