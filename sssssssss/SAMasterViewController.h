//
//  SAMasterViewController.h
//  sssssssss
//
//  Created by Simon Anreiter on 01.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface SAMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
