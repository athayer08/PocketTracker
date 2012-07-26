//
//  ViewController.m
//  PocketTracker
//
//  Created by OSU 758 Capstone on 5/12/12.
//  Copyright (c) 2012 Credibility. All rights reserved.
//

#import "SpendingPlanViewController.h"

@interface SpendingPlanViewController ()

@end

@implementation SpendingPlanViewController
@synthesize tableView;

@synthesize document, isLoading, fetchedResultsController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isLoading = YES;
    self.tableView.delegate = self; //This class controls the table view
    self.tableView.dataSource = self; //This class controls the data source of the table view
    
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//Envoked right before the view appears
-(void) viewWillAppear:(BOOL)animated {
    NSLog(@"Viewwillappear");
    if (!isLoading) {
        [self doFetch];
    } else {
        
        UIView *loadingView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 480.0)];
        loadingView.opaque = NO;
        loadingView.backgroundColor = [UIColor darkGrayColor];
        loadingView.alpha = 0.5;
        UIActivityIndicatorView *loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        loading.frame = CGRectMake(0.0, 0.0, 40.0, 40.0);
        loading.center = self.view.center;
        [loadingView addSubview:loading];
        [self.view addSubview:loadingView];
        
        [loading startAnimating];
        
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
        self.document = [[UIManagedDocument alloc] initWithFileURL:url];
        if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
        {
            [self.document openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    NSLog(@"Before setup");
                    [self setupFetchedResultsController];
                    [loadingView removeFromSuperview];
                    [loading stopAnimating];
                    NSLog(@"After setup fetched");
                } else {
                    NSLog(@"count open document at %@", url);
                }
            }];
        } else {
            [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success)
                {
                    NSLog(@"Before setup");
                    [self setupFetchedResultsController];
                    [loadingView removeFromSuperview];
                    [loading stopAnimating];
                    NSLog(@"After setup fetched");
                } else {
                    NSLog(@"couldn't create document at %@", url);
                }
            }];
        }
        self.isLoading = NO;
        
    }
    [super viewWillAppear:animated];
}

-(void) doFetch {
    //fetch data (added income amount and date added) from stored database
    NSLog(@"doFetch");
    
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    NSLog(@"objects: %i", [self.fetchedResultsController.fetchedObjects count]);
    [self.tableView reloadData];
}

- (void)setupFetchedResultsController
{
    NSLog(@"setupFetched");
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SpendingPlan"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    [self doFetch];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    if(section == 0) {
        return 1;
    } else {
        //number of rows will depend on the number of entries stored in the database
        if (self.fetchedResultsController.fetchedObjects) {
            return [self.fetchedResultsController.fetchedObjects count];
        } else {
            return 0;
        }
    }
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    NSString *CellIdentifier;
    NSDecimalNumber *ftotal = [NSDecimalNumber zero];
    //first cell in table view is the total Spending Plan cell
    if(indexPath.section == 0 && indexPath.row == 0) {
        CellIdentifier = @"Total Cell";
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = @"Total";
        
        NSLog(@"fetched array %i", [self.fetchedResultsController.fetchedObjects count]);
        
        //calculate the total sum of all the entries
        for (SpendingPlan *spendingplan in self.fetchedResultsController.fetchedObjects) {
            NSLog(@"spending plan amount = %@", spendingplan.amount);
            NSString *temp = [spendingplan.amount stringByReplacingOccurrencesOfString:@"$" withString:@""];
            temp = [temp stringByReplacingOccurrencesOfString:@"," withString:@""];
            NSLog(@"temp = %@", temp);
            NSDecimalNumber *entry = [NSDecimalNumber decimalNumberWithString:temp];
            ftotal = [ftotal decimalNumberByAdding:entry];
        }
        
        //update the total cell with the sum of all entries
        NSString *formattedTotal= [self formatCurrencyValue:ftotal];
        cell.detailTextLabel.text = formattedTotal;

    } else {
        CellIdentifier = @"Spending Plan Entry Cell";
        cell= [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        SpendingPlan *spendingplan = [self.fetchedResultsController.fetchedObjects objectAtIndex:indexPath.row];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        //set date as the main text in the cell
        cell.textLabel.text = [formatter stringFromDate:spendingplan.date];
        //set spending plan amount as the detail to the date
        cell.detailTextLabel.text = spendingplan.amount;
        
        NSLog(@"date: %@", cell.textLabel.text);
        NSLog(@"amount: %@", cell.detailTextLabel.text);
        
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

//format amount with correct decimal places and $ sign
-(NSString*)formatCurrencyValue:(NSDecimalNumber *)value
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setCurrencySymbol:@"$"];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return [numberFormatter stringFromNumber:value];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    //set header for a new section that separtes the spending plan additions from the total
    if(section == 1) {
        return @"Spending Plan Additions";
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // If row is deleted, remove it from the list.
    if (indexPath.section == 1)
    {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            NSInteger row = [indexPath row];

            [self.document.managedObjectContext deleteObject:[self.fetchedResultsController.fetchedObjects objectAtIndex:row]];
            
            [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                if (success){
                    [self doFetch];
                    
                    [tableView reloadData];
                } else {
                    NSLog(@"couldn't save document at %@", self.document.fileURL);
                }
            }];
        }
    }
}


@end
