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
    
    UILabel *datesLabel = [[UILabel alloc] initWithFrame:CGRectMake((screenRect.size.width / 4) - 30, 20, (screenRect.size.width), 44)];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *startDate = [defaults objectForKey:@"startDate"];
    NSTimeInterval interval = 30 * 24 * 60 * 60;
    NSDate *endDate = [startDate dateByAddingTimeInterval:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/YYYY"];
    NSMutableString *labelText = [[NSMutableString alloc] init];
    [labelText appendString:[formatter stringFromDate:startDate]];
    [labelText appendString:@" - "];
    [labelText appendString:[formatter stringFromDate:endDate]];
    datesLabel.text = labelText;
    datesLabel.font = [UIFont boldSystemFontOfSize:20];
    
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
    NSLog(@"Summary Load");
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self setupPieChart];
            } else {
                NSLog(@"count open document at %@", url);
            }
        }];
    } else {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success)
            {
                [self setupPieChart];
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
    [self setupFetchedCategoriesController];
    NSError *error;
    [self.fetchedCategories performFetch:&error];
    
    return (9 + [self.fetchedCategories.fetchedObjects count]);
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
                NSLog(@"fetched category: %@", [self.fetchedCategories.fetchedObjects objectAtIndex:i]);
                category = [self.fetchedCategories.fetchedObjects objectAtIndex:i];
            }
        }
    }
    
    NSLog(@"category: %@", category);
    
    [self setupFetchedResultsController:category];
    
    float expenseAmount = 0.0;
    for (Expenses *expense in self.fetchedExpenses.fetchedObjects)
    {
        NSString *formatted = [expense.amount stringByReplacingOccurrencesOfString:@"$" withString:@""];
        formatted = [formatted stringByReplacingOccurrencesOfString:@"," withString:@""];
        
        expenseAmount = expenseAmount + [formatted floatValue];
    }
    
    NSNumber *amount = [NSNumber numberWithFloat:expenseAmount];
    
    return amount;
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
    
    [self setupFetchedResultsController:category];
    
    if ([self.fetchedExpenses.fetchedObjects count] == 0) {
        return nil;
    } else {
        return category;
    }
}

@end
