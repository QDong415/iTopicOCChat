//
//  ConversationCellTableViewCell.m
//  pinpin
//
//  Created by DongJin on 15-4-5.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "ConversationCell.h"
#import "ValueUtil.h"

@interface ConversationCell()
{
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_unreadLabel;
    IBOutlet UIView  *_unreadView;
    IBOutlet UIImageView *_avatarImageView;
}

@end
@implementation ConversationCell


- (void)awakeFromNib {
    if (@available(iOS 11.0, *)) {
        _nameLabel.textColor = [UIColor colorNamed:@"text_black_gray"];
        _detailLabel.textColor = [UIColor colorNamed:@"text_gray"];
        _timeLabel.textColor = [UIColor colorNamed:@"text_gray"];
    }
    [super awakeFromNib];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setModel:(ChatModel *)model
{
    _nameLabel.text = model.other_name;
    _timeLabel.text = [ValueUtil timeIntervalBeforeNowLongDescription:model.create_time];
    NSInteger unreadCount = model.hisTotalUnReadedChatCount;
    _unreadLabel.text = [NSString stringWithFormat:@"%d",(int)unreadCount];
    if (unreadCount>0) {
        _unreadView.hidden = NO;
    }
    else
    {
        _unreadView.hidden = YES;
    }
    [_avatarImageView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:model.other_photo isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    
    _detailLabel.text = model.content;
}


@end
