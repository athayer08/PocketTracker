//
//  AddExpenseViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddExpenseViewController.h"

@interface AddExpenseViewController ()

@end

@implementation AddExpenseViewController
@synthesize tableView;
@synthesize categoryInput;
@synthesize methodInput;
@synthesize dateInput;
@synthesize fetchedCategories;

@synthesize doneAddExpense, categoryPicker, paymentPicker, datePicker, pickerCategories, paymentMethods, amountInput, amountTag, amount, document, topContainer;


-(void)deselectAllRows
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)setupCategoryPicker
{
    self.pickerCategories =[[NSMutableArray alloc] init ];
    [self.pickerCategories addObject:@"Grocery, Dining"];
    [self.pickerCategories addObject:@"Auto: Gas, Maintenance"];
    [self.pickerCategories addObject:@"Medical"];
    [self.pickerCategories addObject:@"Children, Education"];
    [self.pickerCategories addObject:@"Clothing"];
    [self.pickerCategories addObject:@"Personal Items"];
    [self.pickerCategories addObject:@"Fun, Entertainment"];
    [self.pickerCategories addObject:@"Savings"];
    [self.pickerCategories addObject:@"Miscellaneous"];
    
    self.categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.categoryPicker setTag:1];
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    self.categoryPicker.frame = CGRectMake(0, (screenRect.size.height / 2), 320, 216);
    self.categoryPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.categoryPicker.delegate = self;
    self.categoryPicker.dataSource = self;
    self.categoryPicker.showsSelectionIndicator = YES;
    
}

-(void)removeKeyboard
{
    [self.amountInput resignFirstResponder];
}

-(void)removeDatePicker
{
    [self.dateInput resignFirstResponder];
}

-(void)removeCategoryPicker
{
    [self.categoryInput resignFirstResponder];
}

-(void)removeMethodPicker
{
    [self.methodInput resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.datePicker) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.datePicker.minimumDate = [defaults objectForKey:@"startDate"];
        self.datePicker.maximumDate = [defaults objectForKey:@"endDate"];
        
        [self.tableView reloadData];
    }
    
    for (NSInteger i = 9; i < [pickerCategories count] ; i++) {
        [pickerCategories removeObjectAtIndex:i];
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CustomCategories"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES]];
    self.fetchedCategories = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error;
    [self.fetchedCategories performFetch:&error];
    
    for (CustomCategories *category in self.fetchedCategories.fetchedObjects) {
        if (![self.pickerCategories containsObject:category.category]) {
            [self.pickerCategories addObject:category.category];
        }
    }
    
    [self.categoryPicker reloadAllComponents];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // This opens the UIManagedDocument/database. Pretty much, just copy and paste.
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentIsReady]; // When the document is open, I proceed with the app by going to this
                                        // method. Replace with your own method.
            } else {
                NSLog(@"count open document at %@", url);
            }
         }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                [self documentIsReady]; // See above
            } else {
                NSLog(@"couldn't create document at %@", url);
            }
        }];
    }
    
    self.paymentMethods = [[NSMutableArray alloc] init];
    [self.paymentMethods addObject:@"Cash"];
    [self.paymentMethods addObject:@"Credit Card"];
    [self.paymentMethods addObject:@"Debit Card"];
    
    [self setupCategoryPicker];
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    self.paymentPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.paymentPicker setTag:2];
    self.paymentPicker.frame = CGRectMake(0, (screenRect.size.height / 2), 320, 216);
    self.paymentPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.paymentPicker.delegate = self;
    self.paymentPicker.dataSource = self;
    self.paymentPicker.showsSelectionIndicator = YES;
    
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, (screenRect.size.height / 2), 320, 216)];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker setDate:[NSDate date]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"startDate"]) {
        NSDate *minimumDate = [defaults objectForKey:@"startDate"];
        self.datePicker.minimumDate = minimumDate;

        self.datePicker.maximumDate = [defaults objectForKey:@"endDate"];
    }
    
    self.amountTag = 0;
    self.amountInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    [self.amountInput setTag:self.amountTag];
    self.amountInput.delegate = self;
    self.amountInput.placeholder = @"$0.00";
    self.amountInput.keyboardType = UIKeyboardTypeNumberPad;
    self.amountInput.returnKeyType = UIReturnKeyDefault;
    self.amountInput.textAlignment = UITextAlignmentRight;
    self.amountInput.adjustsFontSizeToFitWidth = YES;
    [self.amountInput addTarget:self action:@selector(editingAmount) forControlEvents:UIControlEventEditingDidBegin];
    [self.amountInput setEnabled:YES];
    
    UIToolbar *keyboardTBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    keyboardTBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneKeyboard = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeKeyboard)];
    NSMutableArray *keyboardTbarItems = [[NSMutableArray alloc] init];
    [keyboardTbarItems addObject:doneKeyboard];
    [keyboardTBar setItems:keyboardTbarItems];
    self.amountInput.inputAccessoryView = keyboardTBar;
    
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
    
    self.categoryInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.categoryInput.delegate = self;
    self.categoryInput.textAlignment = UITextAlignmentRight;
    self.categoryInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.categoryInput setEnabled:YES];
    [self.categoryInput setTag:2];
    
    UIToolbar *categoryBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    categoryBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneCategory = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeCategoryPicker)];
    NSMutableArray *categoryBarItems = [[NSMutableArray alloc] init];
    [categoryBarItems addObject:doneCategory];
    [categoryBar setItems:categoryBarItems];
    self.categoryInput.inputView = self.categoryPicker;
    self.categoryInput.inputAccessoryView = categoryBar;
    
    self.methodInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.methodInput.delegate = self;
    self.methodInput.textAlignment = UITextAlignmentRight;
    self.methodInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.methodInput setEnabled:YES];
    [self.methodInput setTag:3];
    
    UIToolbar *methodBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    methodBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneMethod = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeMethodPicker)];
    NSMutableArray *methodBarItems = [[NSMutableArray alloc] init];
    [methodBarItems addObject:doneMethod];
    [methodBar setItems:methodBarItems];
    self.methodInput.inputView = self.paymentPicker;
    self.methodInput.inputAccessoryView = methodBar;
}

- (void)viewDidUnload
{
    [self setDoneAddExpense:nil];
    [self setTableView:nil];
    [super viewDidUnload];
    self.categoryPicker = nil;
    self.paymentPicker = nil;
    self.datePicker = nil;
    self.pickerCategories = nil;
    self.paymentMethods = nil;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    [self.datePicker addTarget:self action:@selector(datePickerValueChange) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];

    if (indexPath.row == 0) {
        NSInteger row = [self.categoryPicker selectedRowInComponent:0];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Category"];
        }
        cell.textLabel.text = @"Category";
        [cell addSubview:self.categoryInput];
        self.categoryInput.text = [self.pickerCategories objectAtIndex:row];
    } else if (indexPath.row == 1) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Date"];
        }
        
        cell.textLabel.text = @"Date";
        [cell addSubview:self.dateInput];
        self.dateInput.text = [formatter stringFromDate:self.datePicker.date];
    } else if (indexPath.row == 2) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Amount"];
        }
        cell.textLabel.text = @"Amount";
        
        [cell addSubview:self.amountInput];
    } else if (indexPath.row == 3) {
        NSInteger row = [self.paymentPicker selectedRowInComponent:0];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Method"];
        }
        cell.textLabel.text = @"Payment Method";
        [cell addSubview:self.methodInput];
        self.methodInput.text = [self.paymentMethods objectAtIndex:row];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row = %i, section = %i", indexPath.row, indexPath.section);
    
    if(indexPath.row == 0 && indexPath.section == 0) {
        [self.categoryInput becomeFirstResponder];
    } else if (indexPath.row == 1 && indexPath.section == 0) {
        [self.dateInput becomeFirstResponder];
    } else if (indexPath.row == 2 && indexPath.section == 0) {
        [self.amountInput becomeFirstResponder];
    } else if (indexPath.row == 3 && indexPath.section == 0) {
        [self.methodInput becomeFirstResponder];
    }
}

#pragma mark - Picker view data source

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows;
    
    if ([pickerView tag] == 1) {
        
        rows = [self.pickerCategories count];
    } else if ([pickerView tag] == 2) {
        
        rows = [self.paymentMethods count];
    }
    
    return rows;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{

    return 1;
}


#pragma mark - Picker view delegate

- (NSString *)pickerView:(UIPickerView *)pickerView
titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *result;
    
    if ([pickerView tag] == 1) {
        result = [NSString stringWithString:[self.pickerCategories objectAtIndex:row]];
    } else if ([pickerView tag] == 2) {
        result = [NSString stringWithString:[self.paymentMethods objectAtIndex:row]];
    }
    
    return result;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView tag] == 1) {
    
        self.categoryInput.text = [self.pickerCategories objectAtIndex:row];
        
    } else if ([pickerView tag] == 2) {
        
        self.methodInput.text = [self.paymentMethods objectAtIndex:row];
    }
}

#pragma mark - Text field delegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"tag = %i", [textField tag]);
    NSLog(@"string length = %i", [string length]);
    if ([textField tag] == self.amountTag) {
        
        if (!self.amount) {
            self.amount = [[NSMutableString alloc] init];
        }
        
        if ([string length] == 0 && [self.amount length] > 0) {
            NSRange range = NSMakeRange([self.amount length] - 1, 1);
            [self.amount deleteCharactersInRange:range];
        } else if ([self.amount length] < 7) {
            if ([string isEqualToString:@"0"]) {
                if ([self.amount length] > 0) {
                    [self.amount appendString:string];
                }
            } else {
                [self.amount appendString:string];
            }
        }
        
        NSLog(@"new string = %@", self.amount);
        NSString *newAmount = [self formatCurrencyValue:([self.amount doubleValue]/100)];
        
        [textField setText:[NSString stringWithFormat:@"%@",newAmount]];
        
        return NO;
    }
    return YES;
}

-(NSString*)formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}

-(void)datePickerValueChange
{    
    NSDate *date = self.datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    self.dateInput.text = [formatter stringFromDate:date];
}
     
-(void)editingAmount
{

}

-(void)documentIsReady
{
    if (self.document.documentState == UIDocumentStateNormal) {
        NSLog(@"document state normal");
    }
}

-(IBAction)doDoneButton
{
    NSLog(@"doDoneButton begin");
    
    NSInteger row = [self.categoryPicker selectedRowInComponent:0];
    NSInteger row1 = [self.paymentPicker selectedRowInComponent:0];
    
    if (self.amountInput.text && ![self.amountInput.text isEqualToString:@""] && ![self.amountInput.text isEqualToString:@"$0.00"] ) {
        
        Expenses *expense = [NSEntityDescription insertNewObjectForEntityForName:@"Expenses" inManagedObjectContext:self.document.managedObjectContext]; // Inserting a new row for the entity provided. In this case, it is Expenses.
        // You will want to replace Expenses with Budget.
    
        // This block sets the attributes for the newly added row.
        // Budget will only have 2 attributes. date and amount (lower case)
        expense.category = [self.pickerCategories objectAtIndex:row];
        expense.date = self.datePicker.date;
        NSLog(@"storing amount... %@", self.amountInput.text);
        expense.amount = self.amountInput.text;
        expense.method = [self.paymentMethods objectAtIndex:row1];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        float totalExpenses = [defaults floatForKey:@"totalExpenses"];
        NSString *formattedString = [self.amountInput.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        formattedString = [formattedString stringByReplacingOccurrencesOfString:@"," withString:@""];
        totalExpenses = totalExpenses + [formattedString floatValue];
        [defaults setFloat:totalExpenses forKey:@"totalExpenses"];
        
        NSLog(@"totalExpenses = %f", totalExpenses);
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success){
                [self.topContainer removeFromSuperview];
                [self.categoryPicker selectRow:0 inComponent:0 animated:NO];
                [self.datePicker setDate:[NSDate date]];
                self.amountInput.text = @"";
                self.amount = nil;
                [self.paymentPicker selectRow:0 inComponent:0 animated:NO];
                [self.tableView reloadData];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                UITabBarController *tabController = [storyboard instantiateViewControllerWithIdentifier:@"Tab Controller"];
                tabController.selectedIndex = 3;
                
                [self presentModalViewController:tabController animated:YES];
            } else {
                NSLog(@"couldn't save document at %@", self.document.fileURL);
            }
        }];
    }
}

@end
