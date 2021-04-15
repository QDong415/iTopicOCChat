//
//  GKDYViewController.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#define kNavAvatarWidth 30

#import "UserViewController.h"
#import "UserHeaderView.h"
#import <Masonry/Masonry.h>
#import "GKPageScrollView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "WMScrollView.h"
#import "UserResponse.h"
#import "LayoutNavigationBar.h"
#import "ValueUtil.h"
#import "StringUtil.h"
#import "ESSinglePictureBrowser.h"
#import "ChatViewController.h"
#import "ChatModel.h"
#import "MineInfoPersonalViewController.h"

@interface UserViewController ()< UIScrollViewDelegate, UINavigationBarDelegate,HeaderActionDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) UserHeaderView        *headerView;

@property (nonatomic, assign) float headerHeight;

@end

@implementation UserViewController

+ (void)pushToUser:(UIViewController *)viewController userid:(nullable NSString *)userid name:(nullable NSString*)name avatar:(nullable NSString *)avatar;
{
    UserViewController* svc = [[UserViewController alloc]init];
    svc.hisUserID = userid;
    svc.hisAvatarModel = avatar;
    svc.hisRealName = name;
    [svc setHidesBottomBarWhenPushed:YES];
    [viewController.navigationController pushViewController:svc animated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.headerView];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (![ValueUtil isEmptyString:_hisUserID]) {
        [params setObject:_hisUserID forKey:@"to_userid"];

    } else if (![ValueUtil isEmptyString:_hisRealName]) {
        if ([_hisRealName characterAtIndex:0] == '@'){
            _hisRealName = [_hisRealName substringFromIndex:1];
        }
        [params setObject:_hisRealName forKey:@"to_name"];
    } else {
        [ProgressHUD showError:@"找不到该用户"];
        return;
    }
    
    [NETWORK getDataByApi:@"user/profile" parameters:params responseClass:[UserResponse class] success:^(NSURLSessionTask *task, id responseObject){
        UserResponse *response = (UserResponse *)responseObject;
        if (response.isSuccess) {
            UserModel *_userModel = response.data;
            if (!_hisUserID){
                //之前没有userid
                self.hisUserID = _userModel.userid;
                [self.headerView createButtons:[_hisUserID isEqualToString:[USERMANAGER getUserId]]];
            }
            self.hisRealName = _userModel.name;
            self.hisAvatarModel = _userModel.avatar;
            self.headerHeight = [self.headerView setUserModel:_userModel];
            self.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.headerHeight);
            
            
            if(![ValueUtil isEmptyString:_userModel.cover]){
                [_headerView.bgImgView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:_userModel.cover isThumbnail:NO]] placeholderImage:[UIImage imageNamed:@"dy_bg"]];
            }

        } else {
            [ProgressHUD showError:response.message];
            
            if (!_hisUserID){//name进来，但是又查不到这个用户，为了界面好看一点
//                [self.view addSubview:self.pageScrollView];
//                [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.edges.equalTo(self.view);
//                }];
            }
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        [ProgressHUD showError:nil];
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - HeaderActionDelegate
- (void)onChatButtonClick
{
    if (self.hisUserID){
        [ChatViewController pushChatViewController:self targetid:self.hisUserID userId:self.hisUserID userName:self.hisRealName userPhoto:_hisAvatarModel type:TYPE_CHAT_SINGLE];
    }
}

- (void)onFollowButtonClick
{

}

- (void)onAvatarImageViewClick
{
    ESSinglePictureBrowser *browser = [[ESSinglePictureBrowser alloc] init];
    [browser showSingleImageFromView:_headerView.iconImgView placeholderImage:_headerView.iconImgView.image pictureUrl:[ValueUtil getQiniuUrlByFileName:self.hisAvatarModel isThumbnail:NO] largeImage:nil defaultSize:CGSizeZero];
}

- (void)onEditButtonClick
{
    MineInfoPersonalViewController *vc = [[MineInfoPersonalViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UserHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[UserHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDYHeaderHeight)];
        if (_hisUserID) {//已经有了，就加上两个button；否则就是通过name进来的，通过name进来的需要等访问网络后再定是不是我自己
            [_headerView createButtons:[_hisUserID isEqualToString:[USERMANAGER getUserId]]];
        }
        _headerView.delegate = self;
    }
    return _headerView;
}


- (IBAction)moreAction:(id)sender
{

}

#pragma marks UINavigationBarDelegate
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item
{
    return NO;
}
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item
{
}
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [self.navigationController popViewControllerAnimated:YES];
    return NO;
}
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item
{
}


@end
