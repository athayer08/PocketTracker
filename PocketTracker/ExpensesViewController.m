//
//  ExpensesViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExpensesViewController.h"

@interface ExpensesViewController ()

@end

@implementation ExpensesViewController
@synthesize tableView;

@synthesize category, document, fetchedResultsController, isLoading, pickerCategories, categoryPicker, topContainer, paymentMethods, paymentPicker, method, fetchedBudgetResults, categoryInput, methodInput, fetchedCategories;


-(NSString *) calculateTotalBudgetString
{
    float totalBudget = 0.0;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setCurrencySymbol:@"$"];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    for (SpendingPlan *budget in self.fetchedBudgetResults.fetchedObjects) {
        NSString *entry = budget.amount;
        NSString *newEntry = [[entry substringFromIndex:1] stringByReplacingOccurrencesOfString:@"," withString:@""];
        totalBudget = totalBudget + [newEntry floatValue];
    }

    NSLog(@"Budget: $%@", [formatter stringFromNumber:[NSNumber numberWithFloat:totalBudget]]);
    return [formatter stringFromNumber:[NSNumber numberWithFloat:totalBudget]];
}

-(NSString *) calculateBalanceString
{
    NSString *budgetString = [self calculateTotalBudgetString];
    NSString *formattedString = [budgetString stringByReplacingOccurrencesOfString:@"$" withString:@""];
    formattedString = [formattedString stringByReplacingOccurrencesOfString:@"," withString:@""];
    float budget = [formattedString floatValue];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float totalExpenses = [defaults floatForKey:@"totalExpenses"];
    NSLog(@"Total Expenses: %f", totalExpenses);
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setCurrencySymbol:@"$"];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSLog(@"Balance: %@", [formatter stringFromNumber:[NSNumber numberWithFloat:(budget - totalExpenses)]]);
    return [formatter stringFromNumber:[NSNumber numberWithFloat:(budget - totalExpenses)]];
}

-(void)deselectAllRows
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)doFetch
{
    NSLog(@"doFetch");
    NSLog(@"predicate before: %@", [self.fetchedResultsController.fetchRequest.predicate predicateFormat]);
    NSLog(@"before category = %@ and before method = %@", self.category, self.method);
    if(self.category) {
        if (self.method) {
            self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(category = %@) AND (method = %@)", self.category, self.method];
            NSLog(@"predicate is category and method");
        } else {
            self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(category = %@)", self.category];
            NSLog(@"predicate is category");
        }
    } else {
        if (!self.method) {
            self.fetchedResultsController.fetchRequest.predicate = nil;
            NSLog(@"no predicate");
        } else {
            NSLog(@"Total Expenses and not Show All");
            self.fetchedResultsController.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(method = %@)", self.method];
        }
    }
    NSLog(@"predicate after: %@", [self.fetchedResultsController.fetchRequest.predicate predicateFormat]);
    NSLog(@"after category = %@ and after method = %@", self.category, self.method);
    
    NSError *error;
    NSError *errorBudget;
    [self.fetchedResultsController performFetch:&error];
    [self.fetchedBudgetResults performFetch:&errorBudget];
    [self.tableView reloadData];
}

-(void)updateCategories
{
    
    for (NSInteger i = 9; i < [pickerCategories count] ; i++) {
        [pickerCategories removeObjectAtIndex:i];
    }
    
    NSError *error;
    [self.fetchedCategories performFetch:&error];
    
    for (CustomCategories *customCategory in self.fetchedCategories.fetchedObjects) {
        if (![self.pickerCategories containsObject:customCategory.category]) {
            [self.pickerCategories addObject:customCategory.category];
        }
    }
    
    [self.categoryPicker reloadAllComponents];

}

- (void)setupFetchedResultsController
{    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expenses"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSFetchRequest *requestBudget = [NSFetchRequest fetchRequestWithEntityName:@"SpendingPlan"];
    requestBudget.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];

    self.fetchedBudgetResults = [[NSFetchedResultsController alloc] initWithFetchRequest:requestBudget managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil] ;
        
    NSFetchRequest *requestCategories = [NSFetchRequest fetchRequestWithEntityName:@"CustomCategories"];
    requestCategories.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES]];
    self.fetchedCategories = [[NSFetchedResultsController alloc] initWithFetchRequest:requestCategories managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
    [self updateCategories];
    [self doFetch];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!isLoading) {
        [self updateCategories];
        [self doFetch];
    } else {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
        self.document = [[UIManagedDocument alloc] initWithFileURL:url];
        if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
        {
            [self.document openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [self setupFetchedResultsController];
                } else {
                    NSLog(@"count open document at %@", url);
                }
            }];
        } else {
            [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success)
                {
                    [self setupFetchedResultsController];
                } else {
                    NSLog(@"couldn't create document at %@", url);
                }
            }];
        }
        self.isLoading = NO;
    }
    [super viewWillAppear:animated];
}

-(void)removeCategoryPicker
{
    [self.categoryInput resignFirstResponder];
    [self doFetch];

}

-(void)removeMethodPicker
{
    [self.methodInput resignFirstResponder];
    [self doFetch];
}

- (void)viewDidLoad
{
    self.isLoading = YES;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.pickerCategories =[[NSMutableArray alloc] init ];
    [self.pickerCategories addObject:@"Total Expenses"];
    [self.pickerCategories addObject:@"Grocery, Dining"];
    [self.pickerCategories addObject:@"Auto: Gas, Maintenance"];
    [self.pickerCategories addObject:@"Medical"];
    [self.pickerCategories addObject:@"Children, Education"];
    [self.pickerCategories addObject:@"Clothing"];
    [self.pickerCategories addObject:@"Personal Items"];
    [self.pickerCategories addObject:@"Fun, Entertainment"];
    [self.pickerCategories addObject:@"Savings"];
    [self.pickerCategories addObject:@"Miscellaneous"];
    
    self.paymentMethods = [[NSMutableArray alloc] init];
    [self.paymentMethods addObject:@"Show All"];
    [self.paymentMethods addObject:@"Cash"];
    [self.paymentMethods addObject:@"Credit Card"];
    [self.paymentMethods addObject:@"Debit Card"];

    
    self.categoryPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.categoryPicker setTag:1];
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    self.categoryPicker.frame = CGRectMake(0.0, (screenRect.size.height / 2), 320, 216);
    self.categoryPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.categoryPicker.delegate = self;
    self.categoryPicker.dataSource = self;
    self.categoryPicker.showsSelectionIndicator = YES;
    
    self.paymentPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.paymentPicker setTag:2];
    self.paymentPicker.frame = CGRectMake(0.0, (screenRect.size.height / 2), 320, 216);
    self.paymentPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.paymentPicker.delegate = self;
    self.paymentPicker.dataSource = self;
    self.paymentPicker.showsSelectionIndicator = YES;
    
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
    
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    } else if (section == 1) {
        return 2;
    } else if (section == 2) {
        if (self.fetchedResultsController.fetchedObjects) {
            return [self.fetchedResultsController.fetchedObjects count];
        } else {
            return 0;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        NSInteger row = [self.categoryPicker selectedRowInComponent:0];
        NSString *CellIdentifier = @"Category Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        if (indexPath.row == 0) {
            row = [self.categoryPicker selectedRowInComponent:0];
            cell.textLabel.text = @"Category";
            self.categoryInput.text = [self.pickerCategories objectAtIndex:row];
            [cell addSubview:self.categoryInput];
        } else if (indexPath.row == 1) {
            row = [self.paymentPicker selectedRowInComponent:0];
            cell.textLabel.text = @"Payment Method";
            self.methodInput.text = [self.paymentMethods objectAtIndex:row];
            [cell addSubview:self.methodInput];
        }
        
    } else if (indexPath.section == 1) {
        NSString *CellIdentifier = @"Expense Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if(indexPath.row == 0) {
            cell.textLabel.text = @"Spending Plan";
            cell.detailTextLabel.text = [self calculateTotalBudgetString];
        } else if (indexPath.row == 1) {
            cell.textLabel.text = @"Balance";
            if ([[self calculateBalanceString] characterAtIndex:0] == 40) {
                cell.detailTextLabel.textColor = [UIColor redColor];
            } else {
                cell.detailTextLabel.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
            }
            cell.detailTextLabel.text = [self calculateBalanceString];
        }
    } else if (indexPath.section == 2) {
        
        Expenses *expense = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        
        if (!category) {
            cell = [[UITableViewCell alloc] init];
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            
            UILabel *dateLabel;
            UILabel *amountLabel;
            UILabel *categoryLabel;
            
            dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            dateLabel.frame = CGRectMake(20.0, 15.0, 100.0, 21.0);
            dateLabel.text = [formatter stringFromDate:expense.date];
            dateLabel.adjustsFontSizeToFitWidth = YES;
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.font = [UIFont boldSystemFontOfSize:17];
            dateLabel.textAlignment = UITextAlignmentLeft;
            
            categoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            categoryLabel.frame = CGRectMake(20.0, 40.0, 150.0, 21.0);
            categoryLabel.text = expense.category;
            categoryLabel.adjustsFontSizeToFitWidth = NO;
            categoryLabel.backgroundColor = [UIColor clearColor];
            categoryLabel.font = [UIFont systemFontOfSize:10.0];
            categoryLabel.textAlignment = UITextAlignmentLeft;
            
            amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            amountLabel.frame = CGRectMake(190.0, 27.5, 76.0, 21.0);
            amountLabel.text = expense.amount;
            amountLabel.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
            amountLabel.adjustsFontSizeToFitWidth = YES;
            amountLabel.backgroundColor = [UIColor clearColor];
            amountLabel.font = [UIFont systemFontOfSize:17];
            amountLabel.textAlignment = UITextAlignmentRight;
            
            if (!method) {
                amountLabel.frame = CGRectMake(190.0, 15.0, 76.0, 21.0);
                
                UILabel *methodLabel = [[UILabel alloc] initWithFrame:CGRectMake(190.0, 40.0, 76.0, 21.0)];
                methodLabel.text = expense.method;
                methodLabel.adjustsFontSizeToFitWidth = NO;
                methodLabel.backgroundColor = [UIColor clearColor];
                methodLabel.font = [UIFont systemFontOfSize:10.0];
                methodLabel.textAlignment = UITextAlignmentRight;
                
                [cell addSubview:methodLabel];
            }
            
            [cell addSubview:dateLabel];
            [cell addSubview:categoryLabel];
            [cell addSubview:amountLabel];
        } else if (!self.method) {
            cell = [[UITableViewCell alloc] init];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *dateLabel;
            UILabel *amountLabel;
            UILabel *methodLabel;
            
            dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            dateLabel.frame = CGRectMake(20.0, 27.5, 100.0, 21.0);
            dateLabel.text = [formatter stringFromDate:expense.date];
            dateLabel.adjustsFontSizeToFitWidth = YES;
            dateLabel.backgroundColor = [UIColor clearColor];
            dateLabel.font = [UIFont boldSystemFontOfSize:17];
            dateLabel.textAlignment = UITextAlignmentLeft;
            
            amountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            amountLabel.frame = CGRectMake(190.0, 15.0, 76.0, 21.0);
            amountLabel.text = expense.amount;
            amountLabel.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
            amountLabel.adjustsFontSizeToFitWidth = YES;
            amountLabel.backgroundColor = [UIColor clearColor];
            amountLabel.font = [UIFont systemFontOfSize:17];
            amountLabel.textAlignment = UITextAlignmentRight;
            
            methodLabel = [[UILabel alloc] initWithFrame:CGRectMake(190.0, 40.0, 76.0, 21.0)];
            methodLabel.text = expense.method;
            methodLabel.adjustsFontSizeToFitWidth = NO;
            methodLabel.backgroundColor = [UIColor clearColor];
            methodLabel.font = [UIFont systemFontOfSize:10.0];
            methodLabel.textAlignment = UITextAlignmentRight;
            
            [cell addSubview:dateLabel];
            [cell addSubview:amountLabel];
            [cell addSubview:methodLabel];
        } else {
            NSString *cellIdentifier = @"Expense Cell";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            cell.textLabel.text = [formatter stringFromDate:expense.date];
            cell.detailTextLabel.text = expense.amount;
        }
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2 && (!self.category || !self.method)) {
        return 75.0;
    }
    return self.tableView.rowHeight;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        Expenses *expense = [fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        NSLog(@"Category: %@", expense.category);
        NSLog(@"Date: %@", [formatter stringFromDate:expense.date]);
        NSLog(@"Amount: %@", expense.amount);
        NSLog(@"Method: %@", expense.method);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        EditExpenseViewController *editController = [storyboard instantiateViewControllerWithIdentifier:@"Edit Expense Controller"];
        editController.editExpense = expense;
        
        [self presentModalViewController:editController animated:YES];  
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0) {

    } else {
        if (indexPath.row == 0) {
            [self.categoryInput becomeFirstResponder];
        } else if (indexPath.row == 1) {
            [self.methodInput becomeFirstResponder];
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (indexPath.section == 2)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSInteger row = [indexPath row];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            float totalExpenses = [defaults floatForKey:@"totalExpenses"];
            Expenses *expense = [self.fetchedResultsController.fetchedObjects objectAtIndex:row];
            NSString *formattedString = [expense.amount stringByReplacingOccurrencesOfString:@"$" withString:@""];
            formattedString = [formattedString stringByReplacingOccurrencesOfString:@"," withString:@""];
            totalExpenses = totalExpenses - [formattedString floatValue];
            NSLog(@"totalExpenses: %f", totalExpenses);
            [self.document.managedObjectContext deleteObject:[self.fetchedResultsController.fetchedObjects objectAtIndex:row]];
            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                if (success){
                    [defaults setFloat:totalExpenses forKey:@"totalExpenses"];
                    [self doFetch];
                    [tableView reloadData];
                } else {
                    NSLog(@"couldn't save document at %@", self.document.fileURL);
                }
            }];
        }
    }
}

#pragma mark - Picker view data source

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rows = 0;
    
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
        
        NSString *result = [NSString stringWithString:[self.pickerCategories objectAtIndex:row]];
        if ([result isEqualToString:@"Total Expenses"]) {
            self.category = nil;
        } else {
            self.category = result;
        }
    } else if ([pickerView tag] == 2) {
        
        self.methodInput.text = [self.paymentMethods objectAtIndex:row];
        
        NSString *result = [NSString stringWithString:[self.paymentMethods objectAtIndex:row]];
        if ([result isEqualToString:@"Show All"]) {
            self.method = nil;
        } else {
            self.method = result;
        }
    }
    
}

@end
