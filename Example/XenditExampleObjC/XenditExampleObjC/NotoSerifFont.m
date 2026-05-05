#import "NotoSerifFont.h"
#import <CoreText/CoreText.h>

@implementation NotoSerifFont

+ (void)register {
    NSArray<NSString *> *names = @[
        @"NotoSerif-Regular",
        @"NotoSerif-Medium",
        @"NotoSerif-SemiBold",
        @"NotoSerif-Bold",
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

+ (UIFont *)regular  { return [UIFont fontWithName:@"NotoSerif-Regular"  size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]; }
+ (UIFont *)medium   { return [UIFont fontWithName:@"NotoSerif-Medium"   size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium]; }
+ (UIFont *)semiBold { return [UIFont fontWithName:@"NotoSerif-SemiBold" size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]; }
+ (UIFont *)bold     { return [UIFont fontWithName:@"NotoSerif-Bold"     size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightBold]; }

@end
