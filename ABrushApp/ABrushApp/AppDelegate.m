//
//  AppDelegate.m
//  ABrushApp
//
//  Created by apricity on 2023/6/9.
//

#import "AppDelegate.h"
#import "ABrushPage/ABrushViewController.h"
#import "Vlogs/VlogsViewController.h"
#import "ShowImages/ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UITabBarController * tabBarController = [[UITabBarController alloc] init];
    
    ViewController * vc0 = [[ViewController alloc] init];
    UINavigationController * nc0 = [[UINavigationController alloc] initWithRootViewController:vc0];
    nc0.tabBarItem.title = @"Images";
    nc0.tabBarItem.image = [UIImage systemImageNamed:@"photo.fill"];

    VlogsViewController * vc1 = [[VlogsViewController alloc] init];
    UINavigationController * nc1 = [[UINavigationController alloc] initWithRootViewController:vc1];
    nc1.tabBarItem.title = @"Vlogs";
    nc1.tabBarItem.image = [UIImage systemImageNamed:@"tv.fill"];
    
    ABrushViewController * vc2 = [[ABrushViewController alloc] init];
    UINavigationController * nc2 = [[UINavigationController alloc] initWithRootViewController:vc2];
    nc2.tabBarItem.title = @"ABrush";
    nc2.tabBarItem.image = [UIImage systemImageNamed:@"paintbrush.pointed.fill"];
    
    [tabBarController addChildViewController:nc0];
    [tabBarController addChildViewController:nc1];
    [tabBarController addChildViewController:nc2];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
