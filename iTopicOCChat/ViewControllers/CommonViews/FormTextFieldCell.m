//
//  FormTextFieldCellTableViewCell.m
//  xiucai
//
//  Created by DongJin on 15-1-8.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import "FormTextFieldCell.h"

@implementation FormTextFieldCell


- (void)awakeFromNib {
    if (@available(iOS 11.0, *)) {
        _keyLabel.textColor = [UIColor colorNamed:@"text_black_gray"];
        _textField.textColor = [UIColor colorNamed:@"text_black_gray"];
    }
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setValueForHeight:(FormTextFieldModel *)item
{
    [_textField setText:item.valueString];
}
- (void)setValue:(FormTextFieldModel *)item
{
    self.formTextFieldModel = (FormTextFieldModel *)item;
    [_keyLabel setText:item.keyString];
    [_textField setText:item.valueString];
    [_textField setPlaceholder:item.placeHolder];
    [_textField setTextAlignment:item.textAlignment];
    _textField.secureTextEntry = item.secureTextEntry;
    if (item.keyboardType) {
        _textField.keyboardType = item.keyboardType;
    }
    if (item.editable) {
        _arrowImage.hidden = YES;
        [_textField setDelegate:self];
        [_textField setUserInteractionEnabled:YES];
    } else {
        _arrowImage.hidden = NO;
        [_textField setDelegate:nil];
        [_textField setUserInteractionEnabled:NO];
    }

}


- (void)textFieldDidEndEditing:(__unused UITextField *)textField
{
     _formTextFieldModel.valueString = _textField.text;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    return YES;
}
@end




@implementation FormTextFieldModel

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self didSelectAction]) {
        self.didSelectAction(indexPath);
    }
}


@end
