//
//  MineOrderRootViewController.h
//  iTopic
//
//  Created by DongJin on 16/5/19.
//  Copyright © 2016年 DongQi. All rights reserved.
//

#import "WMPageController.h"


@interface SearchResultRootViewController : WMPageController

@property (nonatomic,strong) NSString *keyword;

- (void)setUpViewControllers;

@end
