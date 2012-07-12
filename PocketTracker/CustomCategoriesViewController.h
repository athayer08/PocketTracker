//
//  CustomCategoriesViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCategories.h"

@interface CustomCategoriesViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addCategoryButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editCategoriesButton;

@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSFetchedResultsController *resultsController;

- (IBAction)addCategory:(id)sender;
- (IBAction)editCategories:(id)sender;
@end
