//
//  SettingsViewController.m
//  PocketTracker
//
//  Created by OSU 758 Capstone on 5/12/12.
//  Copyright (c) 2012 Credibility. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

@synthesize document;
@synthesize fetchedBudget;
@synthesize fetchedExpenses;

//Calculates the total Spending Plan amount for the e-mail.
-(float)calculateTotalBudget
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
    [self setupFetchedBudgetController];
    [self setupFetchedResultsController];
    
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
    float totalBudget = [self calculateTotalBudget];
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
    
    //Display the e-mail.
    [self presentModalViewController:mailController animated:YES];
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

- (void)viewDidLoad
{
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
    
    [super viewDidLoad];
    //initlize email text field
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIAlertView *alertView = [[UIAlertView alloc ] initWithTitle:@"Credability: Pocket Tracker" message:@"Delete all Expense and Spending Plan data?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alertView.delegate = self;
        [alertView show];
    }  else if (indexPath.section == 2 && indexPath.row == 0) {
         [self showEmailModalView];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:YES forKey:@"e-mailNotify"];
        //[defaults setBool:YES forKey:@"initialView"];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController *controller = [storyBoard instantiateViewControllerWithIdentifier:@"Initial View"];
        [self presentModalViewController:controller animated:YES];
        [defaults synchronize];
    }
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

@end
