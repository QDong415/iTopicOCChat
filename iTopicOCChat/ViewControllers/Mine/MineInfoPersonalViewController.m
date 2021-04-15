//
//  UserPersonalDetailViewController.m
//  pinpin
//
//  Created by DongJin on 15-3-23.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "MineInfoPersonalViewController.h"
#import "FormModelSection.h"
#import "FormTextFieldCell.h"
#import "MineInfoHeader.h"
#import "AvatarModel.h"
#import "ValueUtil.h"
#import "FormSingleLabelCell.h"
#import "STPickerArea.h"
#import "DictionaryListResponse.h"
#import "QMUIPopupMenuView.h"
#import "STPickerSingle.h"

@interface MineInfoPersonalViewController ()<STPickerAreaDelegate
    ,STPickerSingleDelegate,UIAlertViewDelegate>
{
    NSMutableArray *_mutableItems;
   

    FormTextFieldModel *_formNameModel;
    FormTextFieldModel *_formAgeModel;
    FormTextFieldModel *_formSexModel;
    FormTextFieldModel *_formMobileModel;
    FormSingleLabelModel *_formIntroModel;
}
@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, strong) NSArray *areaTotalArray;
@property (nonatomic, strong) QMUIPopupMenuView *menuPopupView;
@property (nonatomic, retain) UITableViewCell *anchorLabelCell;
@end

@implementation MineInfoPersonalViewController

- (instancetype)init {
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的资料";
    
    _mutableItems = [[NSMutableArray alloc]init];
    UserModel *myUserModel= [USERMANAGER userModel];
     __weak MineInfoPersonalViewController *weakSelf = self;
    
    MineInfoHeader *mineInfoHeader = [[MineInfoHeader alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 99)];
    if (@available(iOS 11.0, *)) {
        mineInfoHeader.backgroundColor = [UIColor colorNamed:@"gray"];
    }
    [mineInfoHeader.avatarImageView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:myUserModel.avatar  isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    self.avatarImageView = mineInfoHeader.avatarImageView;
    
    mineInfoHeader.avatarImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarImageViewClick:)];
    [mineInfoHeader.avatarImageView addGestureRecognizer:labelTapGestureRecognizer];
    
    self.tableView.tableHeaderView = mineInfoHeader;
    
    FormModelSection *firstSection = [FormModelSection sectionWithHeaderTitle:@"基本资料" footerTitle:@""];
    
    _formNameModel = [[FormTextFieldModel alloc]initWithKey:@"昵称" Value:myUserModel.name];
    _formNameModel.didSelectAction = ^(NSIndexPath *indexPath){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入新昵称" message:@"" delegate:weakSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] ;
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alert show];
    };
    [firstSection addItem:_formNameModel];

    _formAgeModel = [[FormTextFieldModel alloc] initWithKey:@"年龄" Value:[self findAgeText:myUserModel.age]];
    
    _formAgeModel.didSelectAction = ^(NSIndexPath *indexPath){
        
        STPickerSingle *pickerArea = [[STPickerSingle alloc] init];
        [pickerArea setupUI];
        pickerArea.arrayData = [weakSelf getSimpleAgeArray];
        pickerArea.title = @"请选择年龄";
        [pickerArea setDelegate:weakSelf];
        [pickerArea setContentMode:STPickerContentModeBottom];
        [pickerArea show];
    };
    [firstSection addItem:_formAgeModel];
    
    self.menuPopupView = [self createPopupView];
    
    _formSexModel = [[FormTextFieldModel alloc]initWithKey:@"性别" Value:[self findGenderText:myUserModel.gender]];
    _formSexModel.didSelectAction = ^(NSIndexPath *indexPath){
        
//        NSMutableArray *cateTotalItems = [NSMutableArray array];
//        [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:[UIImage imageNamed:@"profile_icon_female_m_normal"] title:@"男" handler:^(UIButton *button){
//            [weakSelf.menuPopupView hideWithAnimated:YES];
//            [weakSelf handleGenderSelected:1];
//        }]];
//        [cateTotalItems addObject:[QMUIPopupMenuItem itemWithImage:[UIImage imageNamed:@"profile_icon_male_m_normal"] title:@"女" handler:^(UIButton *button){
//            [weakSelf.menuPopupView hideWithAnimated:YES];
//            [weakSelf handleGenderSelected:2];
//        }]];
//
//        weakSelf.menuPopupView.items = cateTotalItems;
//        [weakSelf.menuPopupView layoutWithTargetView:[weakSelf.tableView cellForRowAtIndexPath:indexPath]];
//        [weakSelf.menuPopupView showWithAnimated:YES];
    };
    [firstSection addItem:_formSexModel];
    
    _formMobileModel = [[FormTextFieldModel alloc]initWithKey:@"城市" Value:myUserModel.cityname];
    _formMobileModel.didSelectAction = ^(NSIndexPath *indexPath){
        STPickerArea *pickerArea = [[STPickerArea alloc] init];
        pickerArea.arrayRoot = weakSelf.areaTotalArray;
        [pickerArea setupUI];
        [pickerArea setDelegate:weakSelf];
        [pickerArea setContentMode:STPickerContentModeBottom];
        [pickerArea show];
    };
    [firstSection addItem:_formMobileModel];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FormTextFieldCell" bundle:nil] forCellReuseIdentifier:@"FormTextFieldModel"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FormSingleLabelCell" bundle:nil] forCellReuseIdentifier:NSStringFromClass([FormSingleLabelModel class])];

    FormModelSection *thirdSection = [FormModelSection sectionWithHeaderTitle:@"自我介绍" footerTitle:@""];
    
    _formIntroModel = [[FormSingleLabelModel alloc]initWithKey:@"" Value:@""];
    _formIntroModel.valueString = myUserModel.intro;
    _formIntroModel.didSelectAction = ^(NSIndexPath *indexPath){
        
    };
    [thirdSection addItem:_formIntroModel];

    [_mutableItems addObject:firstSection];
    [_mutableItems addObject:thirdSection];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoChanged:) name:NOTIFICATION_USER_CHANGE object:nil];
    
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

#pragma mark AreaSelectDelegate
- (void)pickerArea:(STPickerArea *)pickerArea province:(NSDictionary *)provinceDictionary city:(NSDictionary *)cityDictionary area:(NSDictionary *)areaDictionary
{
    NSString *adcode;
    NSString *cityname;
    if(areaDictionary){
//        _formMobileModel.valueString = [NSString stringWithFormat:@"%@ %@",cityDictionary[@"name"],areaDictionary[@"name"]];
        adcode = [NSString stringWithFormat:@"%@",areaDictionary[@"code"]];//例:130102
        cityname = cityDictionary[@"name"];
        _formMobileModel.valueString = cityname;
    } else {
//        _formMobileModel.valueString = [NSString stringWithFormat:@"%@ %@",provinceDictionary[@"name"],cityDictionary[@"name"]];
        adcode = [NSString stringWithFormat:@"%@",cityDictionary[@"code"]];//例:110101 120101 419001(河南济源这种特殊的)
        cityname = provinceDictionary[@"name"];
        _formMobileModel.valueString = cityname;
    }
    
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

- (void)userInfoChanged:(NSNotification *)notification
{
    __weak MineInfoPersonalViewController *weakSelf = self;
    UserModel *userModel = [USERMANAGER userModel];

    _formIntroModel.valueString  = userModel.intro;
    _formIntroModel.didSelectAction = ^(NSIndexPath *indexPath){
    };
    
    [self.tableView reloadData];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER_CHANGE object:nil];
}

-(void)editInfoStart:(NSString*)content withEventKey:(NSString*)eventKey
{
    [ProgressHUD show:@"提交中..."];
    [USERMANAGER editInfoStart:content withEventKey:eventKey withSuccessBlock:
     ^(id anything) {
         [ProgressHUD dismiss];
         [ProgressHUD showSuccess:@"修改成功"];
         
     } andFailBlock:^(int code,NSString *message){
         [ProgressHUD dismiss];
         [ProgressHUD showError:message];
     }];
}

- (void)handleGenderSelected:(int)gender
{
    _formSexModel.valueString = gender == 1?@"男":@"女";
    
    [self.tableView reloadData];

    [USERMANAGER editInfo:@{@"gender":[NSString stringWithFormat:@"%d",gender]} success:^(id object) {
    } failure:^(int code,NSString *message){
    }];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        if([alertView textFieldAtIndex:0].text.length > 18){
            [ProgressHUD showError:@"昵称字数不能大于18个字符"];
            return;
        }
        NSString *inputText = [alertView textFieldAtIndex:0].text;
        if (inputText.length == 0 || [inputText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0){
            [ProgressHUD showError:@"昵称不能为空"];
            return;
        }
        _formNameModel.valueString = inputText;
        
        [self.tableView reloadData];

        [USERMANAGER editInfo:@{@"name":inputText} success:^(id object) {
        } failure:^(int code,NSString *message){
        }];
    }
}

#pragma mark - TagChooseViewControllerDelegate
-(void)getTheChoiceStringsArray:(NSArray *) selectedStringsArray
{
     [self editInfoStart:[ValueUtil getStringFromArray:selectedStringsArray] withEventKey:@"tags"];
}

#pragma mark - STPickerSingleDelegate
- (void)pickerSingle:(STPickerSingle *)pickerSingle selectedTitle:(NSString *)selectedTitle
{
//     [self editInfoStart:selectedValue withEventKey:eventKey];
    _formAgeModel.valueString = [NSString stringWithFormat:@"%@岁",selectedTitle];
    [self.tableView reloadData];

    [USERMANAGER editInfo:@{@"age":selectedTitle} success:^(id object) {
    } failure:^(int code,NSString *message){
    }];
}

- (IBAction)avatarImageViewClick:(id)sender
{
    [super editPortrait:YES];
}

- (void)onPhotoUploadFailed
{
    [ProgressHUD dismiss];
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:[USERMANAGER userModel].avatar isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
}

- (void)onPhotoUploadSuccess:(NSString *)fileName resultDictionary:(NSDictionary *)resp
{
    [ProgressHUD show:@"提交中..."];
    
    //看看是不是第一次上传头像，hadAvatarBefore = 之前是不是有头像
    BOOL hadAvatarBefore = MISSION_ENABLE?[USERMANAGER userModel].avatar.length != 0:YES;
    
    [USERMANAGER editInfoStart:fileName withEventKey:@"avatar" withSuccessBlock:
     ^(id anything) {
         [ProgressHUD dismiss];
         [ProgressHUD showSuccess:@"修改成功"];
         
         if(!hadAvatarBefore){
             //之前没头像 用户上传了头像，记录他完成了 上传头像 任务
             [USERMANAGER missionCompleteWithId:MISSION_AVATAR_ID withSuccessBlock:nil andFailBlock:nil];
         }
         
     } andFailBlock:^(int code,NSString *message){
         [ProgressHUD dismiss];
         [ProgressHUD showError:message];
     }];
}

- (void)onPhotoSelected:(UIImage *)compressedImage
{
    _avatarImageView.image = compressedImage;
}


- (NSString *)findGenderText:(int)gender
{
    switch (gender) {
        case 1:
            return @"男";
        case 2:
            return @"女";
        default:
            return @"未填";
    }
    return @"";
}

- (NSString *)findAgeText:(int)age
{
    switch (age) {
        case 0:
            return @"未填";
        default:
            return [NSString stringWithFormat:@"%d岁",age];
    }
    return @"";
}


- (NSMutableArray *)getSimpleAgeArray
{
    NSMutableArray *temparray = [NSMutableArray array];
    for (int i = 15; i<=60; i++) {
        [temparray addObject:[NSString stringWithFormat:@"%d",i]];
    }
    return temparray;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _mutableItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return ((FormModelSection *)[_mutableItems objectAtIndex:sectionIndex]).items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormModelSection *section = [_mutableItems objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    NSString *cellIdentifier = NSStringFromClass([item class]);
    FormBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
  
    [cell setValue:item];
    
    return cell;
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)sectionIndex
{
    FormModelSection *section = [_mutableItems objectAtIndex:sectionIndex];
    return section.footerTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FormModelSection *section = [_mutableItems objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    [item didSelectRowAtIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    FormModelSection *section = [_mutableItems objectAtIndex:indexPath.section];
    FormBaseModel *item = [section.items objectAtIndex:indexPath.row];
    NSString *cellIdentifier = NSStringFromClass([item class]);
    
    FormBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    [cell setValueForHeight:item];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
   return 1  + size.height;
}

@end
