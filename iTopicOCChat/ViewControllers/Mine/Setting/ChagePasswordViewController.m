/************************************************************
 *  * EaseMob CONFIDENTIAL
 * __________________
 * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of EaseMob Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from EaseMob Technologies.
 */

#import "ChagePasswordViewController.h"

#import "FormModelSection.h"

#import "FormTextFieldCell.h"
#import "CompleteFooterCell.h"
#import "UIView+shake.h"
#import "BaseResponse.h"

@interface ChagePasswordViewController ()
{
    NSMutableArray         *_mutableItems;
    FormTextFieldModel *_formOldPasswordModel;
    FormTextFieldModel *_formNewPasswordModel1;
    FormTextFieldModel *_formNewPasswordModel2;
}

@end

@implementation ChagePasswordViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"修改密码";
    
    __weak ChagePasswordViewController *weakSelf = self;
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FormTextFieldCell" bundle:nil] forCellReuseIdentifier:@"FormTextFieldModel"];
    FormModelSection *firstSection = [FormModelSection sectionWithHeaderTitle:@"旧密码" footerTitle:@""];
    _formOldPasswordModel = [[FormTextFieldModel alloc]initWithKey:@"旧密码" Value:@""];
    _formOldPasswordModel.editable = YES;
    _formOldPasswordModel.secureTextEntry = YES;
    _formOldPasswordModel.placeHolder = @"输入旧密码";
    _formOldPasswordModel.didSelectAction = ^(NSIndexPath *indexPath){
        [weakSelf showKeyBoardAtIndexPath:indexPath];
    };

    [firstSection addItem:_formOldPasswordModel];
    
    
    FormModelSection *secondSection = [FormModelSection sectionWithHeaderTitle:@"新密码" footerTitle:@""];
    _formNewPasswordModel1 = [[FormTextFieldModel alloc]initWithKey:@"新密码" Value:@""];
    _formNewPasswordModel1.editable = YES;
    _formNewPasswordModel1.secureTextEntry = YES;
    _formNewPasswordModel1.placeHolder = @"输入新密码";
    _formNewPasswordModel1.didSelectAction = ^(NSIndexPath *indexPath){
        [weakSelf showKeyBoardAtIndexPath:indexPath];
    };
    

    [secondSection addItem:_formNewPasswordModel1];
    
    _formNewPasswordModel2 = [[FormTextFieldModel alloc]initWithKey:@"确认新密码" Value:@""];
    _formNewPasswordModel2.editable = YES;
    _formNewPasswordModel2.secureTextEntry = YES;
    _formNewPasswordModel2.placeHolder = @"确认新密码";
    _formNewPasswordModel2.didSelectAction = ^(NSIndexPath *indexPath){
        [weakSelf showKeyBoardAtIndexPath:indexPath];
    };
    [secondSection addItem:_formNewPasswordModel2];
    
    CompleteFooterCell *completeFooterCell = [[[UINib nibWithNibName:@"CompleteFooterCell" bundle:nil] instantiateWithOwner:nil options:nil] objectAtIndex:0];
    [completeFooterCell.completeButton setTitle:@"保存"  forState:UIControlStateNormal];
    completeFooterCell.backgroundColor = self.tableView.backgroundColor;
    [completeFooterCell.completeButton addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    UIView *footview = [[UIView alloc] initWithFrame:[completeFooterCell frame]];
    completeFooterCell.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [footview addSubview:completeFooterCell];
    
    self.tableView.tableFooterView = footview;
    
    _mutableItems = [[NSMutableArray alloc]initWithArray:@[firstSection,secondSection]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)refreshEnable{
    //是否支持下拉刷新，由子类重写
    return NO;
}

- (BOOL)loadMoreEnable{
    //是否支持底部自动加载更多，由子类重写
    return NO;
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

- (void)downTheKeyboard
{
    //隐藏键盘
    NSArray* cellArray = self.tableView.visibleCells;
    for (UITableViewCell * cell in cellArray) {
        for (UIView *views in [cell.contentView subviews]) {
            if ([views isKindOfClass:[UITextField class]] || [views isKindOfClass:[UITextView class]]) {
                [views resignFirstResponder];
                break;
            }
        }
    }
}

- (IBAction)saveAction:(id)sender
{
    [self downTheKeyboard];
    
    if ([_formNewPasswordModel1.valueString isEqualToString:@""]){
        UITableViewCell *cell = [self.tableView  cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [cell shake];
        return ;
    }
    
    
    if (![_formNewPasswordModel1.valueString isEqualToString:_formNewPasswordModel2.valueString]){
        [ProgressHUD showError:@"两次密码不一致"];
        return ;
    }
    
    [ProgressHUD show:@"提交中..."];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:_formOldPasswordModel.valueString,@"oldpassword",_formNewPasswordModel1.valueString,@"password", nil];
    [NETWORK postDataByApi:@"account/changepw" parameters:dictionary responseClass:[BaseResponse class] success:^(NSURLSessionTask *task, id responseObject){
        BaseResponse* result = (BaseResponse *)responseObject;
        [ProgressHUD dismiss];
        if ([result isSuccess]) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [ProgressHUD showError:result.message];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD dismiss];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self downTheKeyboard];
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 34 - 21, 300, 15)];
    titleLabel.textColor= RGBCOLOR(110,110,110);
    titleLabel.font = [UIFont systemFontOfSize:13.0];
    FormModelSection *formModelSection = [_mutableItems objectAtIndex:section];
    titleLabel.text=formModelSection.headerTitle;
    [myView addSubview:titleLabel];
    return myView;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    FormModelSection *formModelSection = [_mutableItems objectAtIndex:section];
    return [formModelSection.headerTitle isEqualToString:@""]?8.0f:34.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormModelSection *section = [_mutableItems objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    NSString *cellIdentifier = NSStringFromClass([item class]);
    FormBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    [cell setValueForHeight:item];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return 1  + size.height;
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
