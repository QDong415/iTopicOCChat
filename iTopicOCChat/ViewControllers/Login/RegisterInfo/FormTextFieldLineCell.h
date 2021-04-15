//
//  FormTextFieldLineCellTableViewCell.h
//  xiucai
//
//  Created by DongJin on 15-1-8.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormBaseModel.h"
#import "FormBaseCell.h"
@interface FormTextFieldLineModel : FormBaseModel
@property (nonatomic,assign) BOOL editable;
@property (nonatomic,strong) NSString *placeHolder;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic,assign) NSTextAlignment textAlignment;
@property (nonatomic,strong) void (^didSelectAction)(NSIndexPath *indexPath);
//@property (nonatomic,strong) void (^didEditAction)(UITextField *textField);
@end

@interface FormTextFieldLineCell : FormBaseCell <UITextFieldDelegate>
@property (weak, nonatomic) FormTextFieldLineModel *formSingleTextFieldModel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *lineView;
- (void)setValue:(FormTextFieldLineModel *)item;
- (void)setValueForHeight:(FormTextFieldLineModel *)item;
@end


