//
//  SquareNearCell.m
//  pinpin
//
//  Created by DQ QQ:285275534 on 15-2-27.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "UserSimpleCell.h"
#import "ValueUtil.h"
@interface UserSimpleCell()
{

}

@end


@implementation UserSimpleCell


- (void)awakeFromNib {
    // Initialization code
    _userImageView.layer.cornerRadius = _userImageView.frame.size.height/2;
    _userImageView.layer.masksToBounds = YES;
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(UserBaseModel *)model
{
    _nameLabel.text =  model.name;
    [_userImageView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:model.avatar isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo_circle"]];
}

@end
