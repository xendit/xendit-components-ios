#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenSansFont : NSObject
+ (void)register;
+ (UIFont *)regular;
+ (UIFont *)medium;
+ (UIFont *)semiBold;
+ (UIFont *)bold;
@end

NS_ASSUME_NONNULL_END
