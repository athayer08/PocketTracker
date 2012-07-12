//
//  AddExpenseViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Expenses.h"
#import "ExpensesViewController.h"
#import "CustomCategories.h"

@interface AddExpenseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneAddExpense;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIPickerView *categoryPicker;
@property (strong, nonatomic) UIPickerView *paymentPicker;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) NSMutableArray *pickerCategories;
@property (strong, nonatomic) NSMutableArray *paymentMethods;
@property (strong, nonatomic) UITextField *amountInput;
@property (strong, nonatomic) UITextField *categoryInput;
@property (strong, nonatomic) UITextField *dateInput;
@property (strong, nonatomic) UITextField *methodInput;
@property (nonatomic) NSInteger amountTag;
@property (strong, nonatomic) NSMutableString *amount;
@property (strong, nonatomic) UIButton *topContainer;

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSFetchedResultsController *fetchedCategories;

-(IBAction)doDoneButton;

@end
