//
//  SAAppDelegate.h
//  sssssssss
//
//  Created by Simon Anreiter on 01.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
