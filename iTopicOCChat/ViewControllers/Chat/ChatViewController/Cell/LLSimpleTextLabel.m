//
//  LLSimpleTextLabel.m
//  LLWeChat
//
//  Created by GYJZH on 8/10/16.
//  Copyright © 2016 GYJZH. All rights reserved.
//

#import "LLSimpleTextLabel.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#import "FaceManager.h"
#import "StringUtil.h"

#define kAtRegex @"@([\u4E00-\u9FA5A-Za-z0-9_.-]+)"
#define URL_MAIL_SCHEME @"mailto"
#define URL_HTTP_SCHEME @"http"
#define URL_HTTPS_SCHEME @"https"

#define TOUCH_DELAYED_TIME 0.2

@interface LLLabelGestureRecognizer : UIGestureRecognizer

- (void)swallowTouch;

@end

@interface LLLabelRichTextData ()

@property (nonatomic) NSMutableArray<NSValue *> *rects;

@end

@implementation LLLabelRichTextData

- (instancetype)initWithType:(LLLabelRichTextType)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    
    return self;
}

@end


@interface LLSimpleTextLabel ()  <UIGestureRecognizerDelegate>
@property (nonatomic) UIColor *selectedBackgroundColor; //用户选中时的背景颜色
@property (nonatomic) LLLabelRichTextData *data;

@property (nonatomic) NSMutableArray<LLLabelRichTextData *> *totalRichTextDatas;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic) LLLabelGestureRecognizer *labelGestureRecognizer;

@property (nonatomic) NSTimer *timer;

@end

@implementation LLSimpleTextLabel {
    UIGestureRecognizerState longPressGestureRecognizerState;
    BOOL hasParsedRects;
    UIEdgeInsets userDefinedEdgeInset;
    NSMutableDictionary<NSNumber *, LLLabelRichTextData *> *cache;
    dispatch_block_t delayBlock;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self create];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self create];
    }
    
    return self;
}

- (void)create{
    _data = nil;
    cache = [NSMutableDictionary dictionary];
    _totalRichTextDatas = [NSMutableArray array];
    _selectedBackgroundColor = [UIColor colorWithWhite:0.4 alpha:0.3];
    
    _longPressDuration = 0.8;
    _tapGestureRecognizer = [self addTapGestureRecognizer:@selector(tapHandler:)];
    _tapGestureRecognizer.delaysTouchesBegan = NO;
    _tapGestureRecognizer.delaysTouchesEnded = NO;
    _tapGestureRecognizer.cancelsTouchesInView = YES;
    _tapGestureRecognizer.delegate = self;
    
    _labelGestureRecognizer = [[LLLabelGestureRecognizer alloc] initWithTarget:self action:@selector(labelGestureHandler:)];
    _labelGestureRecognizer.delaysTouchesBegan = NO;
    _labelGestureRecognizer.delaysTouchesEnded = NO;
    _labelGestureRecognizer.cancelsTouchesInView = YES;
    _labelGestureRecognizer.delegate = self;
    [self addGestureRecognizer:_labelGestureRecognizer];
    
    longPressGestureRecognizerState = UIGestureRecognizerStatePossible;
    [self.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc {
    [self.panGestureRecognizer removeObserver:self forKeyPath:@"state"];
}

//FIXME:SDK自带的DataDetector对URL识别并不是太精确
//目前该方法只由layoutSubviews首次的时候调用
- (void)parseText:(NSAttributedString *)attributedString {
    
    NSDate *startTime = [NSDate date];
    
    [self.totalRichTextDatas removeAllObjects];
   
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink
                                                               error:&error];
    NSArray *matches = [detector matchesInString:attributedString.string
                                         options:kNilOptions
                                           range:NSMakeRange(0, attributedString.string.length)];
    
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
    
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            if ([url.scheme isEqualToString:URL_MAIL_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTP_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTPS_SCHEME]) {
                LLLabelRichTextData *data = [[LLLabelRichTextData alloc] initWithType:kLLLabelRichTextTypeURL];
                data.range = matchRange;
                data.url = url;
                data.rects = [self calculateRectsForCharacterRange:matchRange];
                [self.totalRichTextDatas addObject:data];
            } else {
                continue;
            }
        
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            NSString *phoneNumber = [match phoneNumber];
            
            LLLabelRichTextData *data = [[LLLabelRichTextData alloc] initWithType:kLLLabelRichTextTypePhoneNumber];
            data.range = matchRange;
            data.phoneNumber = phoneNumber;
            data.rects = [self calculateRectsForCharacterRange:matchRange];
            
            [self.totalRichTextDatas addObject:data];
            
        }
    }
    
    //解析@人的正则
    if (self.atRegexEnable){
        NSError *error = nil;
        NSRegularExpression *atRegular = [NSRegularExpression regularExpressionWithPattern:kAtRegex options:NSRegularExpressionCaseInsensitive error:&error];
        
        NSArray *resultArray = [atRegular matchesInString:self.text options:0 range:NSMakeRange(0, self.text.length)];
//                    NSLog(@"解析后数=%d ； fisrt = %c",[resultArray count],[self.text characterAtIndex:0 ]);
        for(NSTextCheckingResult *match in resultArray) {
            NSRange range = [match range];
            
            LLLabelRichTextData *data = [[LLLabelRichTextData alloc] initWithType:kLLLabelRichTextTypeAt];
            data.range = range;
            data.phoneNumber = [self.text substringWithRange:range];
            data.rects = [self calculateRectsForCharacterRange:range];
            [self.totalRichTextDatas addObject:data];
        }
    } else {

    }
    
    //加入自定义的
    if (self.customerRichTextDatas) {
        for (LLLabelRichTextData *customerData in self.customerRichTextDatas) {
            customerData.rects = [self calculateRectsForCharacterRange:customerData.range];
        }

        [self.totalRichTextDatas addObjectsFromArray:self.customerRichTextDatas];
    }
    
}

- (void)setCustomerRichTextDatas:(NSMutableArray<LLLabelRichTextData *> *)customerRichTextDatas
{
    for (int i = (int)self.totalRichTextDatas.count - 1; i >= 0; i--) {
        LLLabelRichTextData *customerData = self.totalRichTextDatas[i];
        if (customerData.type == kLLLabelRichTextTypeUser) {
            [self.totalRichTextDatas removeObject:customerData];
        }
    }
    
    _customerRichTextDatas = customerRichTextDatas;
    if (_customerRichTextDatas) {
        for (LLLabelRichTextData *customerData in _customerRichTextDatas) {
            customerData.rects = [self calculateRectsForCharacterRange:customerData.range];
        }
        [self.totalRichTextDatas addObjectsFromArray:_customerRichTextDatas];
    }
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [cache removeAllObjects];
//    hasParsedRects = NO;

    if (self.data) {
        [self _setNeedsDisplay:nil];
    }
    
    [self parseText:self.attributedText];
}


- (void)layoutSubviews  {
    [super layoutSubviews];
   
//    if (!hasParsedRects) {
//        hasParsedRects = YES;
//        [self parseText:self.attributedText];
//    }
}

- (NSMutableArray<NSValue *> *)calculateRectsForCharacterRange:(NSRange)range {
    NSMutableArray<NSValue *> *rects = [NSMutableArray array];
    NSParagraphStyle *paragraphStyle = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:0 effectiveRange:nil];
    NSInteger lineSpace = paragraphStyle ? paragraphStyle.lineSpacing : 0;
    NSInteger lineSpaceOffset = lineSpace > 2 ? 1 - lineSpace : 0;

    NSRange glyphRange = [self.layoutManager glyphRangeForCharacterRange:range actualCharacterRange:NULL];
    
    CGRect startRect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location, 1) inTextContainer:self.textContainer];
    
    CGRect endRect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphRange.location + glyphRange.length - 1, 1) inTextContainer:self.textContainer];
    
    CGFloat lineHeight = self.font.lineHeight + lineSpace;
    NSInteger lineNumber = round((CGRectGetMaxY(endRect) - CGRectGetMinY(startRect)) / lineHeight);
    
    CGRect lineRect;
    CGRect drawRect;
    BOOL needAdjustInset = self.textContainerInset.top > 0 || self.textContainerInset.left > 0;
    
    //计算第一行
    if (lineNumber == 1) {
        drawRect = CGRectMake(CGRectGetMinX(startRect), CGRectGetMinY(startRect), CGRectGetMaxX(endRect) - CGRectGetMinX(startRect), CGRectGetHeight(startRect) + lineSpaceOffset );
    }else {
        lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphRange.location effectiveRange:nil];
        drawRect = CGRectMake(CGRectGetMinX(startRect), CGRectGetMinY(startRect), CGRectGetWidth(lineRect) - CGRectGetMinX(startRect), CGRectGetHeight(startRect) + lineSpaceOffset );
    }
    
    if (needAdjustInset) {
        CGRect rect = CGRectOffset(drawRect, self.textContainerInset.left, self.textContainerInset.top);
        [rects addObject:[NSValue valueWithCGRect:rect]];
    }else {
        [rects addObject:[NSValue valueWithCGRect:drawRect]];
    }
    

    //计算最后一行
    if (lineNumber >= 2) {
        drawRect = CGRectMake(self.textContainerInset.left, CGRectGetMinY(endRect) + self.textContainerInset.top, CGRectGetMaxX(endRect), CGRectGetHeight(endRect) + lineSpaceOffset);

        [rects addObject:[NSValue valueWithCGRect:drawRect]];
    }
    
    //计算中间行
    for (NSInteger i = 1; i < lineNumber - 1; i++) {
        NSInteger glyphIndex = [self.layoutManager glyphIndexForPoint:CGPointMake(0 , CGRectGetMinY(startRect) + lineHeight * i) inTextContainer:self.textContainer];
        lineRect = [self.layoutManager lineFragmentUsedRectForGlyphAtIndex:glyphIndex effectiveRange:nil];
        lineRect.size.height += lineSpaceOffset;
        
        if (needAdjustInset) {
            CGRect rect = CGRectOffset(lineRect, self.textContainerInset.left, self.textContainerInset.top);
            [rects addObject:[NSValue valueWithCGRect:rect]];
        }else {
            [rects addObject:[NSValue valueWithCGRect:lineRect]];
        }
    }
    return rects;
}

- (void)drawRect:(CGRect)rect {
    if (!self.data)
        return;
    
    NSArray<NSValue *> *rects = self.data.rects;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.selectedBackgroundColor.CGColor);
    for (NSValue *value in rects) {
        CGContextFillRect(context, value.CGRectValue);
    }
}

- (LLLabelRichTextData *)richTextDataAtPoint:(CGPoint)point {
    CGFloat fraction;
    NSInteger glyphIndex = [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceThroughGlyph:&fraction];
    LLLabelRichTextData *data = cache[@(glyphIndex)];
    if (data) {
        return data;
    }
    
    CGRect rect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:self.textContainer];
    
    if (!CGRectContainsPoint(rect, point)) {
        return nil;
    }
    
    NSInteger characterIndex = [self.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    for (LLLabelRichTextData *data in self.totalRichTextDatas) {
        if (characterIndex >= data.range.location && characterIndex < data.range.location + data.range.length) {
            cache[@(glyphIndex)] = data;
            return data;
        }
    }
    
    return nil;
}


- (void)_setNeedsDisplay:(LLLabelRichTextData *)data {
    self.data = data;
    [self setNeedsDisplay];
}


#pragma mark - AttributedString -

+ (NSMutableAttributedString *)createAttributedStringWithEmotionString:(NSString *)emotionString font:(UIFont *)font lineSpacing:(NSInteger)lineSpacing {
    
    UIColor *textColor = nil;
    if (@available(iOS 11.0, *)) {
        textColor = [UIColor colorNamed:@"text_black_gray"];
    } else {
        textColor = COLOR_BLACK_RGB;
    }
    
    return [LLSimpleTextLabel createAttributedStringWithEmotionString:emotionString font:font lineSpacing:lineSpacing textColor:textColor];
}

+ (NSMutableAttributedString *)createAttributedStringWithEmotionString:(NSString *)emotionString font:(UIFont *)font lineSpacing:(NSInteger)lineSpacing textColor:(UIColor *)textColor
{
    //解析Emotion字符串为NSTextAttachment
    NSMutableAttributedString *attributedString =
        [FACEMANAGER convertTextEmotionToAttachment:emotionString font:font];
    
    NSRange totalRange = NSMakeRange(0, attributedString.length);
    
    //行间距处理
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = lineSpacing;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{NSFontAttributeName:font,
                                 NSForegroundColorAttributeName:textColor,
                                 NSParagraphStyleAttributeName: paragraphStyle};
    [attributedString addAttributes:attributes range:totalRange];
    
    //url，手机号 设置为高亮
    NSError *error;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber | NSTextCheckingTypeLink error:&error];
    NSArray *matches = [detector matchesInString:attributedString.string
                                         options:kNilOptions
                                           range:totalRange];
    for (NSTextCheckingResult *match in matches) {
        NSRange matchRange = [match range];
        BOOL shouldHighlight = NO;
            
        if ([match resultType] == NSTextCheckingTypeLink) {
            NSURL *url = [match URL];
            if ([url.scheme isEqualToString:URL_MAIL_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTP_SCHEME] ||
                [url.scheme isEqualToString:URL_HTTPS_SCHEME]) {
                shouldHighlight = YES;
            }
        } else if ([match resultType] == NSTextCheckingTypePhoneNumber) {
            shouldHighlight = YES;
        }
        if (shouldHighlight) {
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0/255.0 green:104/255.0 blue:248/255.0 alpha:1] range:matchRange];
        }
    }
    
    //@设置为高亮
    NSRegularExpression *atRegular = [NSRegularExpression regularExpressionWithPattern:kAtRegex options:NSRegularExpressionCaseInsensitive error:&error];
    
    UIColor *nameColor = COLOR_NAME_RGB;
    if (@available(iOS 11.0, *)) {
        nameColor = [UIColor colorNamed:@"name"];
    }
    
    NSArray *resultArray = [atRegular matchesInString:attributedString.string options:0 range:totalRange];
    for(NSTextCheckingResult *match in resultArray) {
        NSRange range = [match range];
        [attributedString addAttribute:NSForegroundColorAttributeName value:nameColor range:range];
    }
    
    return attributedString;
}


#pragma mark - 手势 -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.panGestureRecognizer && [keyPath isEqualToString:@"state"]) {
        UIGestureRecognizerState state = [change[NSKeyValueChangeNewKey] integerValue];
        if (state == UIGestureRecognizerStateBegan) {
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            
            if (self.timer) {
                [self invalidateTimer];
            }
        }
        
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (_labelGestureRecognizer == gestureRecognizer) {
        return YES;
    }
    
    CGPoint point = [touch locationInView:self];
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    if (gestureRecognizer == _tapGestureRecognizer) {
        LLLabelRichTextData *data = [self richTextDataAtPoint:point];
        if (data) {
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            self.data = data;
            
            WEAKSELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TOUCH_DELAYED_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf delayedCallback:touch];
            });
            
            return YES;
        }else {
            return NO;
        }
    }

    return YES;
}

- (void)delayedCallback:(UITouch *)touch {
    if (!self.data || !touch || touch.phase == UITouchPhaseEnded || touch.phase == UITouchPhaseCancelled || ![touch.gestureRecognizers containsObject:_tapGestureRecognizer])
        return;
    
    [self invalidateTimer];
    self.timer = [NSTimer timerWithTimeInterval:self.longPressDuration - TOUCH_DELAYED_TIME target:self selector:@selector(longPressRecognized:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    [self _setNeedsDisplay:self.data];
}

- (void)longPressRecognized:(NSTimer *)timer {
    if (self.longPressAction && self.data) {
        longPressGestureRecognizerState = UIGestureRecognizerStateBegan;
        self.longPressAction(self.data, UIGestureRecognizerStateBegan);
        
        self.tapGestureRecognizer.enabled = NO;
    }
}

- (void)labelGestureHandler:(LLLabelGestureRecognizer *)labelGesture {
    switch (labelGesture.state) {
        case UIGestureRecognizerStateBegan:
//            if (self.longPressAction && self.data) {
//                self.longPressAction(self.data, labelGesture.state);
//            }
            break;
        case UIGestureRecognizerStateCancelled:
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            break;
        case UIGestureRecognizerStateEnded:
//            if (self.longPressAction && self.data) {
//                self.longPressAction(self.data, labelGesture.state);
//            }
            
            if (self.data) {
                [self _setNeedsDisplay:nil];
            }
            
            
        default:
            break;
    }

}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        if (self.timer) {
            [self invalidateTimer];
        }
        
        if (self.data && self.tapAction) {
            self.tapAction(self.data);
            
            [self _setNeedsDisplay:self.data];
            WEAKSELF;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(TOUCH_DELAYED_TIME * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf clearLinkBackground];
            });
        }
    }
}


- (void)invalidateTimer {
    [self.timer invalidate];
    self.timer = nil;
    
    self.tapGestureRecognizer.enabled = YES;
    longPressGestureRecognizerState = UIGestureRecognizerStatePossible;
}


- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.data && (_labelGestureRecognizer.state != UIGestureRecognizerStateBegan && _labelGestureRecognizer.state != UIGestureRecognizerStateChanged && _labelGestureRecognizer.state != UIGestureRecognizerStateEnded)) {
        [self _setNeedsDisplay:nil];
    }
    
    if (self.timer) {
        [self invalidateTimer];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (longPressGestureRecognizerState == UIGestureRecognizerStateBegan) {
        if (self.longPressAction && self.data) {
            longPressGestureRecognizerState = UIGestureRecognizerStateEnded;
            self.longPressAction(self.data, UIGestureRecognizerStateEnded);
        }
    }
    
    if (self.data) {
        [self _setNeedsDisplay:nil];
    }
    
    if (self.timer) {
        [self invalidateTimer];
    }
}


- (BOOL)shouldReceiveTouchAtPoint:(CGPoint)point {
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    LLLabelRichTextData *data = [self richTextDataAtPoint:point];
    
    if (!data)return NO;
    return YES;

}

- (void)swallowTouch {
    [_labelGestureRecognizer swallowTouch];
}


- (void)clearLinkBackground {
    if (self.data) {
        [self _setNeedsDisplay:nil];
    }
}


- (UITapGestureRecognizer *)addTapGestureRecognizer:(SEL)action {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:action];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:tap];
    
    return tap;
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    [super addGestureRecognizer:gestureRecognizer];
    
    gestureRecognizer.delaysTouchesBegan = NO;
    gestureRecognizer.delaysTouchesEnded = NO;
}

- (UITapGestureRecognizer *)addTapGestureRecognizer:(SEL)action target:(id)target {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    
    [self addGestureRecognizer:tap];
    
    return tap;
}

- (UILongPressGestureRecognizer *)addLongPressGestureRecognizer:(SEL)action duration:(CGFloat)duration {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:action];
    longPress.minimumPressDuration = duration;
    [self addGestureRecognizer:longPress];
    
    return longPress;
}

- (UILongPressGestureRecognizer *)addLongPressGestureRecognizer:(SEL)action target:(id)target duration:(CGFloat)duration {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:action];
    longPress.minimumPressDuration = duration;
    [self addGestureRecognizer:longPress];
    
    return longPress;
}

#pragma mark - 布局Delegate -



@end

////////////////////////////////////////////////////


@interface LLLabelGestureRecognizer ()

@property (nonatomic) UITouch *touch;

@end

@implementation LLLabelGestureRecognizer

- (void)reset {
    [super reset];
    
    self.touch = nil;
}

- (void)swallowTouch {
    self.state = UIGestureRecognizerStateBegan;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    self.touch = [touches anyObject];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateBegan ||
        self.state == UIGestureRecognizerStateChanged)
        self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateBegan ||
        self.state == UIGestureRecognizerStateChanged)
        self.state = UIGestureRecognizerStateCancelled;
}


@end
