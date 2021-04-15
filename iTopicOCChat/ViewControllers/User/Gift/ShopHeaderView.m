//
//  GreenButtonView.m
//  xiucai
//
//  Created by DongJin on 15-1-10.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//


#define kMarginLeftRight 0

#import "MySenderHeaderView.h"
#import "ValueUtil.h"

@implementation MySenderHeaderView


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]){
        
        int width = (SCREEN_WIDTH - kMarginLeftRight - kMarginLeftRight) / 3;
        
        UIView *titleLeftView = [[UIView alloc] init];
        titleLeftView.frame = CGRectMake(15, 22, 3, 16);
        titleLeftView.layer.cornerRadius = 1;
        titleLeftView.layer.masksToBounds = YES;
        titleLeftView.backgroundColor = [UIColor colorWithRed:139/255.0 green:193/255.0 blue:219/255.0 alpha:1/1.0];
        [self addSubview:titleLeftView];
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(30, 21 , 320, 20);
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = COLOR_BLACK_RGB;
        titleLabel.text = @"贡献排行";
        [self addSubview:titleLabel];
        
        
        UIView *secondView = [[UIView alloc]initWithFrame:CGRectMake(kMarginLeftRight, 90, width, width)];
        [self addSubview:secondView];
        self.secondView = secondView;
        
        UIView *firstView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(secondView.frame), 60, width, width)];
        [self addSubview:firstView];
        self.firstView = firstView;
        
        UIView *thirdView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(firstView.frame), 90, width, width)];
        [self addSubview:thirdView];
        self.thirdView = thirdView;
        
        titleLeftView = [[UIView alloc] init];
        titleLeftView.frame = CGRectMake(15, CGRectGetMaxY(thirdView.frame) + 40, 3, 16);
        titleLeftView.layer.cornerRadius = 1;
        titleLeftView.layer.masksToBounds = YES;
        titleLeftView.backgroundColor = [UIColor colorWithRed:139/255.0 green:193/255.0 blue:219/255.0 alpha:1/1.0];
        [self addSubview:titleLeftView];
        
        titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake(30, CGRectGetMaxY(thirdView.frame) +39 , 320, 20);
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = COLOR_BLACK_RGB;
        titleLabel.text = @"礼物列表";
        [self addSubview:titleLabel];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    iv.center = self.center;
}

- (void)setData:(NSDictionary *)dic userView:(UIView *)userView index:(int)index
{
    for (UIView *subView in userView.subviews) {
        [subView removeFromSuperview];
    }

    float kAvatarSize = userView.bounds.size.width/1.8f;
    UIImageView *avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake((userView.frame.size.width - kAvatarSize)/2, 29, kAvatarSize, kAvatarSize)];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = kAvatarSize/2;
    [userView addSubview:avatarImageView];
    if (dic){
        [avatarImageView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:dic[@"avatar"]  isThumbnail:YES]]];
    } else {
        avatarImageView.image = [UIImage imageNamed:@"user_photo"];
    }
    
    UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:userView.bounds];
    bgImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gift_sender_top%d",index]];
    [userView addSubview:bgImageView];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(avatarImageView.frame) + 18, userView.frame.size.width, 16)];
                         nameLabel.textAlignment = NSTextAlignmentCenter;
                         nameLabel.font = [UIFont boldSystemFontOfSize:15.f];
                         nameLabel.textColor = [UIColor blackColor];
           [userView addSubview:nameLabel];
    nameLabel.text = dic?dic[@"name"]:@"虚以待位";
    
    if (dic){
        UILabel *totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(nameLabel.frame) + 8, userView.frame.size.width, 16)];
                             totalLabel.textAlignment = NSTextAlignmentCenter;
                             totalLabel.font = [UIFont systemFontOfSize:14.f];
                             totalLabel.textColor = COLOR_BLACK_RGB;
               [userView addSubview:totalLabel];
        totalLabel.text = [NSString stringWithFormat:@"贡献:%@",dic[@"totalprice"]];
    }
    userView.tag = index - 1;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
