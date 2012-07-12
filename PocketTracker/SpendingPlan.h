//
//  SpendingPlan.h
//  PocketTracker
//
//  Created by Andrew Thayer on 5/24/12.
//  Copyright (c) 2012 __CredAbility__. All rights reserved.
//
// Object used to represent a Spending Plan entry in the file system.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SpendingPlan : NSManagedObject

@property (nonatomic, retain) NSDate * date; //Stores the date
@property (nonatomic, retain) NSString * amount; //Stores the amount

@end
