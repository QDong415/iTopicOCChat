//
//  FaceManager.m
//  pinpin
//
//  Created by DongJin on 15-7-15.
//  Copyright (c) 2015年 ibluecollar. All rights reserved.
//

#import "FaceManager.h"

@implementation FaceManager

+ (id)sharedFaceManager{
    static FaceManager *_sharedFaceManager=nil;
    static dispatch_once_t predUser;
    dispatch_once(&predUser, ^{
        _sharedFaceManager=[[FaceManager alloc] init];
        
        NSString *plistStr = [[NSBundle mainBundle]pathForResource:@"emoji" ofType:@"plist"];
        _sharedFaceManager.emojiDictionary = [[NSDictionary  alloc]initWithContentsOfFile:plistStr];
       
    });
    return _sharedFaceManager;
}


- (NSMutableAttributedString *)convertTextEmotionToAttachment:(NSString *)text font:(UIFont *)font {
    NSError *error;
    NSRegularExpression *regularExpression =
    [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                              options:kNilOptions
                                                error:&error];
    
    NSArray<NSTextCheckingResult *> *emojis = [regularExpression matchesInString:text
                                                                         options:NSMatchingWithTransparentBounds
                                                                           range:NSMakeRange(0, [text length])];
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    int location = 0;
    for (NSTextCheckingResult *result in emojis) {
        NSRange range = result.range;
        NSString *subStr = [text substringWithRange:NSMakeRange(location, range.location - location)];
        NSMutableAttributedString *attSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attributeString appendAttributedString:attSubStr];
        location = (int)range.location + (int)range.length;
        NSString *emojiKey = [text substringWithRange:range];
        NSString *imageName = self.emojiDictionary[emojiKey];
        if (imageName) {
            NSTextAttachment *attachMent = [[NSTextAttachment alloc] init];
            UIImage *image = [UIImage imageNamed:imageName];
            attachMent.image = image;
            attachMent.bounds = CGRectMake(0, font.descender, font.lineHeight, font.lineHeight);
            
            NSAttributedString *str = [NSAttributedString attributedStringWithAttachment:attachMent];
            [attributeString appendAttributedString:str];
        } else {
            NSMutableAttributedString *originalStr = [[NSMutableAttributedString alloc] initWithString:emojiKey];
            [attributeString appendAttributedString:originalStr];
        }
    }
    
    if (location < [text length]) {
        NSRange range = NSMakeRange(location, [text length] - location);
        NSString *subStr = [text substringWithRange:range];
        NSMutableAttributedString *attrSubStr = [[NSMutableAttributedString alloc] initWithString:subStr];
        [attributeString appendAttributedString:attrSubStr];
    }
    
    return attributeString;
}

- (NSArray<XHEmotionManager *> *)emotionManagerArray
{
    if (!_emotionManagerArray) {
        XHEmotionManager *emotionManager = [[XHEmotionManager alloc] init];
        emotionManager.emotionBarLogoImageName = @"emotionbar_qq_logo";
        NSMutableArray *emotionImageNames = [NSMutableArray array];
        for (int i = 1; i < 21; i ++) {
            [emotionImageNames addObject:[NSString stringWithFormat:@"Expression_%d",i]];
        }
        
        for (int i = 101; i < 111; i ++) {
            [emotionImageNames addObject:[NSString stringWithFormat:@"Expression_%d",i]];
        }
        [emotionImageNames addObject:@"Watermelon"];
        [emotionImageNames addObject:@"Addoil"];
        [emotionImageNames addObject:@"Sweat"];
        [emotionImageNames addObject:@"Shocked"];
        [emotionImageNames addObject:@"Cold"];
        [emotionImageNames addObject:@"Social"];
        [emotionImageNames addObject:@"NoProb"];
        [emotionImageNames addObject:@"Slap"];
        [emotionImageNames addObject:@"KeepFighting"];
        [emotionImageNames addObject:@"Boring"];
        [emotionImageNames addObject:@"666"];
        [emotionImageNames addObject:@"LetMeSee"];
        [emotionImageNames addObject:@"Sigh"];
        [emotionImageNames addObject:@"Hurt"];
        [emotionImageNames addObject:@"Broken"];
        
        for (int i = 21; i < 92; i ++) {
            [emotionImageNames addObject:[NSString stringWithFormat:@"Expression_%d",i]];
        }
        
        emotionManager.emotionImageNames = emotionImageNames;
        _emotionManagerArray = [NSArray arrayWithObject:emotionManager];
    }
    return _emotionManagerArray;
}

@end
