//
//  AppDelegate.m
//  CompositeController
//
//  Created by Alex Kalinin on 11/26/15.
//  Copyright (c) 2015 Alex Kalinin. All rights reserved.
//

#import "AppDelegate.h"
#import "SlidingContainerController.h"
#import "ContentViewController.h"

@interface AppDelegate ()<SlidingContainerController_DataSource>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[SlidingContainerController alloc] init_with_data_source:self];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}
//------------------------------------------------------------------------------
- (UIViewController *)create_controller_for_index:(int)index
{
    ContentViewController* child = [[ContentViewController alloc]init_with_color:[self random_color]];
    child.id_label.text = [NSString stringWithFormat:@"%d", index];
    return child;
}
//------------------------------------------------------------------------------
-(UIColor*) random_color
{
    CGFloat hue = (CGFloat) ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = (CGFloat) (( arc4random() % 128 / 256.0 ) + 0.5);  //  0.5 to 1.0, away from white
    CGFloat brightness = (CGFloat) (( arc4random() % 128 / 256.0 ) + 0.5);  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];

    return color;
}

@end
