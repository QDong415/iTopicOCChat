//
//  MineProgressRootViewController.m
//  iTopic
//
//  Created by DongJin on 16/5/19.
//  Copyright © 2016年 DongQi. All rights reserved.
//

#import "SearchResultRootViewController.h"
#import "UserSimpleViewController.h"

@interface SearchResultRootViewController ()

@end

@implementation SearchResultRootViewController

//需要在init之后执行
- (void)setUpViewControllers
{
    self.viewControllerClasses = @[[UserSimpleViewController class]];
    self.titles = @[@"用户" ];
    self.menuViewStyle = WMMenuViewStyleLine;
//    self.menuHeight = 44;
    self.menuItemWidth = 72;
    self.values = @[@{@"keyword":_keyword}].mutableCopy;
    self.keys = @[@"params"].mutableCopy;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    UIView *backgroundView = [self.navigationController.navigationBar subviews].firstObject;
    for (UIView *view in backgroundView.subviews) {
        if (CGRectGetHeight([view frame]) <= 1) {
            view.hidden = YES;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    UIView *backgroundView = [self.navigationController.navigationBar subviews].firstObject;
    for (UIView *view in backgroundView.subviews) {
        if (CGRectGetHeight([view frame]) <= 1) {
            view.hidden = NO;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *menuLineView  = [[UIView alloc]initWithFrame:CGRectMake(0, self.menuView.frame.size.height - 1, SCREEN_WIDTH, 1)];
   
    if (@available(iOS 11.0, *)) {
        self.menuView.backgroundColor =  [UIColor colorNamed:@"background"];
         menuLineView.backgroundColor = [UIColor colorNamed:@"separator"];
    } else {
        self.menuView.backgroundColor =  [[UINavigationBar appearance] barTintColor];
         menuLineView.backgroundColor = COLOR_DIVIDER_RGB;
    }
    
    [self.menuView addSubview:menuLineView];
}


- (IBAction)close:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat leftMargin = self.showOnNavigationBar ? 50 : 0;
    CGFloat originY = self.showOnNavigationBar ? 0 : CGRectGetMaxY(self.navigationController.navigationBar.frame);
    return CGRectMake(leftMargin, originY, self.view.frame.size.width - 2*leftMargin, 44);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, originY, self.view.frame.size.width, self.view.frame.size.height - originY);
}

@end
