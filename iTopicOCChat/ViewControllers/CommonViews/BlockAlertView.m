//
//  BlockAlertView.m
//  pinpin
//
//  Created by DongJin on 15-4-12.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "BlockAlertView.h"

@implementation BlockAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id) init {
    self = [super init];
    if (self) {
        self.delegate = self;
        
    }
    return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self performSelector:@selector(finishedAnimated:) withObject:[NSNumber numberWithInt:(int)buttonIndex] afterDelay:0];
}

-(void)finishedAnimated:(NSNumber *)buttonIndex
{
    if ([self onClick]) {
        self.onClick(self,[buttonIndex intValue]);
    }
}

@end
