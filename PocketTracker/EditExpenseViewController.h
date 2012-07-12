//
//  EditExpenseViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 6/15/12.
//  Copyright (c) 2012 __CredAbility__. All rights reserved.
//
//  Header file for the Edit Expense view.

#import <UIKit/UIKit.h>
#import "Expenses.h"
#import "ExpensesViewController.h"
#import "CustomCategories.h"

@interface EditExpenseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

//Property representing the done button on the view.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneAddExpense;

//Property representing the cancel button on the view.
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

//Property representing the table view.
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//Property representing the picker for the expense categories.
@property (strong, nonatomic) UIPickerView *categoryPicker;

//Property representing the picker for the payment methods.
@property (strong, nonatomic) UIPickerView *paymentPicker;

//Property representing the picker for the date.
@property (strong, nonatomic) UIDatePicker *datePicker;

//Property representing the array storing the categories.
@property (strong, nonatomic) NSMutableArray *pickerCategories;

//Property representing the array storying the payment methods.
@property (strong, nonatomic) NSMutableArray *paymentMethods;

//Property representing the text field for the amount input.
@property (strong, nonatomic) UITextField *amountInput;

//Property representing the text field containing the category selected
//by the categoryPicker
@property (strong, nonatomic) UITextField *categoryInput;

//Property representing the text field containing the date selected by
//the datePicker.
@property (strong, nonatomic) UITextField *dateInput;

//Property representing the text field containing the payment method
//selected by the paymentPicker.
@property (strong, nonatomic) UITextField *methodInput;

//Property representing an identifier that differentiates the amount
//text field from the other text fields.
@property (nonatomic) NSInteger amountTag;

//Property representing the string of digits entered in the amount
//text field. Used for formatting the input.
@property (strong, nonatomic) NSMutableString *amount;

//Property representing an object that works with the file system to
//store data.
@property (strong, nonatomic) UIManagedDocument *document;

//Property representing an object that queries the file system for expenses.
@property (strong, nonatomic) NSFetchedResultsController *fetchedExpenses;

//Property representing an object that queries the file system for the custom categories.
@property (strong, nonatomic) NSFetchedResultsController *fetchedCategories;

//Property representing the Expense in the file system that is to be changed.
@property (strong, nonatomic) Expenses *editExpense;

//Signature of the method that is envoked when the done button is clicked.
-(IBAction)doDoneButton;

//Signature of the method that is envoked when the cancel button is clicked.
-(IBAction)doCancelButton;



@end
