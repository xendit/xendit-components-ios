#import "AppDelegate.h"
#import "PlayfairFont.h"
#import "OpenSansFont.h"
#import "SpaceMonoFont.h"
#import "NotoSerifFont.h"
@import XenditComponents;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [PlayfairFont register];
    [OpenSansFont register];
    [SpaceMonoFont register];
    [NotoSerifFont register];
    [XDTComponents initializeWithAppearance:[XDTAppearance new]];
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application
configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                               options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                          sessionRole:connectingSceneSession.role];
}

@end
