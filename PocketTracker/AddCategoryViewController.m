//
//  AddCategoryViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 6/21/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddCategoryViewController.h"

@interface AddCategoryViewController ()

@end

@implementation AddCategoryViewController
@synthesize cancelButton;
@synthesize doneButton;
@synthesize tView;
@synthesize categoryInput;
@synthesize document;

-(void)removeKeyboard
{
    [self.categoryInput resignFirstResponder];
}

-(void)setupView
{
    self.tView.dataSource = self;
    self.tView.delegate = self;
    
    self.categoryInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 12, 320, 30)];
    self.categoryInput.placeholder = @"Enter Category";
    self.categoryInput.textAlignment = UITextAlignmentCenter;
    self.categoryInput.adjustsFontSizeToFitWidth = YES;
    [self.categoryInput setEnabled:YES];
    
    UIToolbar *keyboardTBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    keyboardTBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *doneKeyboard = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(removeKeyboard)];
    NSMutableArray *keyboardTbarItems = [[NSMutableArray alloc] init];
    [keyboardTbarItems addObject:doneKeyboard];
    [keyboardTBar setItems:keyboardTbarItems];
    self.categoryInput.inputAccessoryView = keyboardTBar;
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
    [self setupView];
}

- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [self setDoneButton:nil];
    [self setCategoryInput:nil];
    [self setTView:nil];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Add Category Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0 && indexPath.section == 0) {
        [cell addSubview:self.categoryInput];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.categoryInput becomeFirstResponder];
    }
}
- (IBAction)doCancelButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doDoneButton:(id)sender {
    
    if (![self.categoryInput.text isEqualToString:@""]) {
        CustomCategories *category = [NSEntityDescription insertNewObjectForEntityForName:@"CustomCategories" inManagedObjectContext:self.document.managedObjectContext];
        
        category.category = self.categoryInput.text;
        
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success){
                [self dismissModalViewControllerAnimated:YES];
            } else {
                NSLog(@"couldn't save document at %@", self.document.fileURL);
            }
        }];
    }
}
@end
