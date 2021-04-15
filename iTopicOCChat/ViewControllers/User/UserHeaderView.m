//
//  GKDYHeaderView.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "UserHeaderView.h"
#import "ValueUtil.h"
#import "StringUtil.h"
#import "MineInfoPersonalViewController.h"

@interface UserHeaderView()

@property (nonatomic, assign) CGRect        bgImgFrame;


@property (nonatomic, strong) UILabel *followLabel;
@property (nonatomic, strong) UILabel *fansLabel;

@property (nonatomic, strong) UILabel *introLabel;

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *chatButton;
@property (nonatomic, strong) UIButton *followButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;


@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIView        *bottomView;


@end

@implementation UserHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImgView];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.iconImgView];
        
        self.bgImgFrame = CGRectMake(0, 0, frame.size.width, kDYBgImgHeight);
        self.bgImgView.frame = self.bgImgFrame;
        
        int screenWidth = SCREEN_WIDTH;
        
        self.contentView.frame = CGRectMake(0, kDYBgImgHeight, screenWidth, kDYHeaderHeight);
        self.iconImgView.frame = CGRectMake(15, -15.0f, 96.0f, 96.0f);
        
        self.followLabel = [[UILabel alloc] init];
        self.followLabel.textAlignment = NSTextAlignmentLeft;
        self.followLabel.font = [UIFont systemFontOfSize:16];
        self.followLabel.attributedText = [self resetFollowLabel:@"0" remark:@"关注"];
        [self.contentView addSubview:self.followLabel];
        self.followLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followLabelAction:)];
        [self.followLabel addGestureRecognizer:labelTapGestureRecognizer];
        CGRect frame = [self.followLabel.attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        self.followLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 20, 14, frame.size.width + 15, 20);
        
        
        self.fansLabel = [[UILabel alloc] init];
        self.fansLabel.textAlignment = NSTextAlignmentLeft;
        self.fansLabel.font = [UIFont systemFontOfSize:16];
        self.fansLabel.attributedText = [self resetFollowLabel:@"0" remark:@"粉丝"];
        self.fansLabel.userInteractionEnabled=YES;
        UITapGestureRecognizer *labelTapGestureRecognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(fansLabelAction:)];
        [self.fansLabel addGestureRecognizer:labelTapGestureRecognizer2];
        [self.contentView addSubview:self.fansLabel];
        
        CGRect frame2 = [self.followLabel.attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        self.fansLabel.frame = CGRectMake(CGRectGetMaxX(self.followLabel.frame) + 20, 14, frame2.size.width + 15, 20);
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.iconImgView.frame) + 15, screenWidth - 30, 20)];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont boldSystemFontOfSize:22];
        [self.contentView addSubview:self.nameLabel];
        
        self.introLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.nameLabel.frame) + 15, screenWidth - 30, 20)];
        self.introLabel.textAlignment = NSTextAlignmentLeft;
        self.introLabel.font = [UIFont systemFontOfSize:16];
        self.introLabel.numberOfLines = 0;
        [self.contentView addSubview:self.introLabel];
        
        self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 30)];
        [self.contentView addSubview:self.bottomView];
        
        if (@available(iOS 11.0, *)) {
            self.contentView.backgroundColor = [UIColor colorNamed:@"user_bg"];//background
            self.followLabel.textColor = [UIColor colorNamed:@"text_gray104"];
            self.fansLabel.textColor = [UIColor colorNamed:@"text_gray104"];
            self.introLabel.textColor = [UIColor colorNamed:@"text_gray104"];
            self.nameLabel.textColor = [UIColor colorNamed:@"black_white"];
        } else {
            self.contentView.backgroundColor = COLOR_BACKGROUND_RGB;
            self.followLabel.textColor = COLOR_GRAY_DARK_RGB;
            self.fansLabel.textColor = COLOR_GRAY_DARK_RGB;
            self.introLabel.textColor = COLOR_GRAY_DARK_RGB;
            self.nameLabel.textColor = [UIColor blackColor];
        }
    }
    return self;
}

- (void)createButtons:(BOOL)myself
{
    int screenWidth = SCREEN_WIDTH;
    float buttonItemWidth = (screenWidth - CGRectGetMaxX(self.iconImgView.frame) - 20 - 15 - 6) / 2;
    if (myself) {
        //当前是看我自己
        self.editButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 20, 49 , (screenWidth - CGRectGetMaxX(self.iconImgView.frame) - 20 - 15 ) , 32)];
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"white_btn"] forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:[UIImage imageNamed:@"gray_rect"] forState:UIControlStateHighlighted];
        [self.editButton setImage:[UIImage imageNamed:@"profile_icon_edit_normal"] forState:UIControlStateNormal];
        [self.editButton setTitle:@" 编辑资料 " forState:UIControlStateNormal];
        self.editButton.titleLabel.font = [UIFont systemFontOfSize:16];
        self.editButton.layer.borderWidth = 0.5;
        [self.editButton addTarget:self action:@selector(chatEditAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.editButton];
    } else {
        //当前是看别人
        self.chatButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 20, 49 , buttonItemWidth , 32)];
        [self.chatButton setBackgroundImage:[UIImage imageNamed:@"white_btn"] forState:UIControlStateNormal];
        [self.chatButton setBackgroundImage:[UIImage imageNamed:@"gray_rect"] forState:UIControlStateHighlighted];
        [self.chatButton setImage:[UIImage imageNamed:@"profile_icon_chat_normal"] forState:UIControlStateNormal];
        [self.chatButton setTitle:@" 私信 " forState:UIControlStateNormal];
        self.chatButton.titleLabel.font = [UIFont systemFontOfSize:16];
        self.chatButton.layer.borderWidth = 0.5;
        [self.chatButton addTarget:self action:@selector(chatClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.chatButton];
        
        self.followButton = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.chatButton.frame) + 8, 49 , buttonItemWidth , 32)];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"white_btn"] forState:UIControlStateNormal];
        [self.followButton setBackgroundImage:[UIImage imageNamed:@"gray_rect"] forState:UIControlStateHighlighted];
        [self.followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.followButton.titleLabel.font = [UIFont systemFontOfSize:16];
        self.followButton.layer.borderWidth = 0.5;
        [self.followButton addTarget:self action:@selector(followClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.followButton];

        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.followButton addSubview:_indicatorView];
        _indicatorView.center = CGPointMake(self.followButton.frame.size.width/2, self.followButton.frame.size.height/2);
        [self.followButton bringSubviewToFront:_indicatorView];
        
        [self loadingFollowView];
    }
    
    if (@available(iOS 11.0, *)) {
        self.followButton.layer.borderColor = [UIColor colorNamed:@"border223"].CGColor;
        self.editButton.layer.borderColor = [UIColor colorNamed:@"border223"].CGColor;
        self.chatButton.layer.borderColor = [UIColor colorNamed:@"border223"].CGColor;
        [self.chatButton setTitleColor:[UIColor colorNamed:@"black_white"] forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor colorNamed:@"black_white"] forState:UIControlStateNormal];
    } else {
        self.followButton.layer.borderColor = RGBCOLOR(223, 223, 223).CGColor;
        self.editButton.layer.borderColor = RGBCOLOR(223, 223, 223).CGColor;
        self.chatButton.layer.borderColor = RGBCOLOR(223, 223, 223).CGColor;
        [self.chatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (void)scrollViewDidScroll:(CGFloat)offsetY {
    CGRect frame = self.bgImgFrame;
    // 上下放大
    frame.size.height -= offsetY;
    frame.origin.y = offsetY;
    
    // 左右放大
    if (offsetY <= 0) {
        frame.size.width = frame.size.height * self.bgImgFrame.size.width / self.bgImgFrame.size.height;
        frame.origin.x   = (self.frame.size.width - frame.size.width) / 2;
    }
    
    self.bgImgView.frame = frame;
}

- (NSMutableAttributedString *)resetFollowLabel:(NSString *)value remark:(NSString *)remark
{
    UIColor *blackColor = nil;
    UIColor *grayColor = nil;
    if (@available(iOS 11.0, *)) {
        blackColor = [UIColor colorNamed:@"black_white"];
        grayColor = [UIColor colorNamed:@"text_gray104"];
    } else {
        blackColor = [UIColor blackColor];
        grayColor = COLOR_GRAY_DARK_RGB;
    }
    
    NSString *textString = [NSString stringWithFormat:@"%@ %@",value,remark];
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:textString];
    [str2 addAttribute:NSForegroundColorAttributeName value:blackColor range:NSMakeRange(0, value.length)];
    [str2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:22] range:NSMakeRange(0, value.length)];
    [str2 addAttributes:@{NSForegroundColorAttributeName:grayColor} range:NSMakeRange(textString.length - remark.length - 1,remark.length)];
    [str2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(textString.length - remark.length - 1,remark.length)];

    return str2;
}

- (float)setUserModel:(UserModel *)userModel
{
    self.nameLabel.text = userModel.name;
    
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:[ValueUtil getQiniuUrlByFileName:userModel.avatar  isThumbnail:YES]] placeholderImage:[UIImage imageNamed:@"user_photo"]];
    
    self.followLabel.attributedText = [self resetFollowLabel:[NSString stringWithFormat:@"%d",userModel.followcount] remark:@"关注"];
    CGRect frame = [self.followLabel.attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    self.followLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImgView.frame) + 20, 14, frame.size.width + 25, 20);
    
    self.fansLabel.attributedText = [self resetFollowLabel:[NSString stringWithFormat:@"%d",userModel.fanscount] remark:@"粉丝"];
    CGRect frame2 = [self.followLabel.attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    self.fansLabel.frame = CGRectMake(CGRectGetMaxX(self.followLabel.frame) + 10, 14, frame2.size.width + 50, 20);

    if ([userModel.userid isEqualToString:[USERMANAGER getUserId]]){
        //看我自己
    } else {
        _followStatus = userModel.follow;
        [self reloadFollowView];
    }
    
    NSString *introDisplay = [ValueUtil isEmptyString:userModel.intro]?@"没有填写个人介绍":userModel.intro;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 3;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    self.introLabel.attributedText = [[NSAttributedString alloc] initWithString:introDisplay attributes:attributes];
    
    CGSize introSize = [StringUtil boundingSizeForText:introDisplay maxWidth:self.introLabel.frame.size.width font:self.introLabel.font lineSpacing:3];
    self.introLabel.frame = CGRectMake(15, CGRectGetMaxY(self.nameLabel.frame) + 10, self.introLabel.frame.size.width, introSize.height + 1);
//    self.introLabel.text = introDisplay;

    UIColor *textColor = nil;
    if (@available(iOS 11.0, *)) {
        textColor = [UIColor colorNamed:@"text_gray104"];
    } else {
        textColor = COLOR_GRAY_DARK_RGB;
    }
    
    int currentX = 0;
    UIButton *genderButton;
    if (userModel.gender > 0) {
        genderButton = [[UIButton alloc]initWithFrame:CGRectMake(0 , 0 , 40 , 22)];
        [genderButton setBackgroundImage:[UIImage imageNamed:@"gray_rect"] forState:UIControlStateNormal];
        [genderButton setImage:[UIImage imageNamed:userModel.gender == 2?@"profile_icon_female_m_normal":@"profile_icon_male_m_normal"] forState:UIControlStateNormal];
        [genderButton setTitle:userModel.gender == 2?@" 女":@" 男" forState:UIControlStateNormal];
        [genderButton setTitleColor:textColor forState:UIControlStateNormal];
        genderButton.titleLabel.font = [UIFont systemFontOfSize:14];
        genderButton.layer.cornerRadius = 2;
        genderButton.layer.masksToBounds = YES;
        genderButton.userInteractionEnabled = NO;
        [self.bottomView addSubview:genderButton];
        currentX = CGRectGetMaxX(genderButton.frame) + 7;
    }
    
    UIButton *ageButton;
    if (userModel.age > 0) {
        ageButton = [[UIButton alloc]initWithFrame:CGRectMake(currentX , 0 , 40 , 22)];
        [ageButton setBackgroundImage:[UIImage imageNamed:@"gray_rect"] forState:UIControlStateNormal];
        [ageButton setTitle:[NSString stringWithFormat:@"%d岁",userModel.age] forState:UIControlStateNormal];
        [ageButton setTitleColor:textColor forState:UIControlStateNormal];
        ageButton.titleLabel.font = [UIFont systemFontOfSize:14];
        ageButton.layer.cornerRadius = 2;
        ageButton.layer.masksToBounds = YES;
        ageButton.userInteractionEnabled = NO;
        [self.bottomView addSubview:ageButton];
        currentX  = CGRectGetMaxX(ageButton.frame) + 7;
    }
    
    UIButton *cityButton;
    if (![ValueUtil isEmptyString:userModel.cityname]) {
        cityButton = [[UIButton alloc]init];
        [cityButton setBackgroundImage:[UIImage imageNamed:@"gray_rect"] forState:UIControlStateNormal];
        [cityButton setTitle:userModel.cityname forState:UIControlStateNormal];
        [cityButton setTitleColor:textColor forState:UIControlStateNormal];
        cityButton.titleLabel.font = [UIFont systemFontOfSize:14];
        cityButton.layer.cornerRadius = 2;
        cityButton.layer.masksToBounds = YES;
        cityButton.userInteractionEnabled = NO;
        cityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:cityButton];
        CGSize citySize = [StringUtil boundingSizeForText:userModel.cityname maxWidth:SCREEN_WIDTH font:cityButton.titleLabel.font lineSpacing:0];
        cityButton.frame = CGRectMake(currentX , 0 , citySize.width + 8, 22);
        currentX  = CGRectGetMaxX(cityButton.frame) + 7;
    }
    
    self.bottomView.frame = CGRectMake(15, CGRectGetMaxY(self.introLabel.frame) + 10, SCREEN_WIDTH - 30, currentX == 0?8:30);
    
    self.contentView.frame = CGRectMake(0, kDYBgImgHeight, SCREEN_WIDTH, CGRectGetMaxY(self.bottomView.frame));
    return CGRectGetMaxY(self.contentView.frame);
}

- (IBAction)followLabelAction:(id)sender
{
    [self.delegate onFollowLabelClick];
}

- (IBAction)fansLabelAction:(id)sender
{
    [self.delegate onFansLabelClick];
}


- (IBAction)chatEditAction:(id)sender
{
    [self.delegate onEditButtonClick];
}


- (IBAction)followClickAction:(id)sender
{
    [self loadingFollowView];
    [self.delegate onFollowButtonClick];
//    [HOMEMANAGER followMember:self.fo];
}

- (IBAction)chatClickAction:(id)sender
{
    [self.delegate onChatButtonClick];
}

- (IBAction)avatarClickAction:(id)sender
{
    [self.delegate onAvatarImageViewClick];
}

- (IBAction)coverClickAction:(id)sender
{
    [self.delegate onCoverImageViewClick];
}

- (void)loadingFollowView
{
    [_indicatorView startAnimating];
    _indicatorView.hidden = NO;
    [self.followButton setImage:nil forState:UIControlStateNormal];
    [self.followButton setTitle:@"" forState:UIControlStateNormal];
    self.followButton.userInteractionEnabled = NO;
}

- (void)reloadFollowView
{
    [_indicatorView stopAnimating];
    _indicatorView.hidden = YES;
    self.followButton.userInteractionEnabled = YES;
    switch (_followStatus) {
        case INT_FOLLOWTYPE_NONE:
        case INT_FOLLOWTYPE_MY_FANS:
            _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
            [self.followButton setBackgroundImage:[UIImage imageNamed:@"orange_rect"] forState:UIControlStateNormal];
            [self.followButton setBackgroundImage:[UIImage imageNamed:@"orange_press_rect"] forState:UIControlStateHighlighted];
            [self.followButton setImage:[UIImage imageNamed:@"profile_icon_follow_white_s_normal"] forState:UIControlStateNormal];
            [self.followButton setTitle:@" 关注" forState:UIControlStateNormal];
            [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            break;
            
        default:
            _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
            [self.followButton setBackgroundImage:[UIImage imageNamed:@"white_btn"] forState:UIControlStateNormal];
            [self.followButton setBackgroundImage:[UIImage imageNamed:@"gray_rect"] forState:UIControlStateHighlighted];
            [self.followButton setImage:[UIImage imageNamed:@"profile_icon_followed_black_m_normal"] forState:UIControlStateNormal];
            [self.followButton setTitle:_followStatus == INT_FOLLOWTYPE_MY_FOLLOWING?@" 已关注":@" 互相关注" forState:UIControlStateNormal];
            if (@available(iOS 11.0, *)) {
                [self.followButton setTitleColor:[UIColor colorNamed:@"black_white"] forState:UIControlStateNormal];
            } else {
                [self.followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            
            break;
    }
}

#pragma mark - 懒加载
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [UIImageView new];
        _bgImgView.image = [UIImage imageNamed:@"dy_bg"];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImgView.clipsToBounds = YES;
        _bgImgView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(coverClickAction:)];
        [_bgImgView addGestureRecognizer:tapGestureRecognizer];
    }
    return _bgImgView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = RGBCOLOR(248, 248, 246);
    }
    return _contentView;
}

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [UIImageView new];
        _iconImgView.image = [UIImage imageNamed:@"user_photo"];
        _iconImgView.layer.cornerRadius = 48.0f;
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.layer.borderColor = RGBCOLOR(248, 248, 246).CGColor;
        _iconImgView.layer.borderWidth = 3;
        
        _iconImgView.userInteractionEnabled=YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(avatarClickAction:)];
        [_iconImgView addGestureRecognizer:tapGestureRecognizer];
        
        [self.delegate onAvatarImageViewClick];
    }
    return _iconImgView;
}


@end
