//
//  SAMasterViewController.m
//  sssssssss
//
//  Created by Simon Anreiter on 01.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SAMasterViewController.h"

#import "SADetailViewController.h"
#import "CDInseratRecord.h"
#import "SAAppDelegate.h"
#import "Image.h"
#import "CDInseratHandler.h"
#import "KeychainItemWrapper.h"
#import "UserActionHandler.h"
#import "InseratRecord.h"


@interface SAMasterViewController ()
@property(nonatomic, strong) CDInseratHandler *inseratHandler;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation SAMasterViewController

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
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    [refresh addTarget:self
                action:@selector(reloadResults)
      forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *sideMenuButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSideMenu)];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.navigationItem.leftBarButtonItem = sideMenuButton;
    
    self.refreshControl = refresh;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated
{
    [self loadResults];
}

-(void)showSideMenu
{
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    [appDelegate showSideMenu:@"Merkliste"];
}

-(void)showLogoutScreen
{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
                                                      message:@"Ausloggen?"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Logout", nil];
    [message show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1){
        NSLog(@"Ausgeloggt");
        SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        KeychainItemWrapper *keyChain = [appDelegate keychain];
        
        [keyChain resetKeychainItem];
    }
}

- (void)showErrorPage:(NSString *)error
{
    CGRect frame = self.parentViewController.view.bounds;

    UILabel *errorLabel = [[UILabel alloc] initWithFrame:frame];
    errorLabel.backgroundColor = [UIColor whiteColor];
    errorLabel.textAlignment = NSTextAlignmentCenter;
    errorLabel.text = @"Nicht eingeloggt";
    [self.view addSubview:errorLabel];
}

-(void)loadResults
{
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    KeychainItemWrapper *keyChain = [appDelegate keychain];
    
    if(![[keyChain getAuthenticationToken] isEqual:@""])
    {
        UserActionHandler *userActionHandler = [[UserActionHandler alloc] init];
        [userActionHandler setCompletionHandler:^(NSData *response){
            NSError *error;
            
            //NSString *responsestring = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            //NSLog(@"%@",responsestring);
            
            NSMutableArray *entries = [[NSMutableArray alloc] init];
            
            NSArray *objects = [NSJSONSerialization JSONObjectWithData:response
                                                               options:kNilOptions
                                                                 error:&error];
            for(NSDictionary *dictionary in objects){
                [entries addObject:[[InseratRecord alloc] initWithJsonDictionary:dictionary]];
            }
            
            SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = [appDelegate managedObjectContext];
            NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            [backgroundContext setParentContext:context];
            
            
            if(_inseratHandler == nil)
                _inseratHandler = [[CDInseratHandler alloc] initWithManagedObjectContext:backgroundContext Entries:entries];
            
            [_inseratHandler syncWatchList:entries];
            
        }];
        [userActionHandler getUserWatchList];
    }
    else
    {
        [self.refreshControl endRefreshing];
        [self showErrorPage:nil];
    }
}

- (void)reloadResults
{
    [self.refreshControl beginRefreshing];
    [self loadResults];
    if(self.refreshControl.isRefreshing)
        [self.refreshControl endRefreshing];
}

- (void)deleteFromWatchlistItemWithIdentifier:(NSNumber *)identifier
{
    UserActionHandler *userActionHandler = [[UserActionHandler alloc] init];
    [userActionHandler setCompletionHandler:^(NSData *response){
        NSError *error;
        
        NSDictionary *status = [NSJSONSerialization JSONObjectWithData:response
                                                               options:kNilOptions
                                                                 error:&error];
        
        [self toggleCompletedWithStatus:status];
    }];
    
    [userActionHandler toggleUserWatchListItemWithIdentifier:identifier];
}

-(void)toggleCompletedWithStatus:(NSDictionary *)status
{
    if(![[status objectForKey:@"status"] isEqualToString:@"success"])
    {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:nil
                                                          message:@"Von Merkliste entfernen fehlgeschlagen?"
                                                         delegate:self
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
        [message show];
    }
    
    [self loadResults];
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
        CDInseratRecord *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self deleteFromWatchlistItemWithIdentifier:object.identifier];
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:object];
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetail" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        CDInseratRecord *object = (CDInseratRecord *)[[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        [[segue destinationViewController] setDetailItem:[self inseratRecordFromCDInseratRecord:object]];
    }
}

- (InseratRecord *)inseratRecordFromCDInseratRecord:(CDInseratRecord *)cdInseratRecord
{
    InseratRecord *inseratRecord = [[InseratRecord alloc] initWithJsonDictionary:cdInseratRecord.dataDictionary];
    
    inseratRecord.favorite = YES;
    inseratRecord.imageLoadComplete = YES;
    
    NSSet *imageSet = cdInseratRecord.images;
    NSArray *cdImages = [imageSet allObjects];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
   for(Image *cdImage in cdImages)
   {
       UIImage *image = [UIImage imageWithData:cdImage.imageData ];
       [images addObject:image];
   }
    inseratRecord.images = images;
    
    return inseratRecord;
}



#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InseratRecord" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"identifier" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
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
    CDInseratRecord *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    //cell.textLabel.text = [object.dataDictionary objectForKey:@"realty_type"];
    NSSet *imageSet = object.images;
    NSArray *images = [imageSet allObjects];
    Image *cdimage = [images objectAtIndex:0];
    UIImage *image = [UIImage imageWithData:cdimage.imageData ];
    
    NSDictionary *dictionary = object.dataDictionary;
    
    UILabel *typeLabel = (UILabel *)[cell viewWithTag:1];
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:2];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
    
    typeLabel.text = [dictionary objectForKey:@"realty_type"];
    imageView.image = image;
    
}

@end
