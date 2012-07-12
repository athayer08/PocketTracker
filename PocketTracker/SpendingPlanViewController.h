//
//  SpendingPlanViewController.h
//  PocketTracker
//
//  Created by Kathleen Gannon on 5/12/12.
//  Copyright (c) 2012 Credibility. All rights reserved.
//
// Header file for the Spending Plan view of the application

#import <UIKit/UIKit.h>
#import "SpendingPlan.h"

@interface SpendingPlanViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

//Property representing the Table View
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//Property representing the object that queries the file system for Spending Plan entries
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

//Property representing the object that accesses the file system
@property (strong, nonatomic) UIManagedDocument *document;

//Flag representing whether the program is in the viewDidLoad method.
@property (nonatomic) BOOL isLoading;

@end
