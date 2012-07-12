//
//  SettingsViewController.h
//  PocketTracker
//
//  Created by OSU 758 Capstone on 5/12/12.
//  Copyright (c) 2012 Credibility. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "SpendingPlan.h"
#import "Expenses.h"

@interface SettingsViewController : UITableViewController <UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIManagedDocument *document;

//Property that represents an object that queries the file system for
//stored expenses.
@property (strong, nonatomic) NSFetchedResultsController *fetchedExpenses;

//Property that representsan object that queries the file system for
//stored Spending Plan entries.
@property (strong, nonatomic) NSFetchedResultsController *fetchedBudget;

@end
