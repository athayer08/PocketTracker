//
//  InitialViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 5/14/12.
//  Copyright (c) 2012 __CredAbility__. All rights reserved.
//
//  Implementation file for the Welcome Screen.

#import "InitialViewController.h"

@interface InitialViewController ()

@end

@implementation InitialViewController

//"@synthesize" command creates implied getter/setter
//methods for the properties.
@synthesize dateInput;
@synthesize tView;
@synthesize continueButton;
@synthesize amountInput;
@synthesize amount;
@synthesize datePicker;
@synthesize document;
@synthesize fetchedBudget;
@synthesize fetchedExpenses;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//Method used to clear all of the Expense and Spending Plan data 
//from the file system.
-(void) deleteData
{
    //Creates a fetch request for the Spending Plan data in the file system.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SpendingPlan" inManagedObjectContext:self.document.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //Performs the fetch from the file system using the above fetch request. The Spending Plan entries
    //are stored in the array named "items".
    NSError *error;
    NSArray *items = [self.document.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //This loop traversed through the items array and deletes each object from the file system.
    for (SpendingPlan *sPlan in items)
    {
        [self.document.managedObjectContext deleteObject:sPlan];
    }
    
    //This changes the fetch request from Spending Plan entries to Expense entries.
    entity = [NSEntityDescription entityForName:@"Expenses" inManagedObjectContext:self.document.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //Performs the fetch with the new fetch request.
    NSArray *expenses = [self.document.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //This loop traversed through the items array and deletes each object from the file system.
    for (Expenses *expense in expenses)
    {
        [self.document.managedObjectContext deleteObject:expense];
    }
    
    //NSUserDefaults is a lightweight storage object that can store objects that will persist on the
    //file system as long as the app exists on the phone. In this case we are clearing the stored value
    //that keeps track of the total expense amount.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setFloat:0.0 forKey:@"totalExpenses"];
    [defaults synchronize];
    
    //Saves the state of the file system controlling the Spending Plan/Expenses entries.
    [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        if (success){
            
        } else {
            NSLog(@"couldn't save document at %@", self.document.fileURL);
        }
    }];

}

//Calculates the total Spending Plan amount for the e-mail.
-(float)calculateOldTotalBudget
{
    float totalBudget = 0.0;
    for (SpendingPlan *budget in self.fetchedBudget.fetchedObjects) {
        NSString *entry = budget.amount;
        NSLog(@"Budget amount: %@", budget.amount);
        NSString *newEntry = [[entry substringFromIndex:1] stringByReplacingOccurrencesOfString:@"," withString:@""];
        newEntry = [newEntry stringByReplacingOccurrencesOfString:@"$" withString:@""];
        totalBudget = totalBudget + [newEntry floatValue];
    }
    
    return totalBudget;
}

//Encodes images into a base 64 string.
-(NSString *)Base64Encode:(NSData *)data{
    //Point to start of the data and set buffer sizes
    int inLength = [data length];
    int outLength = ((((inLength * 4)/3)/4)*4) + (((inLength * 4)/3)%4 ? 4 : 0);
    const char *inputBuffer = [data bytes];
    char *outputBuffer = malloc(outLength);
    outputBuffer[outLength] = 0;
    
    //64 digit code
    static char Encode[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    //start the count
    int cycle = 0;
    int inpos = 0;
    int outpos = 0;
    char temp;
    
    //Pad the last to bytes, the outbuffer must always be a multiple of 4
    outputBuffer[outLength-1] = '=';
    outputBuffer[outLength-2] = '=';
    
    while (inpos < inLength){
        switch (cycle) {
            case 0:
                outputBuffer[outpos++] = Encode[(inputBuffer[inpos]&0xFC)>>2];
                cycle = 1;
                break;
            case 1:
                temp = (inputBuffer[inpos++]&0x03)<<4;
                outputBuffer[outpos] = Encode[temp];
                cycle = 2;
                break;
            case 2:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xF0)>> 4];
                temp = (inputBuffer[inpos++]&0x0F)<<2;
                outputBuffer[outpos] = Encode[temp];
                cycle = 3;                  
                break;
            case 3:
                outputBuffer[outpos++] = Encode[temp|(inputBuffer[inpos]&0xC0)>>6];
                cycle = 4;
                break;
            case 4:
                outputBuffer[outpos++] = Encode[inputBuffer[inpos++]&0x3f];
                cycle = 0;
                break;                          
            default:
                cycle = 0;
                break;
        }
    }
    NSString *pictemp = [NSString stringWithUTF8String:outputBuffer];
    free(outputBuffer); 
    return pictemp;
}

//Displays the e-mail with HTML.
-(void) showEmailModalView 
{
    NSLog(@"Mail method");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init]; //Controls the mail view.
    NSMutableString *messageBody = [[NSMutableString alloc] init];
    
    //Beginning of the HTML
    [messageBody appendString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><html><head><title>Pocket Tracker E-mail</title><style type=\"text/css\"><style type=\"text/css\"></style><meta content=\"andrewthayer\" name=\"author\"><meta content=\"BlueGriffon wysiwyg editor\" name=\"generator\"><meta content=\"text/html; charset=UTF-8\" http-equiv=\"content-type\"></head><body><div class=\"yui-t1\" id=\"doc3\"><div id=\"hd\"><br><p align=\"center\"><img title=\"Credability Logo\" alt=\"\" src=\"data:image/png;base64,"];
    
    //Sets up the CredAbility Logo to be embedded into the HTML
    NSString *logoPng = [[NSBundle mainBundle] pathForResource:@"CA_tag_4c"
                                                         ofType:@"jpg"];
    UIImage *imageLogo = [[UIImage alloc] initWithContentsOfFile:logoPng];
    NSData *imageLogoData = UIImagePNGRepresentation(imageLogo);
    NSString *logoBase64String = [self Base64Encode:imageLogoData];
    [messageBody appendString:logoBase64String];
    
    //Continuation of the HTML
    [messageBody appendString:@"\"></p><p align=\"center\"><a href=\"file:///Users/andrewthayer/Pictures/E-Mail%20Pictures/www.CredAbility.org\">www.CredAbility.org</a>&nbsp;&nbsp;&nbsp;800.251.2227</p><p align=\"center\"><br></p><p><img title=\"AtAGlance\" alt=\"\" src=\"data:image/png;base64,"];
    
    //Sets up the At a Glance image to be embedded into the HTML.
     NSString *atAGlancePng = [[NSBundle mainBundle] pathForResource:@"AtAGlance"
                                                              ofType:@"png"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:atAGlancePng];
    NSData *imageData = UIImagePNGRepresentation(image);
    NSString *base64String = [self Base64Encode:imageData];
    [messageBody appendString:base64String];
     
    //Continuation of the HTML
    [messageBody appendString:@"\" height=\"113\"width=\"321\"><p><p></p><p></p>"];
    
    //Fetches the Spending Plan entires
    NSError *error;
    [self.fetchedBudget performFetch:&error];
    
    //Calculate the total Spending Plan amount
    float totalBudget = [self calculateOldTotalBudget];
    NSNumber *totalSPlan = [NSNumber numberWithFloat:totalBudget];
    
    //Formats the amount into a pretty string and adds to the HTML string.
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numFormatter setCurrencySymbol:@"$"];
    [numFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [messageBody appendString:@"<table border=\"1\" width=\"100%\"><tbody><tr><td align=\"center\">Total 30 Day Spending Plan<br></td><td align=\"center\">"];
    [messageBody appendString:[numFormatter stringFromNumber:totalSPlan]];
    [messageBody appendString:@"<br></td></tr><tr><td align=\"center\">Total Expenditures<br></td><td align=\"center\">"];
    
    //Retrieves the total Expense amount.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float totalExpenses = [defaults floatForKey:@"totalExpenses"];
    NSNumber *tExpenses = [NSNumber numberWithFloat:totalExpenses];
    
    //Formats the total expense amount and adds it to the HTML string.
    [messageBody appendString:[numFormatter stringFromNumber:tExpenses]];
    
    //Finds the difference between the total Spending Plan and the total Expenses.
    //Determines whether the user is over, under, or on budget. Adds the result
    //to the HTML string
    float difference = totalBudget - totalExpenses;
    if (difference > 0) {
        [messageBody appendString:@"<br></td></tr><tr><td align=\"center\">Under Budget<br></td>"];
    } else if (difference < 0) {
        [messageBody appendString:@"<br></td></tr><tr><td align=\"center\">Over Budget<br></td>"];
    } else {
        [messageBody appendString:@"<br></td></tr><tr><td align=\"center\">On Budget<br></td>"];
    }
    [messageBody appendString:@"<td align=\"center\">"];
    
    //Formats the difference and adds it to the HTML string.
    NSNumber *diffNum = [NSNumber numberWithFloat:difference];
    [messageBody appendString:[numFormatter stringFromNumber:diffNum]];
    [messageBody appendString:@"<br></td></tr></tbody></table><br><img title=\"SpendingPlan\" alt=\"\" src=\"data:image/png;base64,"];
    
    //Sets up the Spending Plan image to be embedded into the HTML.
    NSString *sPlanPng = [[NSBundle mainBundle] pathForResource:@"SpendingPlan" ofType:@"jpg"];
    UIImage *sPlanImage = [[UIImage alloc] initWithContentsOfFile:sPlanPng];
    NSData *sPlanImageData = UIImagePNGRepresentation(sPlanImage);
    NSString *sPlanBase64String = [self Base64Encode:sPlanImageData];
    [messageBody appendString:sPlanBase64String];
    [messageBody appendString:@"\" height=\"89\" width=\"320\"<br><br><table border=\"1\" width=\"100%\"><tbody><tr><td align=\"center\"><b>Date</b><br></td><td align=\"center\"><b>Amount</b></td></tr>"];
    
    //Retrieves all of the Spending Plan entries and adds them to the HTML.
    for (SpendingPlan *sPlan in self.fetchedBudget.fetchedObjects)
    {
        [messageBody appendString:@"<tr><td align=\"center\">"];
        [messageBody appendString:[formatter stringFromDate:sPlan.date]];
        [messageBody appendString:@"<br></td><td align=\"center\">"];
        [messageBody appendString:sPlan.amount];
        [messageBody appendString:@"<br></td></tr>"];
    }
    
    //Formats the Expenses image to be embedded into the HTML.
    [messageBody appendString:@"</tbody></table><br><img title=\"Expenses\" alt=\"\" src=\"data:image/png;base64,"];
    NSString *expensePng = [[NSBundle mainBundle] pathForResource:@"Expenses" ofType:@"jpg"];
    UIImage *expenseImage = [[UIImage alloc] initWithContentsOfFile:expensePng];
    NSData *expenseImageData = UIImagePNGRepresentation(expenseImage);
    NSString *expenseBase64String = [self Base64Encode:expenseImageData];
    [messageBody appendString:expenseBase64String];
    
    //Retrieves all of the expense entries and adds them to the HTML string.
    NSError *error1;
    [self.fetchedExpenses performFetch:&error1];
    [messageBody appendString:@"\" height=\"89\" width=\"320\"<br><br><table border=\"1\" width=\"100%\"><tbody><tr><td align=\"center\"><b>Date</b><br></td><td align=\"center\"><b>Category</b><br></td><td align=\"center\"><b>Amount</b><br></td><td align=\"center\"><b>Payment Method</b><br></td></tr>"];
    for (Expenses *expense in self.fetchedExpenses.fetchedObjects)
    {
        [messageBody appendString:@"<tr><td align=\"center\">"];
        [messageBody appendString:[formatter stringFromDate:expense.date]];
        [messageBody appendString:@"<br></td><td align=\"center\">"];
        [messageBody appendString:expense.category];
        [messageBody appendString:@"<br></td><td align=\"center\">"];
        [messageBody appendString:expense.amount];
        [messageBody appendString:@"<br></td><td align=\"center\">"];
        [messageBody appendString:expense.method];
        [messageBody appendString:@"<br></td></tr>"];
    }
    [messageBody appendString:@"</tbody></table>"];
    [messageBody appendString:@"</html>"];
//    NSLog(@"HTML: %@", messageBody);
    
    //Indicates that this class controls how the mail view operates.
    mailController.mailComposeDelegate = self;
    
    //Calculates the date range for the subject of the e-mail.
    NSDate *startDate = [defaults objectForKey:@"startDate"];
    NSTimeInterval thirtyDays = 30 * 24 * 60 * 60;
    NSMutableString *subject = [[NSMutableString alloc] init];
    [subject appendString:@"CredAbility Pocket Tracker Report: "];
    [subject appendString:[formatter stringFromDate:startDate]];
    [subject appendString:@" to "];
    [subject appendString:[formatter stringFromDate:[NSDate dateWithTimeInterval:thirtyDays sinceDate:startDate]]];
    [mailController setSubject:subject];
    
    //Sets the HTML string as the message body.
    [mailController setMessageBody:messageBody isHTML:YES];
    
    //Now that the e-mail is created, delete all of the Spending Plan and Expense data from the
    //file system.
    [self deleteData];
    
    //Display the e-mail.
    [self presentModalViewController:mailController animated:YES];
}

//Removes the keyboard from the view and
//adjusts the view back to normal.
-(void)removeKeyboard
{
    CGRect rect = self.view.frame;
    rect.origin.y += 44.0f;
    rect.size.height -= 44.0f;
    self.view.frame = rect;
    [self.dateInput setEnabled:YES];
    [self.amountInput resignFirstResponder];
}

//Removes the date picker from the view
//and adjusts the view back to normal.
-(void)removePicker
{
    CGRect rect = self.view.frame;
    rect.origin.y += 88.0f;
    rect.size.height -= 88.0f;
    self.view.frame = rect;
    [self.amountInput setEnabled:YES];
    [self.dateInput resignFirstResponder];
}

-(void)editingAmount
{

}

//This method is called whenever there is a selection change
//inside the date picker. The method changes the text value
//of the text field that holds the start date on the view.
-(void)datePickerValueChange
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tView cellForRowAtIndexPath:indexPath];
    
    NSDate *date = self.datePicker.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    self.dateInput.text = [formatter stringFromDate:date];
    [cell setHighlighted:YES];
}

//This method is called when the continue button is pressed.
-(IBAction)doContinue
{    
    //Outter if statement ensures that the program doesn't continue if they enter $0.00 
    if (self.amountInput.text && ![self.amountInput.text isEqualToString:@""] && ![self.amountInput.text isEqualToString:@"$0.00"] ) {
        NSLog(@"doContinue");
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //Inserts inital Spending Plan entry into the file system.
        SpendingPlan *budget = [NSEntityDescription insertNewObjectForEntityForName:@"SpendingPlan" inManagedObjectContext:self.document.managedObjectContext]; 
        
        budget.date = self.datePicker.date;
        budget.amount = self.amountInput.text;
        
        //Saves the file system.
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success){
                if (![defaults boolForKey:@"notFirstLoad"]) {
                    [defaults setBool:YES forKey:@"notFirstLoad"]; //Sets a flag in the defaults indicating that this is
                                                                   //not the first load of the application.
                }
    
                if ([defaults boolForKey:@"initialView"]) {
                    [defaults setBool:NO forKey:@"initialView"]; //Sets a flag in the defaults indicating that it should
                                                                 //NOT load this view when the application becomes active.
                }
                
                //Stores the start date in the defaults.
                [defaults setObject:self.datePicker.date forKey:@"startDate"];
                [defaults synchronize];
                
                //Loads the Tab Bar Controller that controls the Summary, Spending Plan, Add Expense, etc. Views.
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
                UIViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"Tab Controller"];
                
                [self presentModalViewController:controller animated:YES];
            } else {
                NSLog(@"couldn't save document at %@", self.document.fileURL);
            }
        }];
    }
}

//Sets up the controller that queries the file system for Expense entries.
-(void) setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expenses"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedExpenses = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
}

//Sets up the controller that queries the file system for Spending Plan entries.
-(void)setupFetchedBudgetController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SpendingPlan"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedBudget = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void) setupView
{
    NSLog(@"setupView");
    [self setupFetchedBudgetController];
    [self setupFetchedResultsController];
    
    //Sets the action for the continue to be the method "doContinue"
    [self.continueButton setAction:@selector(doContinue)];
    [self.continueButton setTarget:self];
    
    //Initializes the text field for the Spending Plan input. This code block also adjusts its
    //size and other formatting details.
    self.amountInput = [[UITextField alloc] initWithFrame:CGRectMake(105, 12, 170, 30)];
    self.amountInput.delegate = self;
    self.amountInput.placeholder = @"$0.00";
    self.amountInput.keyboardType = UIKeyboardTypeNumberPad;
    self.amountInput.returnKeyType = UIReturnKeyDefault;
    self.amountInput.textAlignment = UITextAlignmentRight;
    self.amountInput.adjustsFontSizeToFitWidth = YES;
    [self.amountInput addTarget:self action:@selector(editingAmount) forControlEvents:UIControlEventEditingDidBegin];
    [self.amountInput setEnabled:YES];
    [self.amountInput setTag:0];
    
    //Creates a tool bar with a done button above the keyboard.
    UIToolbar *keyboardTBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    keyboardTBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneKeyboard = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeKeyboard)]; //When the done button is pressed, the "removeKeyboard" method is
                                                //envoked. 
    NSMutableArray *keyboardTbarItems = [[NSMutableArray alloc] init];
    [keyboardTbarItems addObject:doneKeyboard];
    [keyboardTBar setItems:keyboardTbarItems];
    self.amountInput.inputAccessoryView = keyboardTBar;
    
    //Initialzes the date text field. This code block also adjusts its
    //size and other formatting details.
    self.dateInput = [[UITextField alloc] initWithFrame:CGRectMake(105, 12, 170, 30)];
    self.dateInput.delegate = self;
    self.dateInput.textAlignment = UITextAlignmentRight;
    self.dateInput.textColor = [UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0];
    [self.dateInput setEnabled:YES];
    [self.dateInput setTag:1];
    
    //Creates a tool bar with a done button above the date picker.
    UIToolbar *closePicker = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    closePicker.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removePicker)]; //When the done button is pressed, the "removePicker" method is
                                         //envoked.
    NSMutableArray *barItems = [[NSMutableArray alloc] init];
    [barItems addObject:done];
    [closePicker setItems:barItems];
    
    //Initialzes the date picker. This code block also adjusts its
    //size and other formatting details.
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    CGSize datePickerSize = [self.datePicker sizeThatFits:CGSizeZero];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, screenRect.origin.y + screenRect.size.height - 200.0, datePickerSize.width, datePickerSize.height)];
    self.datePicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    [self.datePicker setDate:[NSDate date]];
    
    self.datePicker.maximumDate = [NSDate date]; //Latest day the user can choose is today's date.
    
    NSTimeInterval thirtyDays = -1 * (30 * 24 * 60 * 60);
    
    //Earliest date the user can choose is 30 days prior to today's date.
    self.datePicker.minimumDate = [NSDate dateWithTimeInterval:thirtyDays sinceDate:[NSDate date]];
    self.dateInput.inputView = self.datePicker;
    self.dateInput.inputAccessoryView = closePicker;
}

//This method is called right after the view is loaded.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Indicates that this class will control the table view.
    self.tView.delegate = self;
    self.tView.dataSource = self;
    
    //Disables scrolling in the Table View.
    self.tView.scrollEnabled = NO;
    
    //Initializes the object that controls the file system.
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]]) //Opens the object connecting to the          //file system if it exists
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults boolForKey:@"e-mailNotify"]) { //If the e-mailNotify flag is set then the user should be
                                                             //prompted with the option to send their 30 day report.
                    
                    //Displays popup
                    UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Credability: Pocket Tracker" message:@"Would you like to e-mail your 30 day report?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    
                    [alertView show];
                }
            } else {
                NSLog(@"count open document at %@", url);
            }
        }];
    } else {
        //Creates the object connecting to the file system if it does not exist.
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success){
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                if ([defaults boolForKey:@"e-mailNotify"]) {
                    UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Credability: Pocket Tracker" message:@"Would you like to e-mail your 30 day report?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                    
                    [alertView show];
                }
            } else {
                NSLog(@"couldn't create document at %@", url);
            }
        }];
    }
    
    //Calls "setupView" method.
    [self setupView];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setContinueButton:nil];
    [self setView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//Table View delegate function that indicates how many rows will be in each section.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2; //Since there is only one section, we can return the exact value.
}

//Table View delegate function that indicates how many sections will be in the table.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//Table View delegate function that determines what will appear in each cell of the Table View
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.datePicker addTarget:self action:@selector(datePickerValueChange) forControlEvents:UIControlEventValueChanged];

    static NSString *cellIdentifier = @"Initial View Cell"; //Identifier used in the Storyboard
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier]; //Creates a cell object that was already designed in the storyboard.
    
    if (cell == nil) { //If the cell isn't found, create one.
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.row == 0) { //First row
        cell.textLabel.text = @"Spending Plan"; //Set the left text label.
        
        [cell addSubview:self.amountInput]; //Adds the Spending Plan amount text field to the right of the cell.
    } else if (indexPath.row == 1) { //Second row
        cell.textLabel.text = @"Start Date"; //Set the left text label.
        
        //Format the date.
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        self.dateInput.text = [formatter stringFromDate:self.datePicker.date]; //Sets the date selected by the date picker.
        
        [cell addSubview:self.dateInput]; //Adds the text field containing the date display
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone]; //No selection style
    return cell;
}

//Table View delegate function that is called when a cell is selected.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) { //If the first row is selected...
        [self.amountInput becomeFirstResponder]; //Keyboard displays for the Spending Plan amount text field.
    } else if (indexPath.row == 1) { //If the second row is selected...
        [self.dateInput becomeFirstResponder]; //Date picker displays for the Start Date text field.
    }
}

//Text Field delegate function used in formatting the Spending Plan amount.
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"tag = %i", [textField tag]);
    NSLog(@"string length = %i", [string length]);
        
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

//Adjusts the position of the view so that the keyboard/Date picker
//do not hide the amount/date text fields.
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect rect = self.view.frame;
    if (textField.tag == 0) {
        rect.origin.y -= 44.0f;
        rect.size.height += 44.0f;
        [self.dateInput setEnabled:NO];
    } else if (textField.tag == 1) {
        rect.origin.y -= 88.0f;
        rect.size.height += 88.0f;
        [self.amountInput setEnabled:NO];
    }
    self.view.frame = rect;
    
    return YES;
}

//Assists in formatting the Spending Plan amount.
-(NSString*)formatCurrencyValue:(double)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    NSNumber *c = [NSNumber numberWithFloat:value];
    return [numberFormatter stringFromNumber:c];
}

//Mail Delegate method that is envoked when the e-mail is dismissed in any way.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            //Handle Error
        }
            
        break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

//This method is envoked whenever a button is pressed on the e-mail notification.
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"e-mailNotify"]) {
        [defaults setBool:NO forKey:@"e-mailNotify"]; //Set the e-mail notify flag to NO.
    }
    [defaults setBool:YES forKey:@"initialView"]; //Indicates that the Welcome screen should be the next view.
    [defaults synchronize];
    if (buttonIndex == 1) { //If Yes is pressed...
        [self showEmailModalView]; //Display e-mail.
    } else { //If No is pressed...
        [self deleteData]; //Delete all of the data.
    }
}
@end
