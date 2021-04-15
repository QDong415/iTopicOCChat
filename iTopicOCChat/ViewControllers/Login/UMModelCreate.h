//
//  UMModel.h
//
//

#import <Foundation/Foundation.h>
#import <UMVerify/UMVerify.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMModelCreate : NSObject

/// 创建全屏的model
+ (UMCustomModel *)createFullScreen;
/// 创建弹窗的model
+ (UMCustomModel *)createAlert;
@end

NS_ASSUME_NONNULL_END
