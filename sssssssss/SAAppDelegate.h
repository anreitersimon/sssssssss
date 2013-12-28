//
//  SAAppDelegate.h
//  sssssssss
//
//  Created by Simon Anreiter on 01.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KeychainItemWrapper;
@class SASideMenuViewController;

@interface SAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, retain) UIViewController *contentViewController;

@property (nonatomic, strong) SASideMenuViewController *menuViewController;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (KeychainItemWrapper *)keychain;
- (void)showSideMenu:(NSString *)viewControllerIdentifier;
- (void)hideSideMenu;

@end
