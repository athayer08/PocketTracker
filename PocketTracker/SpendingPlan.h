//
//  SpendingPlan.h
//  PocketTracker
//
//  Created by OSU 758 Capstone on 5/12/12.
//  Copyright (c) 2012 Credibility. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SpendingPlan : NSManagedObject

@property (nonatomic, retain) NSString *amount;
@property (nonatomic, retain) NSDate *date;

@end
