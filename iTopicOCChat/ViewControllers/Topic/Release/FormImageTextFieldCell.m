//
//  FormImageTextFieldCellTableViewCell.m
//  xiucai
//
//  Created by DongJin on 15-1-8.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import "FormImageLabelCell.h"

@implementation FormImageLabelCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValueForHeight:(FormImageTextFieldModel *)item
{
    [_textField setText:item.valueString];
}
- (void)setValue:(FormImageTextFieldModel *)item
{
    self.formImageTextFieldModel = (FormImageTextFieldModel *)item;
    [_keyLabel setText:item.keyString];
    [_textField setText:item.valueString];
    [_textField setPlaceholder:item.placeHolder];
    if (item.isNetImage) {
         [_leftImageView sd_setImageWithURL:[NSURL URLWithString:item.imageName] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    }else{
        _leftImageView.image = [UIImage imageNamed:item.imageName];
    }

    _textField.keyboardType = item.keyboardType;
    _textField.textColor = COLOR_ORANGE_RGB;
    if (item.editable) {
        _arrowImageView.hidden = YES;
        [_textField setDelegate:self];
        [_textField setUserInteractionEnabled:YES];
    } else {
        _arrowImageView.hidden = NO;
        [_textField setDelegate:nil];
        [_textField setUserInteractionEnabled:NO];
    }

}


- (void)textFieldDidEndEditing:(__unused UITextField *)textField
{
     _formImageTextFieldModel.valueString = _textField.text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    return YES;
}
@end




@implementation FormImageTextFieldModel

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self didSelectAction]) {
        self.didSelectAction(indexPath);
    }
}


@end
