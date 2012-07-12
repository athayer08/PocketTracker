//
//  AddIncomeViewController.m
//  PocketTracker
//
//  Created by OSU 758 Capstone on 5/13/12.
//  Copyright (c) 2012 Credibility. All rights reserved.
//

#import "AddIncomeViewController.h"

@interface AddIncomeViewController ()

@end

@implementation AddIncomeViewController
@synthesize cancelButton;
@synthesize tableView;

@synthesize amount, amountInput, datePicker, doneAddIncome, document, dateInput;

-(void)removeKeyboard
{
    [self.amountInput resignFirstResponder];
}

-(void)removeDatePicker
{
    [self.dateInput resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentReady];
            } else {
                NSLog(@"count open document at %@", url);
            }
        }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                [self documentReady];
            } else {
                NSLog(@"couldn't create document at %@", url);
            }
        }];
    }
    
    //initilize amount input text field
    self.amountInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    [self.amountInput setTag:0];
    self.amountInput.delegate = self;
    self.amountInput.placeholder = @"$0.00";
    self.amountInput.keyboardType = UIKeyboardTypeNumberPad;
    self.amountInput.returnKeyType = UIReturnKeyDefault;
    self.amountInput.textAlignment = UITextAlignmentRight;
    self.amountInput.adjustsFontSizeToFitWidth = YES;
    [self.amountInput addTarget:self action:@selector(changeAmount) forControlEvents:UIControlEventEditingDidBegin];
    [self.amountInput setEnabled:YES];
    
    UIToolbar *keyboardTBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    keyboardTBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneKeyboard = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeKeyboard)];
    NSMutableArray *keyboardTbarItems = [[NSMutableArray alloc] init];
    [keyboardTbarItems addObject:doneKeyboard];
    [keyboardTBar setItems:keyboardTbarItems];
    self.amountInput.inputAccessoryView = keyboardTBar;
    
    //initilize date input field
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGSize datePickerSize = [self.datePicker sizeThatFits:CGSizeZero];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, screenRect.origin.y +screenRect.size.height - 200.0, datePickerSize.width, datePickerSize.height)];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate date];
    [self.datePicker setDate:[NSDate date]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"startDate"]) {
        NSDate *minimumDate = [defaults objectForKey:@"startDate"];
        self.datePicker.minimumDate = minimumDate;
        
        NSTimeInterval thirtyDays = 30 * 24 * 60 * 60;
        
        NSDate *maximumDate = [minimumDate dateByAddingTimeInterval:thirtyDays];
        self.datePicker.maximumDate = maximumDate;
    }
    
    self.dateInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.dateInput.delegate = self;
    self.dateInput.textAlignment = UITextAlignmentRight;
    self.dateInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.dateInput setEnabled:YES];
    [self.dateInput setTag:1];
    
    UIToolbar *dateBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    dateBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneDate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeDatePicker)];
    NSMutableArray *dateBarItems = [[NSMutableArray alloc] init];
    [dateBarItems addObject:doneDate];
    [dateBar setItems:dateBarItems];
    self.dateInput.inputView = self.datePicker;
    self.dateInput.inputAccessoryView = dateBar;
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setCancelButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setDoneAddIncome: nil];
    self.datePicker = nil;
    self.amountInput = nil;
    self.document = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    // Configure the cell...
    [self.datePicker addTarget:self action:@selector(changeDate) forControlEvents:UIControlEventValueChanged];
    
    //if the user selects the first row in the table - configure the cell to the "add budget amount" cell
    if (indexPath.row == 0) {
        
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Spending Plan Add Amount"];
        }
        cell.textLabel.text = @"Amount";
        
        [cell addSubview:self.amountInput];
        
    }
    //if the user selects the second row in the table - configure the cell to the "add date" cell
    else if (indexPath.row == 1) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Spending Plan Add Date"];
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        
        cell.textLabel.text = @"Date";
        self.dateInput.text = [formatter stringFromDate:self.datePicker.date];
        
        [cell addSubview:self.dateInput];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if the add date cell is selected allow the date picker to appear
    if(indexPath.row == 1) {
        [self.datePicker becomeFirstResponder];
    } else if (indexPath.row == 0) {
        [self.amountInput becomeFirstResponder];
    }
    
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(IBAction)doneButton
{
    //if the user does not make aany entry to the add budget cell, then return to the main budget screen
    if(self.amountInput.text && ![self.amountInput.text isEqualToString:@""] && ![self.amountInput.text isEqualToString:@"$0.00"]) {
        NSLog(@"DoneButton");
        
        SpendingPlan *spendingplan = [NSEntityDescription insertNewObjectForEntityForName:@"SpendingPlan" inManagedObjectContext:self.document.managedObjectContext];
        
        
        spendingplan.date = self.datePicker.date;
        NSLog(@"storing amount... %@", self.amountInput.text);
        spendingplan.amount = self.amountInput.text;
        
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success){
                [self dismissModalViewControllerAnimated:YES];  
            } else {
                NSLog(@"couldn't save document at %@", self.document.fileURL);
            }
        }];
        //automatically naivagate back to the main input screen 
    }
    
}

-(IBAction)cancelButton
{    
    [self dismissModalViewControllerAnimated:YES];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSLog(@"string length = %i", [string length]);
    if(textField  == self.amountInput) {
        
        if (!self.amount) {
            self.amount = [[NSMutableString alloc] init];
        }
        
        if ([string length] == 0 && [self.amount length] > 0) {
            NSRange range = NSMakeRange([self.amount length] - 1, 1);
            [self.amount deleteCharactersInRange:range];
        }
        //set limit on amount the user can input. must be less than $10,000.00
        else if ([self.amount length] < 7){
            if([self.amount length]> 0) {
                
                [self.amount appendString:string];
            }
            else {
                [self.amount appendString:string];
            }
        }
        NSLog(@"new string = %@", self.amount);
        //format the string to a currancy format
        NSString *newAmount = [self formatCurrencyValue:([self.amount doubleValue]/100)];
        NSLog(@"new string = %@", newAmount);
        
        [textField setText:[NSString stringWithFormat:@"%@",newAmount]];
        
        return NO;
    }
    
    return YES;
}

//format string to inlcude proper decimal places and dollar sign
-(NSString*)formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}


- (void) changeAmount {
    
}


-(void) changeDate {
    NSDate *date = self.datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    self.dateInput.text = [formatter stringFromDate:date];
}

-(void)documentReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        NSLog(@"document state normal");
    }
}

-(void) deselectAllRows {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
