//
//  ExpensesViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Expenses.h"
#import "SpendingPlan.h"
#import "EditExpenseViewController.h"
#import "CustomCategories.h"

@interface ExpensesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *fetchedBudgetResults;
@property (nonatomic, strong) NSFetchedResultsController *fetchedCategories;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) NSMutableArray *pickerCategories;
@property (nonatomic, strong) NSMutableArray *paymentMethods;
@property (nonatomic, strong) UIPickerView *categoryPicker;
@property (nonatomic, strong) UIPickerView *paymentPicker;
@property (nonatomic, strong) UIButton *topContainer;
@property (nonatomic, strong) UITextField *categoryInput;
@property (nonatomic, strong) UITextField *methodInput;

@end
