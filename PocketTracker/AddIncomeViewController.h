//
//  AddIncomeViewController.h
//  PocketTracker
//
//  Created by OSU 758 Capstone on 5/13/12.
//  Copyright (c) 2012 Credibility. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpendingPlan.h"

@interface AddIncomeViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITextField *amountInput;
@property (strong, nonatomic) UITextField *dateInput;
@property (strong, nonatomic) NSMutableString *amount;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneAddIncome;
@property (weak, nonatomic)IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) UIManagedDocument *document;

-(IBAction)doneButton;
-(IBAction)cancelButton;
@end
