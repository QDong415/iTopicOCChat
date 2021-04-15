//
//  MineCell.h
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-11.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormBaseCell.h"
#import "FormBaseModel.h"
@interface FormMineModel : FormBaseModel
@property (nonatomic,strong) NSString *imageName;
@property (nonatomic,strong) NSString *remark;
@property (nonatomic,assign) int bgType;
@property (nonatomic,strong) void (^didSelectAction)(NSIndexPath *indexPath);
@end

@interface FormMineCell : FormBaseCell
@property (nonatomic,strong) IBOutlet UIImageView *iconImageView;
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;

@property (nonatomic,strong) IBOutlet UIImageView *bgImageView;
@property (nonatomic,strong) IBOutlet UIView *bgView;
@property (nonatomic,strong) IBOutlet UILabel *remarkLabel;

- (void)setValue:(FormMineModel *)_model;
@end
