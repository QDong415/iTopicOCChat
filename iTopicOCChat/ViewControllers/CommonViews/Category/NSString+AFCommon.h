//
//  NSString+AFCommon.h
//  AFCommon
//
//  Created by QDong Email: 285275534@qq.com on 13-3-29.
//  Copyright (c) 2013年 ManGang. All rights reserved.
//

@interface NSString (AFCommon)

- (uint32_t)intHexValue;

- (NSString *)md5String;

+ (NSString *)uniqueString;

//IP 转化为unsigned int 类型
- (uint32_t)ipToInt;

+ (NSString *)stringFromIPInt:(uint32_t)ipInt;

//macAddress 转化为 NSData 类型（十六进制）
- (NSData*)macToData;

+ (NSString *)stringFromMacData:(NSData*)macData;
/** Returns `YES` if a string is a valid email address, otherwise `NO`.
 @return True if the string is formatted properly as an email address.
 */
- (BOOL) isValidateEmail;

/** Returns a `NSString` that properly replaces HTML specific character sequences.
 @return An escaped HTML string.
 */
- (NSString *) escapeHTML;

/** Returns a `NSString` that properly formats text for HTML.
 @return An unescaped HTML string.
 */
- (NSString *) unescapeHTML;

/** Returns a `NSString` that removes HTML elements.
 @return Returns a string without the HTML elements.
 */
- (NSString*) stringByRemovingHTML;


@end
