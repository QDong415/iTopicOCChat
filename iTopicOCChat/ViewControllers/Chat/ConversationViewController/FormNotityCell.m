//
//  FormNotityCell.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-12.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "FormNotityCell.h"

@implementation FormNotityCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setModel:(ChatModel *)model;
{
    _titleLabel.text = model.content;
    _userImageView.image = [UIImage imageNamed:model.other_photo];
    _unreadLabel.text = [NSString stringWithFormat:@"%d",(int)model.hisTotalUnReadedChatCount];
    _unreadView.hidden = model.hisTotalUnReadedChatCount <= 0;
}


@end
