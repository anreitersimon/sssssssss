//
//  SASearchProfileViewController.h
//  sssssssss
//
//  Created by Simon Anreiter on 13.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SASearchProfileViewController : UITableViewController <NSFetchedResultsControllerDelegate >

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;



@end
