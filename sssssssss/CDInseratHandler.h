//
//  CDInseratHandler.h
//  sssssssss
//
//  Created by Simon Anreiter on 06.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class InseratRecord;
@class CDInseratRecord;



@protocol CDInseratHandlerDelegate <NSObject>
@required
- (void)favoritesChanged;
@end

@interface CDInseratHandler : NSObject
{
    // We don't know what kind of class is going to adopt us at
    //compile time, that's why this is an id
    //id<CDInseratHandlerDelegate> delegate;
    
}

@property (nonatomic, assign) id delegate;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSEntityDescription *entityDescription;
@property BOOL syncing;



- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext Entries:(NSArray *)entries;
- (void)filterFavorites;
- (NSDictionary *)identifiersForFavorites;
- (void)insertNewObject:(InseratRecord *)inseratRecord;
- (void)insertNewInserat:(InseratRecord *)inseratRecord;
- (void)deleteObject:(InseratRecord *)inseratRecord;
- (void)syncWatchList:(NSArray *)inseratRecords;

@end
