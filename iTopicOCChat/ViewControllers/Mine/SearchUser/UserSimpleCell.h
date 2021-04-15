//
//  SquareNearCell.h
//  pinpin
//
//  Created by DQ QQ:285275534 on 15-2-27.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserBaseModel.h"
@interface UserSimpleCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel *nameLabel;
@property(nonatomic,weak)IBOutlet UIImageView *userImageView;

- (void)setModel:(UserBaseModel *)model;

@end
