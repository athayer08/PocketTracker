//
//  InitialViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 5/14/12.
//  Copyright (c) 2012 __CredAbility__. All rights reserved.
//
//  Header file for the controller of the Welcome Screen.

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "Expenses.h"
#import "SpendingPlan.h"

@interface InitialViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>

//Property representing the Table View
@property (weak, nonatomic) IBOutlet UITableView *tView;

//Property representing the button that continues from the Welcome screen to the
//Summary screen.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *continueButton;

//Property representing the text field that takes in the Spending Plan
//input.
@property (strong, nonatomic) UITextField *amountInput;

//Property representing the text field that takes in the Start Date.
@property (strong, nonatomic) UITextField *dateInput;

//Property representing a mutable string that is used in formatting
//the Spending Plan input.
@property (strong, nonatomic) NSMutableString *amount;

//Property representing the popup that allows the user to select the
//start date.
@property (strong, nonatomic) UIDatePicker *datePicker;

//Property that represents an object that assists in storing the
//initial Spending Plan entry into the file system.
@property (strong, nonatomic) UIManagedDocument *document;

//Property that represents an object that queries the file system for
//stored expenses.
@property (strong, nonatomic) NSFetchedResultsController *fetchedExpenses;

//Property that representsan object that queries the file system for
//stored Spending Plan entries.
@property (strong, nonatomic) NSFetchedResultsController *fetchedBudget;


- (IBAction)doContinue;

@end
