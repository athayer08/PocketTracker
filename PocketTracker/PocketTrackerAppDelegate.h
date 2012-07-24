//
//  PocketTrackerAppDelegate.h
//  PocketTracker
//
//  Created by Andrew Thayer on 4/29/12.
//  Copyright (c) 2012 __CredAbility__. All rights reserved.
//
// Controls how the application behaves as a whole. Primarily used to determine
// which of the three entry points to choose.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <unistd.h>

@interface PocketTrackerAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
