//
//  SASearchProfileViewController.m
//  sssssssss
//
//  Created by Simon Anreiter on 13.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SASearchProfileViewController.h"
#import "CDSearchProfile.h"
#import "SAAppDelegate.h"
#import "SASearchProfileDetailViewController.h"
#import "SAViewController.h"

@interface SASearchProfileViewController ()<SASearchProfileDetailViewControllerDelegate>
@property(nonatomic, strong) NSString *baseURL;

@end

@implementation SASearchProfileViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    
    self.tableView.allowsSelectionDuringEditing = YES;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(showNewSearchProfileWindow:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSideMenu)];
    self.navigationItem.leftBarButtonItem = sideMenuButton;

}

-(void)showSideMenu
{
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];

    [appDelegate showSideMenu:@"Suche"];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showNewSearchProfileWindow:(id)sender
{
    [self performSegueWithIdentifier:@"addSearchProfile" sender:nil];
}

- (void)showEditSearchProfileWindowForIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"editSearchProfile" sender:nil];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.editing==NO)
    {
        [self performSegueWithIdentifier:@"showSearch" sender:nil];
    }
    if(tableView.editing==YES)
    {
        [self showEditSearchProfileWindowForIndexPath:indexPath];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSearch"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CDSearchProfile *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        _baseURL = [object createBaseURL];
        [[segue destinationViewController] setBaseURL:_baseURL];
    }

    else if([[segue identifier] isEqualToString:@"addSearchProfile"]){
        UINavigationController *nav = [segue destinationViewController];
        
        SASearchProfileDetailViewController *vc = (SASearchProfileDetailViewController *)[nav topViewController];
        vc.title = @"New";
        vc.delegate=self;
        vc.editingMode=NO;
        
        NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
        
        CDSearchProfile *newSearchProfile = [[CDSearchProfile alloc] initWithEntity: entity insertIntoManagedObjectContext:nil];
        
        vc.searchProfile =newSearchProfile;
    }
    
    else if([[segue identifier] isEqualToString:@"editSearchProfile"]){
        UINavigationController *nav = [segue destinationViewController];
        
        SASearchProfileDetailViewController *vc = (SASearchProfileDetailViewController *)[nav topViewController];
        vc.title = @"Edit";
        vc.delegate=self;
        vc.editingMode=YES;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CDSearchProfile *newSearchProfile = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        vc.searchProfile =newSearchProfile;
    }
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SearchProfile" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"SearchProfiles"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
    
}
/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
 {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */



- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    CDSearchProfile *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableDictionary *dictionary;
    
    [dictionary setObject:object.max_cost forKey:@"max_cost"];
    [dictionary setObject:object.min_rooms forKey:@"min_rooms"];
    [dictionary setObject:object.min_size forKey:@"min_size"];
    [dictionary setObject:object.location forKey:@"location"];
    [dictionary setObject:object.type forKey:@"realty_type"];
    
    UITextField *typeField = (UITextField*)[self.view viewWithTag:1];
        typeField.text = object.type;
    UITextField *locationField = (UITextField*)[self.view viewWithTag:2];
    locationField.text = object.location;
    
    NSString *maxCost = (object.max_cost==nil ? nil : [NSString stringWithFormat:@"Preis: %@",object.max_cost ]) ;
    NSString *minRooms = (object.max_cost==nil ? nil : [NSString stringWithFormat:@"Zimmer: %@",object.min_rooms ]) ;
    
    
    UITextField *textField;
    textField = (UITextField*)[self.view viewWithTag:3];
        textField.text = maxCost;
    
    textField = (UITextField*)[self.view viewWithTag:4];
        textField.text = minRooms;
    
}

-(void)saveNewSearchProfile:(CDSearchProfile *)searchProfile
{
    [_managedObjectContext insertObject:searchProfile];
    
    NSError *error;
    [_managedObjectContext save:&error];
    [self.tableView setEditing:NO animated:YES];
    [super setEditing:NO animated:YES];
}

-(void)deleteSearchProfile:(CDSearchProfile *)searchProfile{
    [_managedObjectContext deleteObject:searchProfile];
    
    NSError *error;
    [_managedObjectContext save:&error];
    [super setEditing:NO animated:YES];
}

-(void)updateSearchProfile{
    NSError *error;
    [_managedObjectContext save:&error];
    [super setEditing:NO animated:YES];
    //[self.tableView reloadData];
}

@end