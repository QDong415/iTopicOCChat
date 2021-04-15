//
//  InformationWriteViewController.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "RegisterInfoViewController.h"
#import "ValueUtil.h"
#import "FormTextFieldLineCell.h"
#import "FormModelSection.h"
#import "UIView+shake.h"
#import "UserRegInfoHeaderView.h"
#import "CompleteFooterCell.h"
#import "UserResponse.h"
#import "STPickerArea.h"
#import "DictionaryListResponse.h"
#import "QMUIPopupMenuView.h"

@interface RegisterInfoViewController ()<UIActionSheetDelegate>
{
    UIImageView      *_headImageView;
    NSMutableArray            *_mainArray;
    FormTextFieldLineModel  *_formNickNameModel;
    FormTextFieldLineModel *_formGenderModel;

    NSString *_currentGendercode;
}
@property (nonatomic, strong) NSArray *areaTotalArray;
@property (nonatomic, strong) QMUIPopupMenuView *menuPopupView;
@end

@implementation RegisterInfoViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"完善资料";
    
    __weak RegisterInfoViewController *weakSelf = self;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.backgroundColor = [UIColor colorNamed:@"white"];
//        self.view.backgroundColor = [UIColor colorNamed:@"white"];
    } else {
        self.tableView.backgroundColor = [UIColor whiteColor];
    }
    
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    
    int viewControllersCount = (int)[self.navigationController.viewControllers count];
    if (viewControllersCount == 1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 28, 28);
        [button setBackgroundImage:[UIImage imageNamed:@"navigationbar_close"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"navigationbar_close_highlighted"] forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *homeButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];
                self.navigationItem.leftBarButtonItem = homeButtonItem;
    }
    
    //设置导航栏透明
    [self.navigationController.navigationBar setTranslucent:true];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    _mainArray = [[NSMutableArray alloc]init];
    UserRegInfoHeaderView *userRegInfoHeaderView = [[[UINib nibWithNibName:@"UserRegInfoHeaderView" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    userRegInfoHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 208);
    userRegInfoHeaderView.avatarImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarImageViewClick:)];
    [userRegInfoHeaderView.avatarImageView addGestureRecognizer:labelTapGestureRecognizer];
    
    _headImageView = userRegInfoHeaderView.avatarImageView;
    if (self.photoUrl) {
        [_headImageView sd_setImageWithURL:[NSURL URLWithString:self.photoUrl] placeholderImage:[UIImage imageNamed:@"user_photo_circle"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            //把image提交给我的七牛服务器
            [super uploadPicture:UIImagePNGRepresentation(image)];
        }];
    }
    self.tableView.tableHeaderView = userRegInfoHeaderView;
    FormModelSection *firstSection = [FormModelSection sectionWithHeaderTitle:@"" footerTitle:@""];
    [self.tableView registerNib:[UINib nibWithNibName:@"FormTextFieldLineCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FormTextFieldLineModel class])];
    
    _formNickNameModel = [[FormTextFieldLineModel alloc]initWithKey:@"" Value:self.name?:@""];
    _formNickNameModel.placeHolder = @"输入昵称（必填)";
    _formNickNameModel.editable = YES;
    _formNickNameModel.didSelectAction = ^(NSIndexPath *indexPath){
        [weakSelf showKeyBoardAtIndexPath:indexPath];
    };
    [firstSection addItem:_formNickNameModel];
    
    
    self.menuPopupView = [self createPopupView];
    _formGenderModel = [[FormTextFieldLineModel alloc]initWithKey:@"" Value:@""];
    _formGenderModel.placeHolder = @"性别（必填)";
    _formGenderModel.editable = NO;
    _formGenderModel.didSelectAction = ^(NSIndexPath *indexPath){
         NSMutableArray *cateTotalItems = [NSMutableArray array];
               [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:[UIImage imageNamed:@"profile_icon_male_m_normal"] title:@"男" handler:^(UIButton *button){
                   [weakSelf.menuPopupView hideWithAnimated:YES];
                   [weakSelf handleGenderSelected:1];
               }]];
               [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:[UIImage imageNamed:@"profile_icon_female_m_normal"] title:@"女" handler:^(UIButton *button){
                   [weakSelf.menuPopupView hideWithAnimated:YES];
                   [weakSelf handleGenderSelected:2];
               }]];

               weakSelf.menuPopupView.items = cateTotalItems;
               [weakSelf.menuPopupView layoutWithTargetView:[weakSelf.tableView cellForRowAtIndexPath:indexPath]];
               [weakSelf.menuPopupView showWithAnimated:YES];
    };
    [firstSection addItem:_formGenderModel];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _areaTotalArray = [defaults arrayForKey:@"area_total"];
    
    if (_areaTotalArray.count == 0) {
        NSDictionary *params = [NSDictionary dictionary];
        [NETWORK getDataByApi:@"city/totallist" parameters:params responseClass:[DictionaryListResponse class] success:^(NSURLSessionTask *task, id responseObject){
            DictionaryListResponse *response = (DictionaryListResponse *)responseObject;
            if (response.isSuccess) {
                _areaTotalArray = response.data.items;
                [defaults setObject:_areaTotalArray forKey:@"area_total"];
                [defaults synchronize];
            } else {
                [ProgressHUD showError:response.message];
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            [ProgressHUD showError:nil];
        }];
    }
    
    
    CompleteFooterCell *completeFooterCell = [[[UINib nibWithNibName:@"CompleteFooterCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    completeFooterCell.backgroundColor = self.tableView.backgroundColor;
    [completeFooterCell.completeButton setTitle:@"完成" forState:UIControlStateNormal];
    [completeFooterCell.completeButton addTarget:self action:@selector(commitResult:) forControlEvents:UIControlEventTouchUpInside];
    UIView *footview = [[UIView alloc] initWithFrame:[completeFooterCell frame]];
    completeFooterCell.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [footview addSubview:completeFooterCell];
    self.tableView.tableFooterView = footview;

    _headImageView.layer.masksToBounds = YES;
    _headImageView.layer.cornerRadius = _headImageView.bounds.size.width/2.0f;
    
    [_mainArray addObject:firstSection];
    
    if (self.autoreg) {
        char data[5];
        for (int x=0;x<5;data[x++] = (char)('A' + (arc4random_uniform(26))));
        NSString *name = [[NSString alloc] initWithBytes:data length:5 encoding:NSUTF8StringEncoding];
        _formNickNameModel.valueString = self.name?:name;
//        _formPasswordModel.valueString = @"123";
        [self commitResult:nil];
    } else if (!self.name) {
//        [self performSelector:@selector(showKeyBoard) withObject:nil afterDelay:0.7];
    }
}


- (QMUIPopupMenuView *)createPopupView
{
    QMUIPopupMenuView *popupView = [[QMUIPopupMenuView alloc] init];
    popupView.automaticallyHidesWhenUserTap = YES;// 点击空白地方消失浮层
    popupView.maskViewBackgroundColor = [UIColor clearColor];// 使用方法 2 并且打开了 automaticallyHidesWhenUserTap 的情况下，可以修改背景遮罩的颜色
    popupView.maximumWidth = 90;
    popupView.shouldShowItemSeparator = YES;
    popupView.separatorInset = UIEdgeInsetsMake(0, popupView.padding.left, 0, popupView.padding.right);
    return popupView;
}


- (void)handleGenderSelected:(int)gender
{
    _formGenderModel.valueString = gender == 1?@"男":@"女";
    _currentGendercode = [NSString stringWithFormat:@"%d",gender];
    [self.tableView reloadData];
}

- (BOOL)refreshEnable{
    //是否支持下拉刷新，由子类重写
    return NO;
}

- (BOOL)loadMoreEnable{
    //是否支持底部自动加载更多，由子类重写
    return NO;
}

- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showKeyBoard
{
    [self showKeyBoardAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

- (void)showKeyBoardAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView  cellForRowAtIndexPath:indexPath];
    for (UIView *views in [cell.contentView subviews]) {
        if ([views isKindOfClass:[UITextField class]]) {
            [views becomeFirstResponder];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self downTheKeyboard];
}

- (IBAction)avatarImageViewClick:(UITapGestureRecognizer *)sender {
    [self downTheKeyboard];
    [super editPortrait:YES];
}

- (IBAction)commitResult:(UIButton *)sender {
    [self downTheKeyboard];
    
    NSString *name = _formNickNameModel.valueString;
    
    if ([name isEqualToString:@""]){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [cell shake];
        return ;
    }
    
    if ([name containsString:@" "] || [name containsString:@"@"] || [name containsString:@"#"]) {
        [ProgressHUD showError:@"昵称包含非法字符"];
        return ;
    }
    
    if ([_formGenderModel.valueString isEqualToString:@""]){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [cell shake];
        return ;
    }
    
    [ProgressHUD show:@"请稍候..."];
    //开始上传
    NSMutableDictionary* paramDictionary = [NSMutableDictionary new];
    [paramDictionary setObject:_mobile?:@"" forKey:@"mobile"];
    [paramDictionary setObject:_code?:@"" forKey:@"code"];
    [paramDictionary setObject:_password?:@""  forKey:@"password"];
    [paramDictionary setObject:name  forKey:@"name"];
    [paramDictionary setObject:_photoUrl?:@"" forKey:@"avatar"];
    [paramDictionary setObject:_unionid?:@"" forKey:@"unionid"];
    [paramDictionary setObject:_qqid?:@"" forKey:@"qqid"];
    [paramDictionary setObject:_currentGendercode?:@"" forKey:@"gender"];
    
    [NETWORK postDataByApi:@"account/register" parameters:paramDictionary responseClass:[UserResponse class] success:^(NSURLSessionTask *task, id responseObject){
        UserResponse* result = (UserResponse*)responseObject;
        if ([result isSuccess]) {
            
            //访问login或者reg网络成功 处理我们自己的逻辑
            [USERMANAGER loginRequiteSuccess:result.data];
            
            if (MISSION_ENABLE && _photoUrl) {
                //用户上传了头像，记录他完成了 上传头像 任务
                [USERMANAGER missionCompleteWithId:MISSION_AVATAR_ID withSuccessBlock:nil andFailBlock:nil];
            }
            
            [ProgressHUD dismiss];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
        } else {
            [ProgressHUD dismiss];
            [ProgressHUD showError:result.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
    }];
}

- (void)dealloc
{
    NSLog(@"RegInfo dealloc");
}

- (void)downTheKeyboard
{
    NSArray* cellArray = self.tableView.visibleCells;
    for (UITableViewCell * cell in cellArray) {
        for (UIView *views in [cell.contentView subviews]) {
            if ([views isKindOfClass:[UITextField class]]) {
                [views resignFirstResponder];
                break;
            }
        }
    }
}

- (void)onPhotoUploadFailed
{
    [ProgressHUD dismiss];
    _headImageView.image = [UIImage imageNamed:@"user_reg_photo"];
    _photoUrl = nil;
}

- (void)onPhotoUploadSuccess:(NSString *)fileName resultDictionary:(NSDictionary *)resp
{
    [ProgressHUD dismiss];
    _photoUrl = fileName;
}

- (void)onPhotoSelected:(UIImage *)compressedImage
{
    _headImageView.image = compressedImage;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mainArray.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return ((FormModelSection *)[_mainArray objectAtIndex:sectionIndex]).items.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
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
@end
