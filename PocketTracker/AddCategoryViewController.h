//
//  AddCategoryViewController.h
//  PocketTracker
//
//  Created by Andrew Thayer on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomCategories.h"

@interface AddCategoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITableView *tView;

@property (strong, nonatomic) UITextField *categoryInput;
@property (strong, nonatomic) UIManagedDocument *document;

- (IBAction)doCancelButton:(id)sender;
- (IBAction)doDoneButton:(id)sender;
@end
