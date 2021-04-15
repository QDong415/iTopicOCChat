//
// Copyright (c) 2013 Related Code - http://relatedcode.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProgressHUD.h"

@implementation ProgressHUD

@synthesize window, hud, spinner, image, label,tranBackground;
bool isShowing,isShowingToast;

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (ProgressHUD *)shared
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	static dispatch_once_t once = 0;
	static ProgressHUD *progressHUD;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	dispatch_once(&once, ^{ progressHUD = [[ProgressHUD alloc] init]; });
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return progressHUD;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)dismiss
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[self shared] hudHide];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)show:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[self shared] hudMake:status imgage:nil spin:YES hide:NO];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showSuccess:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[self shared] hudMakeTost:status imgage:HUD_IMAGE_SUCCESS];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)showError:(NSString *)status
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [[self shared] hudMakeTost:!status?@"网络访问失败":status imgage:HUD_IMAGE_ERROR];
}

+ (void)reloadText:(NSString *)string
{
    [self shared].label.text = string;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	id<UIApplicationDelegate> delegate = [[UIApplication sharedApplication] delegate];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    
	if ([delegate respondsToSelector:@selector(window)])
		window = [delegate performSelector:@selector(window)];
	else window = [[UIApplication sharedApplication] keyWindow];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    tranBackground = nil ; hud = nil; spinner = nil; image = nil; label = nil;
	//---------------------------------------------------------------------------------------------------------------------------------------------
    isShowing = NO;isShowingToast = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudMake:(NSString *)status imgage:(UIImage *)img spin:(BOOL)spin hide:(BOOL)hide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (!hide) {
        if (tranBackground == nil) {
            tranBackground = [[UIView alloc]initWithFrame:window.frame];
        }
        if (tranBackground.superview == nil)
        {
            [window addSubview:tranBackground];
        }
    }
    
    
    if (hud == nil)
    {
        hud = [[UIToolbar alloc] initWithFrame:CGRectZero];
        hud.barTintColor = HUD_BACKGROUND_COLOR;
        hud.translucent = YES;
        hud.layer.cornerRadius = 10;
        hud.layer.masksToBounds = YES;
        //-----------------------------------------------------------------------------------------------------------------------------------------
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    if (hud.superview == nil)
    {
        if (!hide) {
            [tranBackground addSubview:hud];
        }else{
            [window addSubview:hud];
        }
        
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (spinner == nil)
    {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.color = HUD_SPINNER_COLOR;
        spinner.hidesWhenStopped = YES;
    }
    if (spinner.superview == nil) [hud addSubview:spinner];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (image == nil)
    {
        image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    }
    if (image.superview == nil) [hud addSubview:image];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (label == nil)
    {
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = HUD_STATUS_FONT;
        label.textColor = HUD_STATUS_COLOR;
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.numberOfLines = 0;
    }
    if (label.superview == nil) [hud addSubview:label];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	label.text = status;
	label.hidden = (status == nil) ? YES : NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	image.image = img;
	image.hidden = (img == nil) ? YES : NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (spin) [spinner startAnimating]; else [spinner stopAnimating];
	//---------------------------------------------------------------------------------------------------------------------------------------------
    [self hudOrient:hud];
    [self hudSize:hud label:label image:image activity:spinner];
    [self hudShow:hud label:label hide:hide];

}

- (void)hudMakeTost:(NSString *)status imgage:(UIImage *)img
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (_toastHud == nil)
    {
        _toastHud = [[UIToolbar alloc] initWithFrame:CGRectZero];
        _toastHud.barTintColor = HUD_BACKGROUND_COLOR;
        _toastHud.translucent = YES;
        _toastHud.layer.cornerRadius = 10;
        _toastHud.layer.masksToBounds = YES;
    }
    if (_toastHud.superview == nil)
    {
         [window addSubview:_toastHud];
    }
     if (_toastImageView == nil)
    {
        _toastImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    }
    if (_toastImageView.superview == nil) [_toastHud addSubview:_toastImageView];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (_toastLabel == nil)
    {
        _toastLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toastLabel.font = HUD_STATUS_FONT;
        _toastLabel.textColor = HUD_STATUS_COLOR;
        _toastLabel.backgroundColor = [UIColor clearColor];
        _toastLabel.textAlignment = NSTextAlignmentCenter;
        _toastLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _toastLabel.numberOfLines = 0;
    }
    if (_toastLabel.superview == nil) [_toastHud addSubview:_toastLabel];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    _toastLabel.text = status;
    _toastLabel.hidden = (status == nil) ? YES : NO;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    _toastImageView.image = img;
    _toastImageView.hidden = (img == nil) ? YES : NO;
    [self hudOrient:_toastHud];
    [self hudSize:_toastHud label:_toastLabel image:_toastImageView activity:nil];
    [self hudShowToast:_toastHud label:_toastLabel hide:YES];
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudDestroy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[label removeFromSuperview];	label = nil;
	[image removeFromSuperview];	image = nil;
	[spinner removeFromSuperview];	spinner = nil;
	[hud removeFromSuperview];		hud = nil;
    [tranBackground removeFromSuperview];		tranBackground = nil;
    
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)rotate:(NSNotification *)notification
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self hudOrient:hud];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudOrient:(UIToolbar *)_hud
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGFloat rotate = 0.0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIInterfaceOrientation orient = [[UIApplication sharedApplication] statusBarOrientation];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (orient == UIInterfaceOrientationPortrait)			rotate = 0.0;
	if (orient == UIInterfaceOrientationPortraitUpsideDown)	rotate = M_PI;
	if (orient == UIInterfaceOrientationLandscapeLeft)		rotate = - M_PI_2;
	if (orient == UIInterfaceOrientationLandscapeRight)		rotate = + M_PI_2;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	_hud.transform = CGAffineTransformMakeRotation(rotate);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudSize:(UIToolbar *)_hud label:(UILabel *)_label image:(UIImageView *)_image activity:(UIActivityIndicatorView *)_spinner
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect labelRect = CGRectZero;
	CGFloat hudWidth = 100, hudHeight = 100;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (_label.text != nil)
	{
		NSDictionary *attributes = @{NSFontAttributeName:_label.font};
		NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin;
		labelRect = [_label.text boundingRectWithSize:CGSizeMake(200, 300) options:options attributes:attributes context:NULL];

		labelRect.origin.x = 12;
		labelRect.origin.y = 66;

		hudWidth = labelRect.size.width + 24;
		hudHeight = labelRect.size.height + 80;

		if (hudWidth < 100)
		{
			hudWidth = 100;
			labelRect.origin.x = 0;
			labelRect.size.width = 100;
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGSize screen = [UIScreen mainScreen].bounds.size;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	_hud.center = CGPointMake(screen.width/2, screen.height/2);
	_hud.bounds = CGRectMake(0, 0, hudWidth, hudHeight);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGFloat imagex = hudWidth/2;
	CGFloat imagey = (_label.text == nil) ? hudHeight/2 : 36;
	_image.center = _spinner.center = CGPointMake(imagex, imagey);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	_label.frame = labelRect;
  

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudShow:(UIToolbar *)_hud label:(UILabel *)_label hide:(BOOL)hide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (!isShowing)
	{
		isShowing = YES;

		_hud.alpha = 0;
		_hud.transform = CGAffineTransformScale(_hud.transform, 1.4, 1.4);

		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;

		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			_hud.transform = CGAffineTransformScale(_hud.transform, 1/1.4, 1/1.4);
			_hud.alpha = 1;
		}
		completion:^(BOOL finished){
            if (hide) {
                double length = _label.text.length;
                NSTimeInterval sleep = length * 0.05 + 1.0;
                [self performSelector:@selector(hudHide) withObject:nil afterDelay:sleep];
            }
        }];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudHide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (isShowing)
	{
		NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;

		[UIView animateWithDuration:0.15 delay:0 options:options animations:^{
			hud.transform = CGAffineTransformScale(hud.transform, 0.7, 0.7);
			hud.alpha = 0;
		}
		completion:^(BOOL finished)
		{
			[self hudDestroy];
			isShowing = NO;
		}];
	}
}



- (void)hudShowToast:(UIToolbar *)_hud label:(UILabel *)_label hide:(BOOL)hide
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (!isShowingToast)
    {
        isShowingToast = YES;
        
        _hud.alpha = 0;
        _hud.transform = CGAffineTransformScale(_hud.transform, 1.4, 1.4);
        
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut;
        
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            _hud.transform = CGAffineTransformScale(_hud.transform, 1/1.4, 1/1.4);
            _hud.alpha = 1;
        }
                         completion:^(BOOL finished){
                             if (hide) {
                                 double length = _label.text.length;
                                 NSTimeInterval sleep = length * 0.05 + 1.0;
                                 [self performSelector:@selector(hudHideToast) withObject:nil afterDelay:sleep];
                             }
                         }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)hudHideToast
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (isShowingToast)
    {
        NSUInteger options = UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn;
        
        [UIView animateWithDuration:0.15 delay:0 options:options animations:^{
            _toastHud.transform = CGAffineTransformScale(_toastHud.transform, 0.7, 0.7);
            _toastHud.alpha = 0;
        }
                         completion:^(BOOL finished)
         {
             [self hudDestroyToast];
             isShowingToast = NO;
         }];
    }
}

- (void)hudDestroyToast
{
    [_toastLabel removeFromSuperview];	_toastLabel = nil;
    [_toastImageView removeFromSuperview];	_toastImageView = nil;
    [_toastHud removeFromSuperview];		_toastHud = nil;
 
}

@end
