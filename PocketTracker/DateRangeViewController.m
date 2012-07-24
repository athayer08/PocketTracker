//
//  DateRangeViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateRangeViewController.h"

@interface DateRangeViewController ()

@end

@implementation DateRangeViewController
@synthesize tView;
@synthesize doneButton;
@synthesize startPicker;
@synthesize startInput;
@synthesize endPicker;
@synthesize endInput;
@synthesize document;
@synthesize fetchedBudget;
@synthesize fetchedExpenses;

-(void)removeStartDatePicker
{
    [self.startInput resignFirstResponder];
}

-(void)removeEndDatePicker
{
    [self.endInput resignFirstResponder];
}

-(void)startDatePickerValueChange
{    
    NSDate *date = self.startPicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    self.startInput.text = [formatter stringFromDate:date];
}

-(void)endDatePickerValueChange
{    
    NSDate *date = self.endPicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    self.endInput.text = [formatter stringFromDate:date];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
            } else {
                NSLog(@"count open document at %@", url);
            }
        }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
            } else {
                NSLog(@"couldn't create document at %@", url);
            }
        }];
    }
    
    self.tView.dataSource = self;
    self.tView.delegate = self;

    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];

    self.startPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, (screenRect.size.height / 2), 320, 216)];
    self.startPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.startPicker.datePickerMode = UIDatePickerModeDate;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"startDate"]) {
        [self.startPicker setDate:[defaults objectForKey:@"startDate"]];
        NSDate *minimumDate = [defaults objectForKey:@"startDate"];
        self.startPicker.minimumDate = minimumDate;
        self.startPicker.maximumDate = [NSDate date];
    }
    
    
    self.endPicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, (screenRect.size.height / 2), 320, 216)];
    self.endPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.endPicker.datePickerMode = UIDatePickerModeDate;
    [self.endPicker setDate:[defaults objectForKey:@"endDate"]];
    self.endPicker.minimumDate = [NSDate date];
    
    self.startInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.startInput.delegate = self;
    self.startInput.textAlignment = UITextAlignmentRight;
    self.startInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.startInput setEnabled:YES];
    
    UIToolbar *startDateBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    startDateBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneStartDate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeStartDatePicker)];
    NSMutableArray *startDateBarItems = [[NSMutableArray alloc] init];
    [startDateBarItems addObject:doneStartDate];
    [startDateBar setItems:startDateBarItems];
    self.startInput.inputView = self.startPicker;
    self.startInput.inputAccessoryView = startDateBar;
    
    self.endInput = [[UITextField alloc] initWithFrame:CGRectMake(120, 12, 170, 30)];
    self.endInput.delegate = self;
    self.endInput.textAlignment = UITextAlignmentRight;
    self.endInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.endInput setEnabled:YES];
    
    UIToolbar *endDateBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    endDateBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneEndDate = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeEndDatePicker)];
    NSMutableArray *endDateBarItems = [[NSMutableArray alloc] init];
    [endDateBarItems addObject:doneEndDate];
    [endDateBar setItems:endDateBarItems];
    self.endInput.inputView = self.endPicker;
    self.endInput.inputAccessoryView = endDateBar;
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setDoneButton:nil];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.startPicker addTarget:self action:@selector(startDatePickerValueChange) forControlEvents:UIControlEventValueChanged];
    [self.endPicker addTarget:self action:@selector(endDatePickerValueChange) forControlEvents:UIControlEventValueChanged];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Date Range Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Date Range Cell"];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"Start Date";
        self.startInput.text = [formatter stringFromDate:[self.startPicker date]];
        [cell addSubview:self.startInput];
    } else if (indexPath.section == 1) {
        cell.textLabel.text = @"End Date";
        self.endInput.text = [formatter stringFromDate:[self.endPicker date]];
        [cell addSubview:self.endInput];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.startInput becomeFirstResponder];
    } else if (indexPath.section == 1) {
        [self.endInput becomeFirstResponder];
    }
}

- (IBAction)doDone:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *newStartDate = self.startPicker.date;
    NSDate *newEndDate = self.endPicker.date;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/YYYY"];
    
    NSLog(@"New Start Date: %@", [dateFormatter stringFromDate:newStartDate]);
    NSLog(@"New End Date: %@", [dateFormatter stringFromDate:newEndDate]);
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expenses"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"(date < %@) OR (date > %@)", newStartDate, newEndDate];
    
    self.fetchedExpenses = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSFetchRequest *requestBudget = [NSFetchRequest fetchRequestWithEntityName:@"SpendingPlan"];
    requestBudget.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    requestBudget.predicate = [NSPredicate predicateWithFormat:@"(date < %@) OR (date > %@)", newStartDate, newEndDate];
    
    self.fetchedBudget = [[NSFetchedResultsController alloc] initWithFetchRequest:requestBudget managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil] ;
    
    NSError *error1;
    NSError *error2;
    [self.fetchedExpenses performFetch:&error1];
    [self.fetchedBudget performFetch:&error2];
    
    for (SpendingPlan *sPlan in self.fetchedBudget.fetchedObjects)
    {
        NSLog(@"Deleting Plan: %@", sPlan.amount);
        [self.document.managedObjectContext deleteObject:sPlan];
    }
    
    float totalExpenses = [defaults floatForKey:@"totalExpenses"];
    for (Expenses *expense in self.fetchedExpenses.fetchedObjects)
    {
        NSLog(@"Deleting Expense: %@", expense.amount);
        
        NSString *formattedString = [expense.amount stringByReplacingOccurrencesOfString:@"$" withString:@""];
        formattedString = [formattedString stringByReplacingOccurrencesOfString:@"," withString:@""];
        totalExpenses = totalExpenses - [formattedString floatValue];

        [self.document.managedObjectContext deleteObject:expense];
    }
    
    [defaults setFloat:totalExpenses forKey:@"totalExpenses"];
    [defaults setObject:self.startPicker.date forKey:@"startDate"];
    [defaults setObject:self.endPicker.date forKey:@"endDate"];
    [defaults synchronize];
    
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (success){
           
        } else {
            NSLog(@"couldn't save document at %@", self.document.fileURL);
        }
    }];
}
@end
