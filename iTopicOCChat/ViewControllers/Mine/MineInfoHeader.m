//
//  UserRegInfoHeaderCell.m
//  xiucai
//
//  Created by DongJin on 15-1-11.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import "MineInfoHeader.h"

@implementation MineInfoHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_photo"]];
               avatarImageView.frame = CGRectMake(18, 18, 66, 66);
               [self addSubview:avatarImageView];
               self.avatarImageView = avatarImageView;
           
    }
    return self;
}


@end
