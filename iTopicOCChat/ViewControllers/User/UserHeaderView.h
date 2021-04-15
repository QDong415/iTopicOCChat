//
//  GKDYHeaderView.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@protocol HeaderActionDelegate <NSObject>

- (void)onChatButtonClick;

- (void)onFollowButtonClick;

- (void)onAvatarImageViewClick;

- (void)onEditButtonClick;

- (void)onCoverImageViewClick;

- (void)onFollowLabelClick;

- (void)onFansLabelClick;

@end

#define kDYHeaderHeight (SCREEN_WIDTH * 240.0f / 345.0f)
#define kDYBgImgHeight  (SCREEN_WIDTH * 130.0f / 345.0f)

@interface UserHeaderView : UIView

@property (nonatomic, strong) UIImageView   *bgImgView;
@property (nonatomic, strong) UIImageView *iconImgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (weak, nonatomic) id <HeaderActionDelegate> delegate;
@property (nonatomic, assign) int followStatus;

- (void)scrollViewDidScroll:(CGFloat)offsetY;

- (float)setUserModel:(UserModel *)userModel;

- (void)reloadFollowView;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)createButtons:(BOOL)myself;

@end

NS_ASSUME_NONNULL_END
