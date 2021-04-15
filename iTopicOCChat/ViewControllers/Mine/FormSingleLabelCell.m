//
//  FormSingleLabelCell.m
//  pinpin
//
//  Created by DongJin on 15-4-2.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "FormSingleLabelCell.h"


@implementation FormSingleLabelCell

- (void)awakeFromNib {
    // Initialization code
    _label.preferredMaxLayoutWidth = [[ UIScreen mainScreen ] bounds ].size.width - 16 - 16;
    if (@available(iOS 11.0, *)) {
        _label.textColor = [UIColor colorNamed:@"text_black_gray"];
    }
    [super awakeFromNib];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setValue:(FormSingleLabelModel *)model
{
    NSString *string = [model.valueString isEqualToString:@""]?@"未填写":model.valueString;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineSpacing = 3;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
    _label.attributedText = [[NSAttributedString alloc]initWithString:string attributes:attributes];
}

- (void)setValueForHeight:(FormSingleLabelModel *)model
{
    [self setValue:model];
}

@end




@implementation FormSingleLabelModel

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self didSelectAction]) {
        self.didSelectAction(indexPath);
    }
}


@end
