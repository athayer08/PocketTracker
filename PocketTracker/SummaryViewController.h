//
//  SummaryViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "Expenses.h"
#import "SpendingPlan.h"
#import "CustomCategories.h"

@interface SummaryViewController : UIViewController <CPTPieChartDataSource>

@property (nonatomic, strong) UIManagedDocument *document;
@property (nonatomic, strong) NSFetchedResultsController *fetchedExpenses;
@property (nonatomic, strong) NSFetchedResultsController *fetchedBudget;
@property (nonatomic, strong) NSFetchedResultsController *fetchedCategories;
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic) BOOL isLoading;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *budgetLabel;
@property (nonatomic, strong) UILabel *expenseLabel;
@property (nonatomic, strong) NSMutableArray *categoryCount;

@end
