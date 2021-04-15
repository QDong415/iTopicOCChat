//
//  ConversationCellTableViewCell.h
//  pinpin
//
//  Created by DongJin on 15-4-5.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"

@interface ConversationCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

- (void)setModel:(ChatModel *)model;

@end
