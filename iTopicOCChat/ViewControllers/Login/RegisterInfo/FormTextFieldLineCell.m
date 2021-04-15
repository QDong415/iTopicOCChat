//
//  FormTextFieldLineCellTableViewCell.m
//  xiucai
//
//  Created by DongJin on 15-1-8.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import "FormTextFieldLineCell.h"

@implementation FormTextFieldLineCell

- (void)awakeFromNib {
    
    if (@available(iOS 11.0, *)) {
        self.lineView.backgroundColor = [UIColor colorNamed:@"gray"];
        _textField.textColor = [UIColor colorNamed:@"text_black_gray"];
    }
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setValueForHeight:(FormTextFieldLineModel *)item
{
    [_textField setText:item.valueString];
}

- (void)setValue:(FormTextFieldLineModel *)item
{
    self.formSingleTextFieldModel = (FormTextFieldLineModel *)item;
    [_textField setText:item.valueString];
    [_textField setPlaceholder:item.placeHolder];
    [_textField setTextAlignment:item.textAlignment];
    if (item.keyboardType) {
        _textField.keyboardType = item.keyboardType;
    }
    if (item.editable) {
        [_textField setDelegate:self];
        [_textField setUserInteractionEnabled:YES];
    } else {
        [_textField setDelegate:nil];
        [_textField setUserInteractionEnabled:NO];
    }
}

- (void)textFieldDidEndEditing:(__unused UITextField *)textField
{
    _formSingleTextFieldModel.valueString = _textField.text;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textField resignFirstResponder];
    return YES;
}

@end




@implementation FormTextFieldLineModel

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self didSelectAction]) {
        self.didSelectAction(indexPath);
    }
}


@end
