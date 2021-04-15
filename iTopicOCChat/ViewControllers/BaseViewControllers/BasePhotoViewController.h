//
//  VPViewController.h
//  VPImageCropperDemo
//
//  Created by Vinson.D.Warm on 1/13/14.
//  Copyright (c) 2014 Vinson.D.Warm. All rights reserved.
//

#import "QMUICommonTableViewController.h"
@interface BasePhotoViewController : QMUICommonTableViewController
- (void)editPortrait:(BOOL)cropPicture;
- (void)uploadPicture:(NSData *)imageData;
@end
