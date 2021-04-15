//
//  ContentView.m
//  FDAlertViewDemo
//
//  Created by fergusding on 15/5/26.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "MineTabHeader.h"
#import "ValueUtil.h"

@interface MineTabHeader ()
{
}
@property(weak,nonatomic) IBOutlet UIView *bgView;
@end

@implementation MineTabHeader

- (void)awakeFromNib {
    if (@available(iOS 11.0, *)) {
        _bgView.backgroundColor = [UIColor colorNamed:@"cell"];
        _userNameLabel.textColor = [UIColor colorNamed:@"black_white"];
        _fansLabel.textColor = [UIColor colorNamed:@"text_black_gray"];
        _followLabel.textColor = [UIColor colorNamed:@"text_black_gray"];
    }
    [super awakeFromNib];
}


@end
