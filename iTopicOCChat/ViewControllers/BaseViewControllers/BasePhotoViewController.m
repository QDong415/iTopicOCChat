//
//  VPViewController.m
//  VPImageCropperDemo
//
//  Created by Vinson.D.Warm on 1/13/14.
//  Copyright (c) 2014 Vinson.D.Warm. All rights reserved.
//

#import "BasePhotoViewController.h"

#import <Photos/Photos.h>
#import "QiniuUploadManager.h"
#import "QiniuSDK.h"
#import "ZLPhotoActionSheet.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface BasePhotoViewController ()
{
    BOOL _cropPicture;
}
@end


@implementation BasePhotoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)editPortrait:(BOOL)cropPicture{
    _cropPicture = cropPicture;
    
    [[self photoActionSheet] showPhotoLibrary];
}

- (ZLPhotoActionSheet *)photoActionSheet
{
    ZLPhotoActionSheet *_photoActionSheet = [[ZLPhotoActionSheet alloc] init];
    //设置照片最大预览数
    _photoActionSheet.configuration.maxPreviewCount = 20;
    //设置照片最大选择数
    _photoActionSheet.configuration.maxSelectCount = 1;
    //    pickerVc.selectPickers = _formPhotoGridViewModel.photoArray;
    _photoActionSheet.configuration.allowSelectVideo = NO;
    _photoActionSheet.sender = self;
    _photoActionSheet.configuration.allowSelectGif = NO;
    _photoActionSheet.configuration.allowEditImage = YES;
    _photoActionSheet.configuration.saveNewImageAfterEdit = NO;
    _photoActionSheet.configuration.allowSelectOriginal = NO;
    _photoActionSheet.configuration.clipRatios = [self clipRatios];
    _photoActionSheet.configuration.editAfterSelectThumbnailImage = YES;
    _photoActionSheet.configuration.navBarColor = [[UINavigationBar appearance] barTintColor];
    _photoActionSheet.configuration.navTitleColor = [[UINavigationBar appearance] tintColor];
    _photoActionSheet.configuration.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    _photoActionSheet.configuration.bottomBtnsNormalTitleColor = [UIColor whiteColor];
    WEAKSELF;
    
    [_photoActionSheet setSelectImageBlock:^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets, BOOL isOriginal) {
        //选好了
        [weakSelf onPhotoSelected:images[0]];
        
        [weakSelf uploadPicture:UIImageJPEGRepresentation(images[0], 0.9)];
    }];
    return _photoActionSheet;
}

- (NSArray *)clipRatios{
    return [NSArray arrayWithObjects:GetClipRatio(1,1), nil];
}

- (void) uploadPicture:(NSData *)imageData
{
    [ProgressHUD show:@"上传图片"];
    
    WEAKSELF;
    [QINIUMANAGER getTokenApi:@"qiniu/uploadtoken" parameters:[NSDictionary dictionary] withSuccessBlock:^(NSString *token){
        
        QNUploadManager *upManager = [QINIUMANAGER createUpManager];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *currentTime = [dateFormatter stringFromDate:[NSDate date]];
        
        //先生成随机文件名字
        char data[7];
        for (int x=0;x<7;data[x++] = (char)('A' + (arc4random_uniform(26))));
        NSString *lastname = [[NSString alloc] initWithBytes:data length:7 encoding:NSUTF8StringEncoding];;
        NSString *key = [NSString stringWithFormat:@"user-%@-%@",currentTime,lastname];
        
        QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
            //                NSLog(@"percent == %.2f", percent);
            dispatch_async(dispatch_get_main_queue(), ^{
                [ProgressHUD reloadText:[NSString stringWithFormat:@"%.2f%%",percent * 100]];
            });
        }params:[NSDictionary dictionary] checkCrc:NO cancellationSignal:nil];
        
        //一个一个上传
        [upManager putData:imageData key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
            
            if (resp) {
                [weakSelf onPhotoUploadSuccess:key resultDictionary:resp];
            }else{
                [weakSelf onPhotoUploadFailed];
            }
        } option:uploadOption];
        
    } andFailBlock:^(int code,NSString *message){
        [ProgressHUD dismiss];
        [weakSelf onPhotoUploadFailed];
    }];
}

- (void)onPhotoUploadFailed
{
    
}

- (void)onPhotoUploadSuccess:(NSString *)fileName resultDictionary:(NSDictionary *)resp
{
    
}

- (void)onPhotoSelected:(UIImage *)compressedImage
{
    
}



@end
