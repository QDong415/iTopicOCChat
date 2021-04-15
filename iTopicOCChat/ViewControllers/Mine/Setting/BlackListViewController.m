//
//  RecruitViewController.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "UserSimpleCell.h"
#import "BlackListViewController.h"
#import "UserBaseListResponse.h"
#import "ValueUtil.h"
#import "UITableView+EmptyFooterView.h"
#import "UserViewController.h"

@interface BlackListViewController()
{
    int                   _page;
    
    
    NSMutableArray       *_mainArray;
}
@property (nonatomic, strong) NSString *cursor;
@end

static NSString *identifier = @"UserSimpleCell";

@implementation BlackListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"黑名单";
    
    _mainArray =  [[NSMutableArray alloc]init];
    
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];

    //马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark override
//触发了下拉刷新，子类需要重写，一般在这里请求第一页数据
- (void)headerRefreshingBlock
{
    NSMutableDictionary* paramDictionary = [NSMutableDictionary new];
    [paramDictionary setObject:@"1" forKey:@"page"];
    [paramDictionary setObject:@"1" forKey:@"block"];
    [NETWORK getDataByApi:@"user/getlist" parameters:paramDictionary responseClass:[UserBaseListResponse class] success:^(NSURLSessionTask *task, id responseObject){
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
        UserBaseListResponse* result = (UserBaseListResponse *)responseObject;
        if ([result isSuccess]) {
            [_mainArray removeAllObjects];
            [_mainArray addObjectsFromArray:result.data.items];
            self.tableView.mj_footer.hidden = ![result.data hasMore];
            [self.tableView reloadData];
            [self needShowEmptyView:_mainArray emptyImage:nil emptyTitle:nil];
            _page = 2;
        }else{
            [ProgressHUD showError:result.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark override
//触发了底部下载更多，子类需要重写，一般在这里请求第n页数据
- (void)footerLoadmoreBlock
{
    NSMutableDictionary* paramDictionary = [NSMutableDictionary new];
    [paramDictionary setObject:[NSString stringWithFormat:@"%d",_page] forKey:@"page"];
    [paramDictionary setObject:@"1" forKey:@"block"];
    [NETWORK getDataByApi:@"user/getlist" parameters:paramDictionary responseClass:[UserBaseListResponse class] success:^(NSURLSessionTask *task, id responseObject){
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.tableView.mj_footer endRefreshing];
        
        UserBaseListResponse* result = (UserBaseListResponse *)responseObject;
        if ([result isSuccess]) {
            [_mainArray addObjectsFromArray:result.data.items];
            self.tableView.mj_footer.hidden = ![result.data hasMore];
            [self.tableView reloadData];
            _page ++;
        }else{
            [ProgressHUD showError:result.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.tableView.mj_footer endRefreshing];
    }];
}

#pragma mark - UITableViewDelegate
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 48 - 21, 300, 15)];
    titleLabel.textColor= RGBCOLOR(110,110,110);
    titleLabel.font = [UIFont systemFontOfSize:13.0];
    titleLabel.text= @"不再接受黑名单的聊天消息，右滑可移除";
    [myView addSubview:titleLabel];
    return myView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mainArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserBaseModel *model =  _mainArray[indexPath.row];
    [UserViewController pushToUser:self userid:model.userid name:model.name avatar:model.avatar];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [cell setModel:_mainArray[indexPath.row]];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [ProgressHUD show:@""];
        UserBaseModel *model =  _mainArray[indexPath.row];
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:model.userid,@"to_userid", nil];
        [NETWORK postDataByApi:@"user/unblock" parameters:params responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
            [ProgressHUD dismiss];
            BaseResponse *result = (BaseResponse *)responseObject;
            if ([result isSuccess]) {
                [_mainArray removeObjectAtIndex:indexPath.row];
                [tableView reloadData];
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [ProgressHUD dismiss];
        }];
    }
}


@end
