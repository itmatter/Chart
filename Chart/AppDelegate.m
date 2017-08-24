//
//  AppDelegate.m
//  Chart
//
//  Created by 李礼光 on 2017/8/23.
//  Copyright © 2017年 LG. All rights reserved.
//

#import "AppDelegate.h"
#import "ChartViewVC.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ChartViewVC alloc]init]];
    [self.window makeKeyAndVisible];
    
    
    
    return YES;
}


@end
