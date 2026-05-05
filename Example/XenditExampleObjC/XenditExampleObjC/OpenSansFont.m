#import "OpenSansFont.h"
#import <CoreText/CoreText.h>

@implementation OpenSansFont

+ (void)register {
    NSArray<NSString *> *names = @[
        @"OpenSans-Regular",
        @"OpenSans-Medium",
        @"OpenSans-SemiBold",
        @"OpenSans-Bold",
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

+ (UIFont *)regular  { return [UIFont fontWithName:@"OpenSans-Regular"  size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightRegular]; }
+ (UIFont *)medium   { return [UIFont fontWithName:@"OpenSans-Medium"   size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightMedium]; }
+ (UIFont *)semiBold { return [UIFont fontWithName:@"OpenSans-SemiBold" size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold]; }
+ (UIFont *)bold     { return [UIFont fontWithName:@"OpenSans-Bold"     size:14] ?: [UIFont systemFontOfSize:14 weight:UIFontWeightBold]; }

@end
