//
//  FaceManager.h
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XHEmotionManager.h"

#define FACEMANAGER [FaceManager sharedFaceManager]
@interface FaceManager : NSObject
{
}

+ (id)sharedFaceManager;

@property (strong, nonatomic)NSDictionary *emojiDictionary;

@property (strong, nonatomic)NSArray<XHEmotionManager *> *emotionManagerArray;

- (NSMutableAttributedString *)convertTextEmotionToAttachment:(NSString *)text font:(UIFont *)font;

@end
