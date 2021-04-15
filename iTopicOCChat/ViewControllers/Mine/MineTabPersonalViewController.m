//
//  MineViewController.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "MineTabPersonalViewController.h"
#import "FormMineCell.h"
#import "SettingViewController.h"
#import "MineInfoPersonalViewController.h"
#import "FormMineCell.h"
#import "FormModelSection.h"
#import "ESSinglePictureBrowser.h"
#import "UserViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ValueUtil.h"
#import "MineTabHeader.h"
#import "LayoutNavigationBar.h"
#import "PYSearchViewController.h"
#import "SearchResultRootViewController.h"
#import "UserViewController.h"

@interface MineTabPersonalViewController ()<UINavigationBarDelegate>
{
    NSMutableArray     *_mainArray;
    BOOL _isCheckingMoney;
    MineTabHeader *_mineTabHeader;
    FormModelSection *_pointSection;
}

//导航栏
@property (nonatomic, weak) UINavigationBar *navView;

@end

@implementation MineTabPersonalViewController

static NSString *identifier = @"FormMineCell";

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的";
    self.fd_prefersNavigationBarHidden = YES;
    UIImageView *naviBgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH *25/36)];
    naviBgView.image = [UIImage imageNamed:@"mine_header_bg"];
    [self.view addSubview:naviBgView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FormMineCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FormMineModel class])];
    
    _mineTabHeader = [[[UINib nibWithNibName:@"MineTabHeader" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    _mineTabHeader.userImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerInfoClick:)];
    [_mineTabHeader.userImageView addGestureRecognizer:tapGestureRecognizer];
    _mineTabHeader.userNameLabel.userInteractionEnabled = YES;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headerInfoClick:)];
    [_mineTabHeader.userNameLabel addGestureRecognizer:tapGestureRecognizer];
    
    
    self.tableView.tableHeaderView = _mineTabHeader;
    __weak MineTabPersonalViewController *weakSelf = self;
    
    FormModelSection *secondSection = [FormModelSection sectionWithHeaderTitle:@"" footerTitle:@""];
    FormMineModel *_searchModel = [[FormMineModel alloc]initWithKey:@"" Value:@"找用户动态"];
    _searchModel.imageName = @"mine_icon_search";
    _searchModel.bgType = 1;
    _searchModel.didSelectAction = ^(NSIndexPath *indexPath){
        PYSearchViewController *searchViewController = [PYSearchViewController searchViewControllerWithHotSearches:nil searchBarPlaceholder:@"输入关键词" didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
            [searchViewController dismissViewControllerAnimated:YES completion:nil];
            SearchResultRootViewController *vc = [[SearchResultRootViewController alloc]init];
            vc.keyword = searchText;
            vc.hidesBottomBarWhenPushed = YES;
            vc.title = searchText;
            [vc setUpViewControllers];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        searchViewController.searchHistoryStyle = PYHotSearchStyleDefault;
        searchViewController.hotSearchStyle = PYHotSearchStyleDefault;
//        searchViewController.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:searchViewController];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [weakSelf presentViewController:nav animated:NO completion:nil];
    };
    [secondSection addItem:_searchModel];
    

    
    FormModelSection *thirdSection = [FormModelSection sectionWithHeaderTitle:@"" footerTitle:@""];
    FormMineModel *settingModel = [[FormMineModel alloc]initWithKey:@"" Value:@"设置"];
    settingModel.imageName = @"mine_icon_setting";
    settingModel.bgType = 4;
    settingModel.didSelectAction = ^(NSIndexPath *indexPath){
        SettingViewController *vc = [[SettingViewController alloc]init];
        [vc setHidesBottomBarWhenPushed:YES];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    [thirdSection addItem:settingModel];
    
    _mainArray = [NSMutableArray arrayWithObjects:secondSection,thirdSection, nil];

    [self userLoginChanged:nil];
    
    //监听用户资料改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoChanged:) name:NOTIFICATION_USER_CHANGE object:nil];
    
    //监听用户登录退出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoginChanged:) name:NOTIFICATION_USER_LOGIN_CHANGE object:nil];
    
    [self.view bringSubviewToFront:self.tableView];
    [self createNaviView];
}

- (void)createNaviView
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    LayoutNavigationBar *transparentNavigationBar = [[LayoutNavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kTopNavHeight)];
    transparentNavigationBar.translucent = YES;
    [transparentNavigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    transparentNavigationBar.shadowImage = [UIImage new];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    NSArray *items = [[NSArray alloc] initWithObjects:navigationItem,nil];
    [transparentNavigationBar setItems:items animated:NO];
    transparentNavigationBar.delegate = self;
    [self.view addSubview:transparentNavigationBar];
    
    LayoutNavigationBar *navView = [[LayoutNavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenWidth, kTopNavHeight)];
    navView.translucent = YES;
//    navView.tintColor = [UIColor whiteColor];
    UINavigationItem *copyRightItem = [[UINavigationItem alloc] init];
    //创建UINavigationItem
    NSArray *coryitems = [[NSArray alloc] initWithObjects:copyRightItem,nil];
    [navView setItems:coryitems animated:NO];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32 + (kStatusBarHeight - 20), [UIScreen mainScreen].bounds.size.width, 20)];
    titleLabel.text = @"我的";
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    navView.alpha = 0;
    navView.delegate = self;
    [self.view addSubview:navView];
    _navView = navView;
    
    if (@available(iOS 11.0, *)) {
        self.view.backgroundColor = [UIColor colorNamed:@"background"];
        titleLabel.textColor = [UIColor colorNamed:@"black_white"];
    } else {
        self.view.backgroundColor = COLOR_BACKGROUND_RGB;
        titleLabel.textColor = COLOR_BLACK_RGB;
    }
}

- (IBAction)headerInfoClick:(id)sender
{
    MineInfoPersonalViewController *vc = [[MineInfoPersonalViewController alloc]init];
    [self checkLoginOrPush:vc];
}

- (BOOL)refreshEnable{
    //是否支持下拉刷新，由子类重写
    return NO;
}

- (BOOL)loadMoreEnable{
    //是否支持底部自动加载更多，由子类重写
    return NO;
}

- (void)checkLoginOrPush:(BaseViewController *)vc
{
    if (![self checkLogined]) {
        return;
    }
    [vc setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)userLoginChanged:(NSNotification *)notification
{
    [self userInfoChanged:notification];
}

- (void)userInfoChanged:(NSNotification *)notification
{
    UserModel *_userModel = [USERMANAGER userModel];
    if (_userModel) {
        [_mineTabHeader.userImageView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:_userModel.avatar  isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo_circle"]];
        _mineTabHeader.userNameLabel.text = _userModel.name;
    } else {
        [_mineTabHeader.userImageView setImage:[UIImage imageNamed:@"user_photo_circle"]];
        _mineTabHeader.userNameLabel.text = @"未登录";
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER_CHANGE object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER_LOGIN_CHANGE object:nil];
}

- (void)onPhotoUploadFailed
{
    _mineTabHeader.userImageView.image = [UIImage imageNamed:@"user_photo"];
}

- (void)onPhotoUploadSuccess:(NSString *)fileName resultDictionary:(NSDictionary *)resp
{
    [ProgressHUD show:@"提交中..."];
    [USERMANAGER editInfoStart:fileName withEventKey:@"avatar" withSuccessBlock:
     ^(id anything) {
         [ProgressHUD dismiss];
         [ProgressHUD showSuccess:@"修改成功"];
     } andFailBlock:^(int code,NSString *message){
         [ProgressHUD dismiss];
         [ProgressHUD showError:message];
     }];
}

- (void)onPhotoSelected:(UIImage *)compressedImage
{
    _mineTabHeader.userImageView.image = compressedImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mainArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ((FormModelSection *)[_mainArray objectAtIndex:section]).items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FormModelSection *section = [_mainArray objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    [item didSelectRowAtIndexPath:indexPath];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormModelSection *section = [_mainArray objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    NSString *cellIdentifier = NSStringFromClass([item class]);
    FormBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setValue:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma marks UINavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item{
    return NO;
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    [self.navigationController popViewControllerAnimated:YES];
    return NO;
}
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item{}
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item{}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //计算导航栏的透明度
    CGFloat minAlphaOffset = 0;
    CGFloat maxAlphaOffset = SCREEN_WIDTH  / 1.7 - kTopNavHeight;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    if (alpha > 0.5) {
        //        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    } else {
        //        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    }
    self.navView.alpha = alpha;
}


@end
