//
//  LLUtils+Text.h
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#define URL_MAIL_SCHEME @"mailto"
#define URL_HTTP_SCHEME @"http"
#define URL_HTTPS_SCHEME @"https"


@interface StringUtil : NSObject
{
}

+ (CGFloat)widthForSingleLineString:(NSString *)text font:(UIFont *)font;

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstPinyinLetterOfString:(NSString *)aString;
//获取拼音
+ (NSString *)pinyinOfString:(NSString *)aString;

+ (NSString *)sizeStringWithStyle:(nullable id)style size:(long long)size;

+ (CGSize)boundingSizeForText:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing;


+ (UIImage *)drawImageWithColor:(UIColor *)color
          size:(CGSize)size
          text:(NSString *)text
textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes
                       circular:(BOOL)isCircular;
@end

