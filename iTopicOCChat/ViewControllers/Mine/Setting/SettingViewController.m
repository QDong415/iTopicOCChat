//
//  SettingViewController.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-8.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "SettingViewController.h"
#import "SimpleWebViewController.h"
#import "FormModelSection.h"
#import "FormTextFieldCell.h"
#import "BlackListViewController.h"
#import "ChagePasswordViewController.h"
#import "CompleteFooterCell.h"
#import "AboutViewController.h"
#import "QMUIPopupMenuView.h"
#import "DictionaryResponse.h"

@interface SettingViewController ()
{
    NSArray         *_mutableItems;
    IBOutlet UIButton *_exitButton;
    FormTextFieldModel *_formAboutModel;
    FormTextFieldModel *_formNotityModel;
    FormTextFieldModel *_formDarkModel;
}

@property(nonatomic, strong) QMUIPopupMenuView *wayPopupView;
@end


@implementation SettingViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

-(IBAction)clickLoginOut:(id)sender
{
    [USERMANAGER clean];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
  
    
    FormModelSection *firstSection = [FormModelSection sectionWithHeaderTitle:@"" footerTitle:@""];
    
    __weak SettingViewController *weakSelf = self;
    _formAboutModel = [[FormTextFieldModel alloc]initWithKey:@"关于我们" Value:@""];
    _formAboutModel.didSelectAction = ^(NSIndexPath *indexPath){
        
//        SimpleWebViewController *vc = [[SimpleWebViewController alloc]init];
//        vc.URLString = @"http://u.eqxiu.com/s/Iqu2BV0q";
//        [weakSelf.navigationController pushViewController:vc animated:YES];
 

    };
    [firstSection addItem:_formAboutModel];
    
    FormTextFieldModel *_formBlackModel = [[FormTextFieldModel alloc]initWithKey:@"黑名单" Value:@""];
    _formBlackModel.didSelectAction = ^(NSIndexPath *indexPath){
        BlackListViewController *vc = [[BlackListViewController alloc] init];
        [weakSelf.navigationController pushViewController:vc animated:YES];
    };
    [firstSection addItem:_formBlackModel];
    
    UserModel *userModel = [USERMANAGER userModel];
    _formNotityModel = [[FormTextFieldModel alloc]initWithKey:@"消息提醒" Value:userModel.slience == 1?@"静音":@"有声音"];
    _formNotityModel.textAlignment = NSTextAlignmentRight;
    _formNotityModel.didSelectAction = ^(NSIndexPath *indexPath){
        NSMutableArray *cateTotalItems = [NSMutableArray array];
        [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:nil title:@"静音" handler:^(UIButton *button){
                    [weakSelf.wayPopupView hideWithAnimated:YES];
                    [weakSelf handleGenderSelected:1];
                }]];
        [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:nil title:@"有声音" handler:^(UIButton *button){
                    [weakSelf.wayPopupView hideWithAnimated:YES];
                    [weakSelf handleGenderSelected:0];
                }]];
        
        weakSelf.wayPopupView.items = cateTotalItems;
        [weakSelf.wayPopupView layoutWithTargetView:[weakSelf.tableView cellForRowAtIndexPath:indexPath]];
        [weakSelf.wayPopupView showWithAnimated:YES];
    };
    [firstSection addItem:_formNotityModel];
    
    if (@available(iOS 13.0, *)) {
        int interface = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"interface"];
        
        _formDarkModel = [[FormTextFieldModel alloc]initWithKey:@"黑夜模式" Value: [self findInterFaceString:interface]];
        _formDarkModel.textAlignment = NSTextAlignmentRight;
        _formDarkModel.didSelectAction = ^(NSIndexPath *indexPath){
            NSMutableArray *cateTotalItems = [NSMutableArray array];
            [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:nil title:@"跟随系统" handler:^(UIButton *button){
                                 [weakSelf.wayPopupView hideWithAnimated:YES];
                                 [weakSelf handleDarkSelected:0];
                             }]];
            [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:nil title:@"普通模式" handler:^(UIButton *button){
                           [weakSelf.wayPopupView hideWithAnimated:YES];
                           [weakSelf handleDarkSelected:1];
                       }]];
            [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:nil title:@"黑夜模式" handler:^(UIButton *button){
                        [weakSelf.wayPopupView hideWithAnimated:YES];
                        [weakSelf handleDarkSelected:2];
                    }]];
            
            weakSelf.wayPopupView.items = cateTotalItems;
            [weakSelf.wayPopupView layoutWithTargetView:[weakSelf.tableView cellForRowAtIndexPath:indexPath]];
            [weakSelf.wayPopupView showWithAnimated:YES];
        };
        [firstSection addItem:_formDarkModel];
    }
    
    FormTextFieldModel *_formPasswordModel = [[FormTextFieldModel alloc]initWithKey:@"修改密码" Value:@""];
    _formPasswordModel.didSelectAction = ^(NSIndexPath *indexPath){
        if ([weakSelf checkLogined]) {
            ChagePasswordViewController *vc = [[ChagePasswordViewController alloc] init];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }
    };
    [firstSection addItem:_formPasswordModel];
    
    FormTextFieldModel *_formOpinionModel = [[FormTextFieldModel alloc]initWithKey:@"意见反馈" Value:@""];
    _formOpinionModel.didSelectAction = ^(NSIndexPath *indexPath){
    };
    [firstSection addItem:_formOpinionModel];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FormTextFieldCell" bundle:nil] forCellReuseIdentifier:@"FormTextFieldModel"];
    
    if([USERMANAGER isLogin]){
        CompleteFooterCell *completeFooterCell = [[[UINib nibWithNibName:@"CompleteFooterCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
        [completeFooterCell.completeButton setTitle:@"退出登录"  forState:UIControlStateNormal];
        completeFooterCell.backgroundColor = self.tableView.backgroundColor;
        [completeFooterCell.completeButton addTarget:self action:@selector(clickLoginOut:) forControlEvents:UIControlEventTouchUpInside];
        UIView *footview = [[UIView alloc] initWithFrame:[completeFooterCell frame]];
        completeFooterCell.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [footview addSubview:completeFooterCell];
        
        self.tableView.tableFooterView = footview;
                
        _mutableItems = @[firstSection];
    } else {
        _mutableItems = @[firstSection];
    }
    
    self.wayPopupView = [self createPopupView];
    
}

- (NSString *)findInterFaceString:(int)interface
{
    switch (interface) {
        case 1:
            return @"固定普通模式";
        case 2:
            return @"固定黑夜模式";
        default:
             return @"更随系统";
    }
    return @"";
}

- (void)handleDarkSelected:(int)gender
{
    if (@available(iOS 13.0, *)) {
        _formDarkModel.valueString = [self findInterFaceString:gender];
        [[NSUserDefaults standardUserDefaults] setInteger:gender forKey:@"interface"];
        
        AppDelegate *mAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        switch (gender) {
            case 0:
                mAppDelegate.window.overrideUserInterfaceStyle = UIUserInterfaceStyleUnspecified;
                break;
            case 1:
                mAppDelegate.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
                break;
            case 2:
                mAppDelegate.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
                break;
            default:
                break;
        }
        
        [self.tableView reloadData];
    }
}


- (void)handleGenderSelected:(int)gender
{
    _formNotityModel.valueString = gender == 1?@"静音":@"有声音";
    
    [self.tableView reloadData];

    [USERMANAGER editInfo:@{@"slience":[NSString stringWithFormat:@"%d",gender]} success:^(id object) {
    } failure:^(int code,NSString *message){
    }];
}

- (QMUIPopupMenuView *)createPopupView
{
    QMUIPopupMenuView *popupView = [[QMUIPopupMenuView alloc] init];
    popupView.automaticallyHidesWhenUserTap = YES;// 点击空白地方消失浮层
    popupView.maskViewBackgroundColor = [UIColor clearColor];// 使用方法 2 并且打开了 automaticallyHidesWhenUserTap 的情况下，可以修改背景遮罩的颜色
    popupView.maximumWidth = 120;
    popupView.shouldShowItemSeparator = YES;
    popupView.separatorInset = UIEdgeInsetsMake(0, popupView.padding.left, 0, popupView.padding.right);
    return popupView;
}


- (void)dealloc
{
    NSLog(@"setting dealloc");
}


- (BOOL)refreshEnable{
    //是否支持下拉刷新，由子类重写
    return NO;
}

- (BOOL)loadMoreEnable{
    //是否支持底部自动加载更多，由子类重写
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mutableItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return ((FormModelSection *)[_mutableItems objectAtIndex:sectionIndex]).items.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24.0f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FormModelSection *section = [_mutableItems objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    [item didSelectRowAtIndexPath:indexPath];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormModelSection *section = [_mutableItems objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    NSString *cellIdentifier = NSStringFromClass([item class]);
    FormBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setValue:item];
    return cell;
}
@end
