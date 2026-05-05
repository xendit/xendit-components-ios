#import "SpaceMonoFont.h"
#import <CoreText/CoreText.h>

@implementation SpaceMonoFont

+ (void)register {
    NSArray<NSString *> *names = @[
        @"SpaceMono-Regular",
        @"SpaceMono-Bold",
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

+ (UIFont *)regular { return [UIFont fontWithName:@"SpaceMono-Regular" size:14] ?: [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightRegular]; }
+ (UIFont *)bold    { return [UIFont fontWithName:@"SpaceMono-Bold"    size:14] ?: [UIFont monospacedSystemFontOfSize:14 weight:UIFontWeightBold]; }

@end
