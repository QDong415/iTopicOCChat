//
//  FormTextFieldCellTableViewCell.h
//  xiucai
//
//  Created by DongJin on 15-1-8.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormBaseModel.h"
#import "FormBaseCell.h"
@interface FormTextFieldModel : FormBaseModel
@property (nonatomic,assign) BOOL editable;//是否可以编辑
@property (nonatomic,assign) BOOL secureTextEntry;//是否是密码样式，默认NO
@property (nonatomic,strong) NSString *placeHolder;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic,assign) NSTextAlignment textAlignment;
@property (nonatomic,strong) void (^didSelectAction)(NSIndexPath *indexPath);
@end

@interface FormTextFieldCell : FormBaseCell <UITextFieldDelegate>
@property (weak, nonatomic) FormTextFieldModel *formTextFieldModel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *keyLabel;
@property (strong, nonatomic) IBOutlet UIImageView *arrowImage;
- (void)setValue:(FormTextFieldModel *)item;
- (void)setValueForHeight:(FormTextFieldModel *)item;
@end


