//
//  GoodsModel.m
//  XLPagerTabStrip
//
//  Created by DongJin on 15-6-1.
//  Copyright (c) 2015年 Xmartlabs. All rights reserved.
//

#import "ChatModel.h"
#import "LLSimpleTextLabel.h"
#import "LLMessageTextCell.h"
#import "LLMessageDateCell.h"
#import "LLMessageImageCell.h"
#import "LLMessageCallCell.h"
#import "LLMessageVoiceCell.h"

@interface ChatModel ()

@property (nonatomic, strong) UIImage *thumbnailImage;

@end

@implementation ChatModel

//jsonmodel 设置所有的属性为可选(所有属性值可以为空)
+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

- (void)processModelForCell {
    
    if (self.type == TYPE_CHAT_SINGLE || self.type == TYPE_CHAT_GROUP) {
        if (self.subtype == SUBTYPE_TEXT){
            
            UIColor *textColor = nil;
            if (@available(iOS 11.0, *)) {
                textColor = _issender == 1?[UIColor blackColor]:[UIColor colorNamed:@"text_black_gray"];
            } else {
                textColor = [UIColor blackColor];
            }
            
            self.attributedText = [LLSimpleTextLabel createAttributedStringWithEmotionString:self.content font:[LLMessageTextCell font] lineSpacing:0 textColor:textColor];
            
            self.cellHeight = [LLMessageTextCell heightForModel:self];
        } else if (self.subtype == SUBTYPE_IMAGE){
            NSDictionary *payloadDictionary = [NSJSONSerialization JSONObjectWithData:[_extend dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

            self.thumbnailImageSize = [LLMessageImageCell thumbnailSize:CGSizeMake([payloadDictionary[@"width"] intValue], [payloadDictionary[@"height"] intValue])];
            self.cellHeight = [LLMessageImageCell heightForModel:self];
            
        } else if (self.subtype == SUBTYPE_VOICE){
            NSDictionary *payloadDictionary = [NSJSONSerialization JSONObjectWithData:[_extend dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

            self.mediaDuration = [payloadDictionary[@"duration"] intValue];
            self.isMediaPlayed = NO;
            self.isMediaPlaying = NO;
            self.isMediaPlayed = [payloadDictionary[@"played"] boolValue];
            self.cellHeight = [LLMessageVoiceCell heightForModel:self];
                   
        } else if (self.subtype == SUBTYPE_CALL_AUDIO || self.subtype == SUBTYPE_CALL_VIDEO ){
            
            UIColor *textColor = nil;
            if (@available(iOS 11.0, *)) {
                textColor = _issender == 1?[UIColor blackColor]:[UIColor colorNamed:@"text_black_gray"];
            } else {
                textColor = [UIColor blackColor];
            }
            
            self.attributedText = [LLSimpleTextLabel createAttributedStringWithEmotionString:self.content font:[LLMessageCallCell font] lineSpacing:0 textColor:textColor];
                       
            self.cellHeight = [LLMessageCallCell heightForModel:self];
            
        } else if (self.subtype == SUBTYPE_GIFT){
//            NSDictionary *payloadDictionary = [NSJSONSerialization JSONObjectWithData:[_extend dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];

            self.thumbnailImageSize = CGSizeMake(IMAGE_MAX_SIZE,IMAGE_MAX_SIZE);
            self.cellHeight = [LLMessageImageCell heightForModel:self];
            
        }
    } else if (self.type == TYPE_CHAT_TIPS){
        self.cellHeight = [LLMessageDateCell heightForModel:self];
    }
}

- (UIImage *)findThumbnailImage {
    if (!_thumbnailImage) {
        if (_issender == 1) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *boxpath = [paths objectAtIndex:0];
            _thumbnailImage = [UIImage imageWithContentsOfFile:[boxpath stringByAppendingPathComponent:_filename]];
        } else {
            
        }

    }
    return _thumbnailImage;
}

@end
