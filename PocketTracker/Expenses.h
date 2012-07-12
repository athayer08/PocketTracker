//
//  Expenses.h
//  PocketTracker
//
//  Created by Andrew Thayer on 5/8/12.
//  Copyright (c) 2012 __CredAbility__. All rights reserved.
//
// Object used to represent an Expense entry in the file system.

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Expenses : NSManagedObject

@property (nonatomic, retain) NSString * amount; //Stores the expense amount
@property (nonatomic, retain) NSString * category; //Stores the category of the expense
@property (nonatomic, retain) NSDate * date; //Stores the date of the expense 
@property (nonatomic, retain) NSString * method; //Stores the payment method of the expense

@end
