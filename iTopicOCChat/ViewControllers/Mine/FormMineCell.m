//
//  MineCell.m
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-11.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "FormMineCell.h"
@implementation FormMineModel
- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self didSelectAction]) {
        self.didSelectAction(indexPath);
    }
}
@end

@implementation FormMineCell

- (void)awakeFromNib {
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    if (@available(iOS 11.0, *)) {
        _bgView.backgroundColor = [UIColor colorNamed:@"cell"];
        _titleLabel.textColor = [UIColor colorNamed:@"text_black_gray"];
        _remarkLabel.textColor = [UIColor colorNamed:@"text_black_gray"];
    }
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    if (@available(iOS 11.0, *)) {
        _bgView.backgroundColor = highlighted?[UIColor colorNamed:@"background"]:[UIColor colorNamed:@"cell"];
    } else {
        _bgView.backgroundColor = highlighted?RGBCOLOR(245, 245, 248):[UIColor whiteColor];
    }
}

- (void)setValue:(FormMineModel *)_model
{
    _iconImageView.image = [UIImage imageNamed:_model.imageName];
    _titleLabel.text = _model.valueString;
    _remarkLabel.text = _model.remark;
    _bgView.layer.cornerRadius = 12;
    if (_model.bgType == 1) {
        if (@available(iOS 11.0, *)) {
            _bgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;; // 左上圆角
        }
    } else if (_model.bgType == 3){
        if (@available(iOS 11.0, *)) {
            _bgView.layer.maskedCorners = kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;
        }
    } else if (_model.bgType == 4){
        if (@available(iOS 11.0, *)) {
            _bgView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner; // 左上圆角
        }
    } else {
        if (@available(iOS 11.0, *)) {
            _bgView.layer.maskedCorners = 0; // 左上圆角
        }
    }
}

@end
