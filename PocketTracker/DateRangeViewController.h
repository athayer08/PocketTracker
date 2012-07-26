//
//  DateRangeViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpendingPlan.h"
#import "Expenses.h"

@interface DateRangeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSFetchedResultsController *fetchedExpenses;
@property (strong, nonatomic) NSFetchedResultsController *fetchedBudget;
@property (strong, nonatomic) UIDatePicker *startPicker;
@property (strong, nonatomic) UIDatePicker *endPicker;
@property (strong, nonatomic) UITextField *startInput;
@property (strong, nonatomic) UITextField *endInput;

- (IBAction)doDone:(id)sender;
@end
