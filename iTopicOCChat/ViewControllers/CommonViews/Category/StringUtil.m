//
//  LLUtils+Text.m
//  LLWeChat
//
//  Created by GYJZH on 9/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "StringUtil.h"


@implementation StringUtil

+ (NSString *)sizeStringWithStyle:(id)style size:(long long)size {
    if (size < 1024 * 1024) {
        return [NSString stringWithFormat:@"%ldK", (long)size/1024];
    }else {
        return [NSString stringWithFormat:@"%.1fM", size/(1024 * 1024.0)];
    }
}


+ (CGSize)boundingSizeForText:(NSString *)text maxWidth:(CGFloat)maxWidth font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing {
    CGSize calSize = CGSizeMake(maxWidth, MAXFLOAT);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = lineSpacing;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName:font,
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    
    
    CGRect rect = [text boundingRectWithSize:calSize
                                     options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading
                                  attributes:attributes
                                     context:nil];
    
    return rect.size;
}

+ (CGFloat)widthForSingleLineString:(NSString *)text font:(UIFont *)font {
    //    stringWidth =[text
    //            boundingRectWithSize:size
    //                         options:NSStringDrawingUsesLineFragmentOrigin
    //                      attributes:@{NSFontAttributeName:self.font}
    //                         context:nil].size.width;
    
    CGRect rect = [text
                   boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                   options:0
                   attributes:@{NSFontAttributeName:font}
                   context:nil];
    return rect.size.width;
    
}


//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstPinyinLetterOfString:(NSString *)aString
{
    if (aString.length == 0)
        return nil;
    
    //首字符就是字母
    unichar C = [aString characterAtIndex:0];
    if((C<= 'Z' && C>='A') || (C <= 'z' && C >= 'a')) {
        //转化为大写拼音
        NSString *pinYin = [[aString substringToIndex:1] capitalizedString];
        //获取并返回首字母
        return pinYin;
    }
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:[aString substringToIndex:1]];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
+ (NSString *)firstPinyinCharactorOfString:(NSString *)aString
{
    if (aString.length == 0)
        return nil;
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:[aString substringToIndex:1]];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return pinYin;
}


//获取拼音
+ (NSString *)pinyinOfString:(NSString *)aString
{
    if (aString.length == 0)
        return nil;
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return pinYin;
}


/**
 绘制图片
 
 @param color 背景色
 @param size 大小
 @param text 文字
 @param textAttributes 字体设置
 @param isCircular 是否圆形
 @return 图片
 */
+ (UIImage *)drawImageWithColor:(UIColor *)color
                          size:(CGSize)size
                          text:(NSString *)text
                textAttributes:(NSDictionary<NSAttributedStringKey, id> *)textAttributes
                      circular:(BOOL)isCircular
{
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // circular
    if (isCircular) {
        CGPathRef path = CGPathCreateWithEllipseInRect(rect, NULL);
        CGContextAddPath(context, path);
        CGContextClip(context);
        CGPathRelease(path);
    }
    
    // color
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    // text
    CGSize textSize = [text sizeWithAttributes:textAttributes];
    [text drawInRect:CGRectMake((size.width - textSize.width) / 2, (size.height - textSize.height) / 2, textSize.width, textSize.height) withAttributes:textAttributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
