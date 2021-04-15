//
//  GKDYViewController.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserViewController : BaseViewController

@property (nonatomic, strong) NSString *hisUserID;
@property (nonatomic, strong) NSString *hisAvatarModel;
@property (nonatomic, strong) NSString *hisRealName;

+ (void)pushToUser:(UIViewController *)viewController userid:(nullable NSString *)userid name:(nullable NSString*)name avatar:(nullable NSString *)avatar;

@end

NS_ASSUME_NONNULL_END
