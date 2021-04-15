//
//  GreenButtonView.m
//  xiucai
//
//  Created by DongJin on 15-1-10.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import "EmptyView.h"

@implementation EmptyView


- (void)awakeFromNib {
    // Initialization code
//    _contentLabel.shadowColor = [UIColor whiteColor];
//    _contentLabel.shadowOffset = CGSizeMake(0, 1.0);
    if (@available(iOS 11.0, *)) {
        self.backgroundColor = [UIColor colorNamed:@"background"];
        _contentLabel.textColor = [UIColor colorNamed:@"text_gray"];
    } else {
        self.backgroundColor = COLOR_BACKGROUND_RGB;
    }
    [super awakeFromNib];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
