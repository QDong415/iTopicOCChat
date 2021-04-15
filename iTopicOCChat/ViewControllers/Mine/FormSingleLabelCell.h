//
//  FormSingleLabelCell.h
//  pinpin
//
//  Created by DongJin on 15-4-2.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "FormBaseModel.h"
#import "FormBaseCell.h"
@interface FormSingleLabelModel : FormBaseModel
@property (nonatomic,strong) void (^didSelectAction)(NSIndexPath *indexPath);
@end

@interface FormSingleLabelCell: FormBaseCell
@property (strong, nonatomic) IBOutlet UILabel *label;
- (void)setValue:(FormSingleLabelModel *)item;
- (void)setValueForHeight:(FormSingleLabelModel *)item;

@end

