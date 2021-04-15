//
//  UserRegInfoHeaderCell.m
//  xiucai
//
//  Created by DongJin on 15-1-11.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import "UserRegInfoHeaderView.h"

@implementation UserRegInfoHeaderView

- (void)awakeFromNib {
    
    if (@available(iOS 11.0, *)) {
        self.avatarLabel.textColor = [UIColor colorNamed:@"text_gray"];
    }
    [super awakeFromNib];
}

@end
