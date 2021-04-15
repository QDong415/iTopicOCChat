//
//  FormHouseCell.m
//  pinpin
//
//  Created by DongJin on 15-4-2.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//


#import "GiftsCell.h"
#import "GiftCellView.h"

@interface GiftsCell()
{

//    GiftCellView *_houseView1;
//    GiftCellView *_houseView2;
}

@property(nonatomic,strong)UIScrollView *scrollView;

@end

@implementation GiftsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // 1.创建UIScrollView
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, kGiftsCellHeight);
        scrollView.backgroundColor = [UIColor clearColor];
//        scrollView.contentSize = CGSizeMake(243 * 2, FormHouseCellHeight);
        [self.contentView addSubview:scrollView];
        self.scrollView = scrollView;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}


- (void)setValue:(NSArray<NSDictionary *> *)array
{
    int count = (int)[array count];
    int cellWidth = kGifImageViewSize + 12+ 12;
    for (int i = 0; i < count; i++) {
        NSDictionary *dic = array[i];
        GiftCellView *giftCellView = [[GiftCellView alloc]initWithFrame:CGRectMake(0, 0, cellWidth, kGiftsCellHeight)];
        [self.scrollView addSubview:giftCellView];
        [giftCellView setGiftData:dic];
    }
    [self.scrollView setContentSize:CGSizeMake(cellWidth * count, kGiftsCellHeight)];
}

@end
