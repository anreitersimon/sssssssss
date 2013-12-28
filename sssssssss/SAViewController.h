//
//  SAViewController.h
//  sssssssss
//
//  Created by Simon Anreiter on 06.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class SAInseratLoader;
@class SAPictureLoader;

@interface SAViewController : UITableViewController 

@property(nonatomic, strong) NSMutableArray *entries;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic, strong) NSString *baseURL;


-(void)toggleInseratRecordatIndexPath:(NSIndexPath *)indexPath;
-(void)setBaseURL:(NSString *)baseURL;

@end
