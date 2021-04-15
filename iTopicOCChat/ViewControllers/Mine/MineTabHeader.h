//
//  ContentView.h
//  FDAlertViewDemo
//
//  Created by fergusding on 15/5/26.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MineTabHeader : UITableViewCell

@property(weak,nonatomic) IBOutlet UIImageView *userImageView;
@property(weak,nonatomic) IBOutlet UILabel *userNameLabel;
@property(weak,nonatomic) IBOutlet UILabel *fansLabel;
@property(weak,nonatomic) IBOutlet UILabel *followLabel;
@end
