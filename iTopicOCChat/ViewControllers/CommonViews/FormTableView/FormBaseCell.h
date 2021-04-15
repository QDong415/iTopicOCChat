//
//  FormBaseCell.h
//  xiucai
//
//  Created by DongJin on 15-1-10.
//  Copyright (c) 2015年 DongJin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FormBaseModel;
@interface FormBaseCell : UITableViewCell
- (void)setValue:(FormBaseModel *)item;
- (void)setValueForHeight:(FormBaseModel *)item;
@end
