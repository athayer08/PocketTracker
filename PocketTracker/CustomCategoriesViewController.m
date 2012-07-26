//
//  CustomCategoriesViewController.m
//  PocketTracker
//
//  Created by Andrew Thayer on 6/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomCategoriesViewController.h"

@interface CustomCategoriesViewController ()

@end

@implementation CustomCategoriesViewController
@synthesize addCategoryButton;
@synthesize editCategoriesButton;
@synthesize document;
@synthesize resultsController;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)setupFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CustomCategories"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES]];
    
    self.resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.document.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    NSError *error;
    [self.resultsController performFetch:&error];
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.document) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Pocket Tracker Database"];
        self.document = [[UIManagedDocument alloc] initWithFileURL:url];
        if([[NSFileManager defaultManager] fileExistsAtPath:[self.document.fileURL path]])
        {
            [self.document openWithCompletionHandler:^(BOOL success) {
                if (success) {
                    [self setupFetchedResultsController];
                } else {
                    NSLog(@"couldn't open document at %@", url);
                }
            }];
        } else {
            [self.document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
                if (success) {
                    [self setupFetchedResultsController];
                } else {
                    NSLog(@"couldn't create document at %@", url);
                }
            }];
        }
    } else {
        NSError *error;
        [self.resultsController performFetch:&error];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setAddCategoryButton:nil];
    [self setEditCategoriesButton:nil];
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
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.resultsController) {
        return [self.resultsController.fetchedObjects count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Custom Category Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CustomCategories *category = [self.resultsController.fetchedObjects objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category.category;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        CustomCategories *category = [self.resultsController.fetchedObjects objectAtIndex:indexPath.row];
        [self.document.managedObjectContext deleteObject:category];
        
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
            if (success){
                NSError *error;
                [self.resultsController performFetch:&error];
                [tableView reloadData];
            } else {
                NSLog(@"couldn't save document at %@", self.document.fileURL);
            }
        }];
    }
}

- (IBAction)addCategory:(id)sender {
    if ([resultsController.fetchedObjects count] < 10) {
        [self performSegueWithIdentifier:@"Add Category" sender:self];
    } else {
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"CredAbility: Pocket Tracker" message:@"A maximum of 10 custom categories are allowed." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alerView show];
    }
}

- (IBAction)editCategories:(id)sender {
}
@end
