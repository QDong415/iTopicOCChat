//
//  LLMessageDateCell.m
//  LLWeChat
//
//  Created by GYJZH on 7/21/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLMessageDateCell.h"
#import "ValueUtil.h"

#define HorizontalMargin 5
#define VerticalMargin 3

@interface LLMessageDateCell ()

@property (nonatomic) UILabel *dateLabel;

@end


@implementation LLMessageDateCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        
        if (@available(iOS 11.0, *)) {
            self.dateLabel.textColor = [UIColor colorNamed:@"text_black_gray"];
        } else {
            self.dateLabel.textColor = COLOR_BLACK_RGB;
        }
        
//        self.dateLabel.textColor = [UIColor whiteColor];
//        self.dateLabel.backgroundColor = [UIColor colorWithRed:203/255.0 green:203/255.0 blue:203/255.0 alpha:1]
//;
//        self.dateLabel.layer.cornerRadius = 6;
//        self.dateLabel.clipsToBounds = YES;
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.contentView addSubview:self.dateLabel];
    }
    
    return self;
}


- (void)setMessageModel:(ChatModel *)messageModel {
    if (_messageModel != messageModel) {
        _messageModel = messageModel;

        self.dateLabel.text = messageModel.content;

        [self layoutContentView];
    }
    
}

- (void)layoutContentView {
    CGRect frame = CGRectZero;
    frame.size.width = self.dateLabel.intrinsicContentSize.width + 2 * HorizontalMargin;
    frame.size.height = self.dateLabel.intrinsicContentSize.height + 2 * VerticalMargin;

    frame.origin.x = (SCREEN_WIDTH - frame.size.width) /2;
    frame.origin.y = (50 - frame.size.height)/2 ;
    self.dateLabel.frame = frame;

}

+ (CGFloat)heightForModel:(ChatModel *)model {
    return 50;
}

@end
