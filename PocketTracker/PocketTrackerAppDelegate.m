//
//  PocketTrackerAppDelegate.m
//  PocketTracker
//
//  Created by Andrew Thayer on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PocketTrackerAppDelegate.h"

@implementation PocketTrackerAppDelegate

@synthesize window = _window;

//Method is envoked when the application is started.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *initialVC;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"notFirstLoad"]) { //If this is the first time the application is loading...
        initialVC = [storyboard instantiateViewControllerWithIdentifier:@"Tutorial Controller"]; //Load the tutorial. This identifier is defined in the storyboard.
        
        self.window.rootViewController = initialVC;
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

//Envoked when the application becomes active.
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"notFirstLoad %i", [defaults boolForKey:@"notFirstLoad"]);
    NSLog(@"initialView %i", [defaults boolForKey:@"initialView"]);
    NSLog(@"e-mailNotify %i", [defaults boolForKey:@"e-mailNotify"]);
    if ([defaults boolForKey:@"notFirstLoad"]) { //If this is not the first load of the application...
        
        //Calculate the end date
        NSDate *endDate = [defaults objectForKey:@"endDate"];
        //NSTimeInterval test = -2 * 24 * 60 * 60;
        //NSTimeInterval test1 = -1 * 24 * 60 * 60;
        //NSDate *startDate = [[NSDate date] dateByAddingTimeInterval:test];
        //NSDate *endDate = [[NSDate date] dateByAddingTimeInterval:test1];
        NSInteger comps = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:comps fromDate:endDate];
        NSDateComponents *components1 = [calendar components:comps fromDate:[NSDate date]];
        
        endDate = [calendar dateFromComponents:components];
        NSDate *today = [calendar dateFromComponents:components1];
        NSLog(@"today: %@", today);
        NSLog(@"endDate: %@", endDate);
        NSComparisonResult result = [today compare:endDate];
        
        //Compare the end date to today's date.
        if (result == NSOrderedDescending) { //If the todays date is past the end date, load the Welcome Screen and e-mail notification.
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UIViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"Initial View"];
            [defaults setBool:YES forKey:@"e-mailNotify"];
            [defaults synchronize];
            self.window.rootViewController = controller;
        }
        
        if ([defaults boolForKey:@"initialView"]) { //The case where Reset Data was chosen in the settings. After the data is deleted, it needs to load the Welcome screen.
            
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UIViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"Initial View"];
            self.window.rootViewController = controller;
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
