//
//  DynamicStateViewController.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//


#import "UserSimpleViewController.h"
#import "UserSimpleCell.h"
#import "ValueUtil.h"
#import "UserBaseListResponse.h"
#import "UserViewController.h"

@interface UserSimpleViewController ()<UIActionSheetDelegate>
{
}
@property (nonatomic, assign) int page;
@property (nonatomic, strong) NSMutableArray *mainArray;
@end


static NSString *identifier = @"UserSimpleCell";

@implementation UserSimpleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    _page = 1;
    _mainArray =  [[NSMutableArray alloc]init];

    [self.tableView.mj_header beginRefreshing];
}


#pragma mark override
//触发了下拉刷新，子类需要重写，一般在这里请求第一页数据
- (void)headerRefreshingBlock
{
    NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionaryWithDictionary:_params];
    [paramDictionary setObject:@"1" forKey:@"page"];
    
    [NETWORK getDataByApi:@"user/getlist" parameters:paramDictionary responseClass:[UserBaseListResponse class] success:^(NSURLSessionTask *task, id responseObject){
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.tableView.mj_header endRefreshing];
        UserBaseListResponse *response = (UserBaseListResponse *)responseObject;
        if ([response isSuccess]) {
            [_mainArray removeAllObjects];
            [_mainArray addObjectsFromArray:response.data.items];
            self.tableView.mj_footer.hidden = ![response.data hasMore];
            [self.tableView reloadData];
               [self needShowEmptyView:_mainArray emptyImage:nil emptyTitle:nil];
            _page = 2;
        } else {
            [ProgressHUD showError:response.message];
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
    NSMutableDictionary *paramDictionary = [NSMutableDictionary dictionaryWithDictionary:_params];
    [paramDictionary setObject:[NSString stringWithFormat:@"%d",_page] forKey:@"page"];
    [NETWORK getDataByApi:@"user/getlist" parameters:paramDictionary responseClass:[UserBaseListResponse class] success:^(NSURLSessionTask *task, id responseObject){
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.tableView.mj_footer endRefreshing];
        UserBaseListResponse *response = (UserBaseListResponse *)responseObject;
        if ([response isSuccess]) {
            [_mainArray addObjectsFromArray:response.data.items];
            self.tableView.mj_footer.hidden = ![response.data hasMore];
            [self.tableView reloadData];
            _page ++;
        }else{
            [ProgressHUD showError:response.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        // 拿到当前的上拉刷新控件，结束刷新状态
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)pullAndRefresh
{
    //马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}


#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mainArray.count ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserBaseModel *topicModel  = self.mainArray[indexPath.row];
    [UserViewController pushToUser:self userid:topicModel.userid name:topicModel.name avatar:topicModel.avatar];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserSimpleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserSimpleCell"];
    
    [super setCellSelectedBackgroundView:cell];
    
    UserBaseModel *topicModel  = self.mainArray[indexPath.row];
    
    [cell setModel : topicModel];

    return cell;
}

@end
