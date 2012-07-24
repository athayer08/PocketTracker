//
//  SummaryViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SummaryViewController.h"

@interface SummaryViewController ()

@end

@implementation SummaryViewController

@synthesize document;
@synthesize fetchedExpenses;
@synthesize graph;
@synthesize isLoading;
@synthesize progressView;
@synthesize fetchedBudget;
@synthesize expenseLabel;
@synthesize budgetLabel;
@synthesize categoryCount;
@synthesize fetchedCategories;
@synthesize datesLabel;
@synthesize legendLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)doFetch
{
    NSError *error;
    [self.fetchedExpenses performFetch:&error];
}

-(void) setupFetchedResultsController:(NSString *) category
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Expenses"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedExpenses = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    self.fetchedExpenses.fetchRequest.predicate = [NSPredicate predicateWithFormat:@"(category = %@)", category];
    
    [self doFetch];
}

-(void)setupFetchedBudgetController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"SpendingPlan"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
    
    self.fetchedBudget = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

-(void)setupFetchedCategoriesController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CustomCategories"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES]];
    
    self.fetchedCategories = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
}

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

-(void)setupProgressView
{
    NSError *error;
    [self.fetchedBudget performFetch:&error];
    
    float totalBudget = [self calculateTotalBudget];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float totalExpenses = [defaults floatForKey:@"totalExpenses"];
    NSLog(@"totalExpenses: %f", totalExpenses);
    NSLog(@"totalBudget: %f", totalBudget);
    
    float progress = totalExpenses / totalBudget;
    NSLog(@"progress: %f", progress);
    
    if (progress > 1) {
        progress = 1;
    }
    
    [self.progressView setProgress:progress animated:YES];
    
}

-(void)setupSummaryLabels
{

    NSMutableString *labelText;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [formatter setCurrencySymbol:@"$"];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];

    float totalBudget = [self calculateTotalBudget];
    labelText = [[NSMutableString alloc] init];
    [labelText appendString:@"Spending Plan: "];
    [labelText appendString:[formatter stringFromNumber:[NSNumber numberWithFloat:totalBudget]]];

    self.budgetLabel.text = labelText;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    float totalExpenses = [defaults floatForKey:@"totalExpenses"];
    labelText = [[NSMutableString alloc] init];
    [labelText appendString:@"Total Expenses: "];
    [labelText appendString:[formatter stringFromNumber:[NSNumber numberWithFloat:totalExpenses]]];
    
    self.expenseLabel.text = labelText;
    
    NSDate *startDate = [defaults objectForKey:@"startDate"];
    NSDate *endDate = [defaults objectForKey:@"endDate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/YYYY"];
    labelText = [[NSMutableString alloc] init];
    [labelText appendString:[dateFormatter stringFromDate:startDate]];
    [labelText appendString:@" - "];
    [labelText appendString:[dateFormatter stringFromDate:endDate]];
    self.datesLabel.text = labelText;
    self.datesLabel.font = [UIFont boldSystemFontOfSize:20];
    
    labelText = [[NSMutableString alloc] init];
    if ([self.fetchedExpenses.fetchedObjects count] == 0 || !self.fetchedExpenses.fetchedObjects) {
        [labelText appendString:@"No Expenses"];
    } else {        
        [labelText appendString:@""];
    }
    self.legendLabel.text = labelText;
    
}

-(void)setupPieChart
{
    self.categoryCount = [[NSMutableArray alloc] init];
    
    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.frame = CGRectMake(12.5, 125, (screenRect.size.width - 25), self.progressView.frame.size.height);
    self.progressView.progressTintColor = [UIColor redColor];
    self.progressView.trackTintColor = [UIColor greenColor];
    [self setupFetchedBudgetController];
    [self setupProgressView];
    
    self.expenseLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.5, 140, (screenRect.size.width - 25), 44)];
    self.budgetLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.5, 75, (screenRect.size.width - 25), 44)];
    self.legendLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 280, (screenRect.size.width - 25), 44)];
    
    self.datesLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenRect.size.width / 4) - 30, 20, (screenRect.size.width), 44)];
    
    [self setupSummaryLabels];
        
    CPTGraphHostingView *hostingView = [[CPTGraphHostingView alloc] initWithFrame:screenRect];
    graph = [[CPTXYGraph alloc] init];
    graph.axisSet = nil;
    
    hostingView.hostedGraph = self.graph;
    
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self;
    pieChart.pieRadius = 60.0;
    pieChart.identifier = @"Expense Pie Chart";
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionCounterClockwise;
    
    [self.graph addPlot:pieChart];
    
    CPTLegend *pieLegend = [CPTLegend legendWithGraph:self.graph];
    pieLegend.numberOfColumns = 1;
    pieLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    pieLegend.borderLineStyle = [CPTLineStyle lineStyle];
    pieLegend.rowMargin = 0.1;
    pieLegend.cornerRadius = 5.0;
    
    self.graph.legend = pieLegend;
    
    self.graph.legendAnchor = CPTRectAnchorBottomRight;
    self.graph.legendDisplacement = CGPointMake(0.0, 75.0);
    
    self.graph.plotAreaFrame.paddingTop = 125.0f;
    self.graph.plotAreaFrame.paddingRight = 150.0f;
    
    [self.view addSubview:datesLabel];
    [self.view addSubview:self.budgetLabel];
    [self.view addSubview:self.progressView];
    [self.view addSubview:self.expenseLabel];
    [self.view addSubview:self.legendLabel];
    [self.view addSubview:hostingView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.graph reloadData];
    
    if (self.progressView) {
        [self setupProgressView];
    }
    
    if (self.budgetLabel && self.expenseLabel) {
        [self setupSummaryLabels];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UITabBarController *tabController = [storyboard instantiateViewControllerWithIdentifier:@"Tab Controller"];
    [[[tabController.tabBar items] objectAtIndex:0] setEnabled:NO];
    [[[tabController.tabBar items] objectAtIndex:1] setEnabled:NO];
    [[[tabController.tabBar items] objectAtIndex:2] setEnabled:NO];
    [[[tabController.tabBar items] objectAtIndex:3] setEnabled:NO];
    [[[tabController.tabBar items] objectAtIndex:4] setEnabled:NO];
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
    
    NSLog(@"Summary Load");
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self setupPieChart];
                [[[tabController.tabBar items] objectAtIndex:0] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:1] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:2] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:3] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:4] setEnabled:YES];
                [loadingView removeFromSuperview];
                [loading stopAnimating];
            } else {
                NSLog(@"count open document at %@", url);
            }
        }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                [self setupPieChart];
                [[[tabController.tabBar items] objectAtIndex:0] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:1] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:2] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:3] setEnabled:YES];
                [[[tabController.tabBar items] objectAtIndex:4] setEnabled:YES];
                [loadingView removeFromSuperview];
                [loading stopAnimating];
            } else {
                NSLog(@"couldn't create document at %@", url);
            }
        }];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([self.fetchedExpenses.fetchedObjects count] == 0 || !self.fetchedExpenses.fetchedObjects) {
        return 1;
    } else {
        [self setupFetchedCategoriesController];
        NSError *error;
        [self.fetchedCategories performFetch:&error];
        
        return (9 + [self.fetchedCategories.fetchedObjects count]);
    }
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSString *category;
    if (index == 0) {
        category = @"Grocery, Dining";
    } else if (index == 1) {
        category = @"Auto: Gas, Maintenance";
    } else if (index == 2) {
        category = @"Medical";
    } else if (index == 3) {
        category = @"Children, Education";
    } else if (index == 4) {
        category = @"Clothing";
    } else if (index == 5) {
        category = @"Personal Items";
    } else if (index == 6) {
        category = @"Fun, Entertainment";
    } else if (index == 7) {
        category = @"Savings";
    } else if (index == 8) {
        category = @"Miscellaneous";
    } 
    
    NSInteger categoryIndex = 9;
    if ([self.fetchedCategories.fetchedObjects count] > 0) {
        for (NSInteger i = 0; i < [self.fetchedCategories.fetchedObjects count]; i++) {
            if (index == (categoryIndex + i)) {
                CustomCategories *customCategory = [self.fetchedCategories.fetchedObjects objectAtIndex:i];
                NSLog(@"fetched category: %@", customCategory.category);
                category = customCategory.category;
            }
        }
    }
    
    NSLog(@"category: %@", category);
    
    [self setupFetchedResultsController:category];
    
    float expenseAmount = 0.0;
    
    if ([self.fetchedExpenses.fetchedObjects count] == 0 || !self.fetchedExpenses.fetchedObjects) {
        expenseAmount = 1.0;
    } else {
        for (Expenses *expense in self.fetchedExpenses.fetchedObjects)
        {
            NSString *formatted = [expense.amount stringByReplacingOccurrencesOfString:@"$" withString:@""];
            formatted = [formatted stringByReplacingOccurrencesOfString:@"," withString:@""];
            
            expenseAmount = expenseAmount + [formatted floatValue];
        }        
    }
    
    NSNumber *amount = [NSNumber numberWithFloat:expenseAmount];

    return amount;
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    if ([self.fetchedExpenses.fetchedObjects count] == 0 || !self.fetchedExpenses.fetchedObjects) {
        return [CPTFill fillWithColor:[CPTColor greenColor]];
    } else {
        return [CPTFill fillWithColor:[CPTPieChart defaultPieSliceColorForIndex:index]];
    }    
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    NSString *category;
    if (index == 0) {
        category = @"Grocery, Dining";
    } else if (index == 1) {
        category = @"Auto: Gas, Maintenance";
    } else if (index == 2) {
        category = @"Medical";
    } else if (index == 3) {
        category = @"Children, Education";
    } else if (index == 4) {
        category = @"Clothing";
    } else if (index == 5) {
        category = @"Personal Items";
    } else if (index == 6) {
        category = @"Fun, Entertainment";
    } else if (index == 7) {
        category = @"Savings";
    } else if (index == 8) {
        category = @"Miscellaneous";
    }
    
    NSInteger categoryIndex = 9;
    if ([self.fetchedCategories.fetchedObjects count] > 0) {
        for (NSInteger i = 0; i < [self.fetchedCategories.fetchedObjects count]; i++) {
            if (index == (categoryIndex + i)) {
                CustomCategories *customCategory = [self.fetchedCategories.fetchedObjects objectAtIndex:i];
                NSLog(@"fetched category: %@", customCategory.category);
                category = customCategory.category;
            }
        }
    }
    
    [self setupFetchedResultsController:category];
    
    if ([self.fetchedExpenses.fetchedObjects count] == 0) {
        return nil;
    } else {
        return category;
    }
}

@end
