//
//  FunsEachCell.h
//  pinpin
//
//  Created by QDong Email: 285275534@qq.com on 15-2-12.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"

@interface FormNotityCell : UITableViewCell
@property(nonatomic,strong)IBOutlet UIImageView *userImageView;
@property(nonatomic,strong)IBOutlet UILabel *titleLabel;
@property(nonatomic,strong)IBOutlet UILabel *unreadLabel;
@property(nonatomic,strong)IBOutlet UIView  *unreadView;

- (void)setModel:(ChatModel *)model;
@end
