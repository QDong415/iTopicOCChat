/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import "InputTableViewController.h"

@interface ChatViewController : InputTableViewController

@property (nonatomic,strong) NSString *targetid;
@property (nonatomic,strong) NSString *hisUserID; //单聊的话 就是对方userid（同时也是环信的id） 。群聊就是群组ID
@property (nonatomic,strong) NSString *hisName; ///单聊的话 就是对方姓名。群组的话为“”
@property (nonatomic,strong) NSString *hisPhoto; //单聊的话 就是对方头像。 群组为空的model
@property (nonatomic,assign) int type;

+ (void)pushChatViewController:(BaseViewController*)viewController targetid:(NSString *)targetid userId:(NSString*)hisUserID userName:(NSString*)hisName userPhoto:(NSString *)hisPhoto type:(int)type;
//- (void)reloadData;
@end
