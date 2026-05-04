#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// Registers and vends Playfair Display font variants for use with XDTFontFamily.
///
/// Call +register once at app startup before accessing any font.
/// Font files must be added to the Xcode target as bundle resources (Build Phases →
/// Copy Bundle Resources), even though they live in the Fonts/ group.
@interface PlayfairFont : NSObject

/// Registers all four Playfair Display weights with CoreText.
+ (void)register;

/// PlayfairDisplay-Regular at size 14. XDTFontFamily scales it via -fontWithSize:.
+ (UIFont *)regular;
/// PlayfairDisplay-Medium at size 14.
+ (UIFont *)medium;
/// PlayfairDisplay-SemiBold at size 14.
+ (UIFont *)semiBold;
/// PlayfairDisplay-Bold at size 14.
+ (UIFont *)bold;

@end

NS_ASSUME_NONNULL_END
