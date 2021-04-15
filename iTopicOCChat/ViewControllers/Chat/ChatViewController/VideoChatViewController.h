//
//  VideoChatViewController.h
//  Agora iOS Tutorial Objective-C
//
//  Created by James Fang on 7/15/16.
//  Copyright © 2016 Agora.io. All rights reserved.
//

#import "CallBaseViewController.h"

@protocol CallDelegate <NSObject>

- (void)onCallMessageUpdata:(NSString *)channelid callState:(int)newCallState content:(NSString *)content;

@end

@interface VideoChatViewController : CallBaseViewController

@property (nonatomic, assign) id <CallDelegate> delegate;

@end

