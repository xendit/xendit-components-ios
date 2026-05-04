#import "PlayfairFont.h"
#import <CoreText/CoreText.h>

@implementation PlayfairFont

+ (void)register {
    NSArray<NSString *> *names = @[
        @"PlayfairDisplay-Regular",
        @"PlayfairDisplay-Medium",
        @"PlayfairDisplay-SemiBold",
        @"PlayfairDisplay-Bold",
    ];
    for (NSString *name in names) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:@"ttf"];
        if (url) {
            CTFontManagerRegisterFontsForURL((__bridge CFURLRef)url, kCTFontManagerScopeProcess, NULL);
        } else {
            NSLog(@"[XenditExampleObjC] '%@.ttf' not found in bundle — add it to Copy Bundle Resources in Xcode.", name);
        }
    }
}

+ (UIFont *)regular  { return [UIFont fontWithName:@"PlayfairDisplay-Regular"  size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]; }
+ (UIFont *)medium   { return [UIFont fontWithName:@"PlayfairDisplay-Medium"   size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium]; }
+ (UIFont *)semiBold { return [UIFont fontWithName:@"PlayfairDisplay-SemiBold" size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]; }
+ (UIFont *)bold     { return [UIFont fontWithName:@"PlayfairDisplay-Bold"     size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightBold]; }

@end
