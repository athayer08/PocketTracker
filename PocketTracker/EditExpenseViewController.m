//
//  EditExpenseViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 6/15/12.
//  Copyright (c) 2012 __CredAbility__. All rights reserved.
//
//  Implementation file for the Edit Expense view.

#import "EditExpenseViewController.h"

@interface EditExpenseViewController ()

@end

@implementation EditExpenseViewController
@synthesize cancelButton;
@synthesize tableView;
@synthesize categoryInput;
@synthesize methodInput;
@synthesize dateInput;
@synthesize editExpense;
@synthesize fetchedExpenses;
@synthesize fetchedCategories;

@synthesize doneAddExpense, categoryPicker, paymentPicker, datePicker, pickerCategories, paymentMethods, amountInput, amountTag, amount, document;

//Initializes and configures the category picker.
-(void)setupCategoryPicker
{
    //Adds each category to the pickerCategories array. This array
    //serves as the data source for the category picker.
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
    
    //Initializes and configures the category picker.
    self.categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.categoryPicker setTag:1];
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    self.categoryPicker.frame = CGRectMake(0, (screenRect.size.height / 2), 320, 216);
    self.categoryPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.categoryPicker.delegate = self;
    self.categoryPicker.dataSource = self;
    self.categoryPicker.showsSelectionIndicator = YES;
    
}

//Removes the keyboard from the view.
-(void)removeKeyboard
{
    [self.amountInput resignFirstResponder];
}

//Removes the date picker from the view.
-(void)removeDatePicker
{
    [self.dateInput resignFirstResponder];
}

//Removes the category picker from the view.
-(void)removeCategoryPicker
{
    [self.categoryInput resignFirstResponder];
}

//Removes the payment method picker from the view.
-(void)removeMethodPicker
{
    [self.methodInput resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

//Envoked when the view is finished loading.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    //Initializes the object that controls the file system.
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) //Opens the object connecting to the          //file system if it exists
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
            } else {
                NSLog(@"count open document at %@", url);
            }
        }];
    } else {
        //Creates the object connecting to the file system if it does not exist.
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
            } else {
                NSLog(@"couldn't create document at %@", url);
            }
        }];
    }
    
    //Adds each payment method to the paymentMethods array. This array
    //serves as the data source for the payment method picker.
    self.paymentMethods = [[NSMutableArray alloc] init];
    [self.paymentMethods addObject:@"Cash"];
    [self.paymentMethods addObject:@"Credit Card"];
    [self.paymentMethods addObject:@"Debit Card"];
    
    [self setupCategoryPicker];
    
    //Initializes and configures the payment method picker.
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    self.paymentPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.paymentPicker setTag:2];
    self.paymentPicker.frame = CGRectMake(0, (screenRect.size.height / 2), 320, 216);
    self.paymentPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.paymentPicker.delegate = self;
    self.paymentPicker.dataSource = self;
    self.paymentPicker.showsSelectionIndicator = YES;
    
    //Initializes and configures the date picker.
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, (screenRect.size.height / 2), 320, 216)];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker setDate:[NSDate date]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"startDate"]) {
        NSDate *minimumDate = [defaults objectForKey:@"startDate"]; //Earliest day the user can choose is the start date.
        self.datePicker.minimumDate = minimumDate;
        
        NSTimeInterval thirtyDays = 30 * 24 * 60 * 60;
        
        NSDate *maximumDate = [minimumDate dateByAddingTimeInterval:thirtyDays]; //Latest day the user can choose is 30
                                                                                 //days from the start date.
        self.datePicker.maximumDate = maximumDate;
    }
    
    //Initializes and configures the text field holding the amount from user input.
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
    
    //Creates a tool bar with a done button above the keyboard.
    UIToolbar *keyboardTBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    keyboardTBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneKeyboard = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeKeyboard)]; //Done button envokes the removeKeyboard method.
    NSMutableArray *keyboardTbarItems = [[NSMutableArray alloc] init];
    [keyboardTbarItems addObject:doneKeyboard];
    [keyboardTBar setItems:keyboardTbarItems];
    self.amountInput.inputAccessoryView = keyboardTBar;
    
    //Initializes and configures the text field holding the date selected from the date picker.
    self.dateInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.dateInput.delegate = self;
    self.dateInput.textAlignment = UITextAlignmentRight;
    self.dateInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.dateInput setEnabled:YES];
    [self.dateInput setTag:1];
    
    //Creates a tool bar with a done button above the date picker.
    UIToolbar *dateBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    dateBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneDate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeDatePicker)]; //Done button envokes the removeDatePicker method.
    NSMutableArray *dateBarItems = [[NSMutableArray alloc] init];
    [dateBarItems addObject:doneDate];
    [dateBar setItems:dateBarItems];
    self.dateInput.inputView = self.datePicker;
    self.dateInput.inputAccessoryView = dateBar;
    
    //Initializes and configures the text field holding the category selected from the category picker.
    self.categoryInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.categoryInput.delegate = self;
    self.categoryInput.textAlignment = UITextAlignmentRight;
    self.categoryInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.categoryInput setEnabled:YES];
    [self.categoryInput setTag:2];
    
    //Creates a tool bar with a done button above the category picker.
    UIToolbar *categoryBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    categoryBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneCategory = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeCategoryPicker)]; //Done button envokes the removeCategoryPicker method.
    NSMutableArray *categoryBarItems = [[NSMutableArray alloc] init];
    [categoryBarItems addObject:doneCategory];
    [categoryBar setItems:categoryBarItems];
    self.categoryInput.inputView = self.categoryPicker;
    self.categoryInput.inputAccessoryView = categoryBar;
    
    //Initializes and configures the text field holding the payment method selected from the payment method picker.
    self.methodInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.methodInput.delegate = self;
    self.methodInput.textAlignment = UITextAlignmentRight;
    self.methodInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.methodInput setEnabled:YES];
    [self.methodInput setTag:3];
    
    //Creates a tool ar with a done button above the payment method picker.
    UIToolbar *methodBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    methodBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneMethod = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeMethodPicker)]; //Done button envokes the removeMethodPicker method.
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
    [self setCancelButton:nil];
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
    
    //Sets the category picker to the category of the expense to be edited.
    for (NSInteger i = 0; i < [self.pickerCategories count]; i++) {
        if ([self.editExpense.category isEqualToString:[self.pickerCategories objectAtIndex:i]]) {
            [self.categoryPicker selectRow:i inComponent:0 animated:NO];
        }
    }
    
    //Sets the date picker to the date of the expense to be edited.
    [self.datePicker setDate:self.editExpense.date];
    
    //Sets the amount text to the amount of the expense to be edited
    self.amountInput.text = self.editExpense.amount;
    
    //Adjust the amount property for formatting purposes.
    NSString *tempString = [self.editExpense.amount stringByReplacingOccurrencesOfString:@"$" withString:@""];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"," withString:@""];
    tempString = [tempString stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    self.amount = [[NSMutableString alloc] init];
    [self.amount appendString:tempString];
    
    //Sets the payment method picker to the payment method of the expense to be edited. 
    for (NSInteger i = 0; i < [self.paymentMethods count]; i++) {
        if ([self.editExpense.method isEqualToString:[self.paymentMethods objectAtIndex:i]]) {
            [self.paymentPicker selectRow:i inComponent:0 animated:NO];
        }
    }
    
    //The first row has a left text label that displays "Category". The right of the cell contains the
    //category input text field.
    if (indexPath.row == 0) {
        NSInteger row = [self.categoryPicker selectedRowInComponent:0];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Category"];
        }
        cell.textLabel.text = @"Category";
        [cell addSubview:self.categoryInput];
        self.categoryInput.text = [self.pickerCategories objectAtIndex:row];
    } else if (indexPath.row == 1) { //The second row has a left text label that displays "Date". The right of the cell
                                     //contains the date input text field.
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Date"];
        }
        
        cell.textLabel.text = @"Date";
        [cell addSubview:self.dateInput];
        self.dateInput.text = [formatter stringFromDate:self.datePicker.date];
    } else if (indexPath.row == 2) { //The third row has a left text label that displays "Amount". The right of the cell
                                     //contains the amount input text field.
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Amount"];
        }
        cell.textLabel.text = @"Amount";
        
        [cell addSubview:self.amountInput];
    } else if (indexPath.row == 3) { //The fourth row has a left text label that displays "Payment Method". The right
                                     //of the cell containts the payment method input text field.
        NSInteger row = [self.paymentPicker selectedRowInComponent:0];
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Method"];
        }
        cell.textLabel.text = @"Payment Method";
        [cell addSubview:self.methodInput];
        self.methodInput.text = [self.paymentMethods objectAtIndex:row];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //No animation or effects when cell is selected.
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"row = %i, section = %i", indexPath.row, indexPath.section);
    
    if(indexPath.row == 0 && indexPath.section == 0) { //First row is selected...
        [self.categoryInput becomeFirstResponder]; //Display the category picker.
    } else if (indexPath.row == 1 && indexPath.section == 0) { //Second row is selected...
        [self.dateInput becomeFirstResponder]; //Display the date picker.
    } else if (indexPath.row == 2 && indexPath.section == 0) { //Third row is selected...
        [self.amountInput becomeFirstResponder]; //Display the keyobard.
    } else if (indexPath.row == 3 && indexPath.section == 0) { //Fourth row is selected...
        [self.methodInput becomeFirstResponder]; //Display the payment method picker.
    }
}

#pragma mark - Picker view data source

//Returns the number of rows in each of the pickers. Not including the date picker.
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

//Returns the number of columns in each of the pickers. Not including the date picker.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}


#pragma mark - Picker view delegate

//Returns the text that should display in each row of the picker view. Not including
//the date picker.
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *result;
    
    if ([pickerView tag] == 1) { //Category picker
        result = [NSString stringWithString:[self.pickerCategories objectAtIndex:row]]; //Values are stored in this array.
    } else if ([pickerView tag] == 2) { //Payment method picker
        result = [NSString stringWithString:[self.paymentMethods objectAtIndex:row]]; //Values are stored in this array.
    }
    
    return result;
}

//Envoked when the a row is selected within the picker. Not including the date picker.
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView tag] == 1) { //Category picker
        
        self.categoryInput.text = [self.pickerCategories objectAtIndex:row]; //Sets the category input text to the value
                                                                             //selected by the category picker.
        
    } else if ([pickerView tag] == 2) { //Payment method picker
        
        self.methodInput.text = [self.paymentMethods objectAtIndex:row]; //Sets the payment method input text to the value
                                                                         //selected by the payment method picker.
    }
}

#pragma mark - Text field delegate

//Text Field delegate function used in formatting the amount.
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

//Assists in formatting the amount.
-(NSString*)formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}

//This method is called whenever there is a selection change
//inside the date picker. The method changes the text value
//of the text field that holds the date of the expense.
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

//Envoked when the done button is pressed.
-(IBAction)doDoneButton
{
    NSLog(@"doDoneButton begin");
    
    NSInteger row = [self.categoryPicker selectedRowInComponent:0];
    NSInteger row1 = [self.paymentPicker selectedRowInComponent:0];
    
    //Outter if statement ensures that the program doesn't continue if they enter $0.00 
    if (self.amountInput.text && ![self.amountInput.text isEqualToString:@""] && ![self.amountInput.text isEqualToString:@"$0.00"] ) {
        
        //Sets up a fetch request to search the file system for the old expense.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expenses"];
        request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        self.fetchedExpenses = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        self.fetchedExpenses.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(category = %@) AND (date = %@) AND (amount = %@) AND (method = %@)", self.editExpense.category, self.editExpense.date, self.editExpense.amount, self.editExpense.method];
        
        //Perform the search.
        NSError *error;
        [self.fetchedExpenses performFetch:&error];
        
        Expenses *removedExpense = [self.fetchedExpenses.fetchedObjects objectAtIndex:0];
        NSString *removedAmount = removedExpense.amount;
        removedAmount = [removedAmount stringByReplacingOccurrencesOfString:@"$" withString:@""];
        removedAmount = [removedAmount stringByReplacingOccurrencesOfString:@"," withString:@""];
        
        //Remove the old expense from the file system.
        [self.document.managedObjectContext deleteObject:removedExpense];
        
        //Create a new Expense object within the file system. This will replace the expense that we deleted above.
        Expenses *expense = [NSEntityDescription insertNewObjectForEntityForName:@"Expenses" inManagedObjectContext:self.document.managedObjectContext]; 
        expense.category = [self.pickerCategories objectAtIndex:row];
        expense.date = self.datePicker.date;
        NSLog(@"storing amount... %@", self.amountInput.text);
        expense.amount = self.amountInput.text;
        expense.method = [self.paymentMethods objectAtIndex:row1];
        
        //Update the value holding the total expenditures.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        float totalExpenses = [defaults floatForKey:@"totalExpenses"];
        NSString *formattedString = [self.amountInput.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        formattedString = [formattedString stringByReplacingOccurrencesOfString:@"," withString:@""];
        totalExpenses = totalExpenses - [removedAmount floatValue]; //Subtract the expense amount from the old expense.
        totalExpenses = totalExpenses + [formattedString floatValue]; //Add the expense amount from the new expense.
        [defaults setFloat:totalExpenses forKey:@"totalExpenses"]; //Save the new value.
        [defaults synchronize];
        
        NSLog(@"totalExpenses = %f", totalExpenses);
        
        //Saves the information to the file system.
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success){
                [self dismissModalViewControllerAnimated:YES]; //Dismiss the view
            } else {
                NSLog(@"couldn't save document at %@", self.document.fileURL);
            }
        }];
    }
}

//Envoked when the cancel button is pressed.
- (IBAction)doCancelButton {
    
    [self dismissModalViewControllerAnimated:YES]; //Dismiss the view.
    
}

@end
