//
//  CDInseratHandler.m
//  sssssssss
//
//  Created by Simon Anreiter on 06.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "CDInseratHandler.h"
#import "CDInseratRecord.h"
#import "InseratRecord.h"
#import "SAAppDelegate.h"
#import "SAPictureLoader.h"



@interface CDInseratHandler ()<SAPictureLoaderDelegate>
@property (strong, nonatomic) NSMutableArray *itemsInFavorites;
@property (strong, nonatomic) NSMutableArray *entries;
@property (weak, nonatomic) SAAppDelegate *appDelegate;

@end

@implementation CDInseratHandler

@synthesize delegate;

- (id)initWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext Entries:(NSMutableArray *)entries
{
    self = [super init];
    
    if(self!=nil){
        _fetchedResultsController = [self fetchedResultsController];
        _managedObjectContext = managedObjectContext;
        _itemsInFavorites = [[NSMutableArray alloc] init];
        _appDelegate = [[UIApplication sharedApplication] delegate];
        _entries = entries;
        
        //[[NSNotificationCenter defaultCenter] addObserver:self
        //                                       selector:@selector(filterFavorites)
        //                                         name:NSManagedObjectContextDidSaveNotification
        //                                     object:_managedObjectContext];
    }
    return self;
}

- (void)insertNewInserat:(InseratRecord *)inseratRecord
{
    
    NSManagedObjectContext *context = _managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InseratRecord" inManagedObjectContext:context];
    
    CDInseratRecord *cdInseratRecord = [[CDInseratRecord alloc] initWithInseratRecord:inseratRecord Entity:entity insertIntoManagedObjectContext:context];
    NSError *error;
    
    [context save:&error];
}

- (NSDictionary *)identifiersForFavorites
{
    NSManagedObjectContext *context = _managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"InseratRecord" inManagedObjectContext:context];
    
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] init];
    
    if(array!=nil)
    {
        for(CDInseratRecord *record in array)
        {
            [identifiers setObject:@"true" forKey:record.identifier];
        }
    }
    return identifiers;
}

- (void)deleteObject:(InseratRecord *)inseratRecord
{
    [NSFetchedResultsController deleteCacheWithName:@"Master"];
    NSManagedObjectContext *context = _managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"InseratRecord" inManagedObjectContext:context];
    
    if(![self inseratIsFavorite:inseratRecord]) return;
    
    inseratRecord.favorite = NO;
    [_itemsInFavorites removeObject:inseratRecord];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSNumber *identifier = inseratRecord.identifier;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"identifier = %@", identifier];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"identifier" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    
    [context deleteObject:[array objectAtIndex:0]];
    
    error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
}

-(void)filterFavorites
{
    if(_itemsInFavorites != nil)
        for(InseratRecord *inseratRecord in _itemsInFavorites)
            inseratRecord.favorite = NO;
    
    _itemsInFavorites = [[NSMutableArray alloc] init];
    
    for(InseratRecord *inseratRecord in _entries)
    {
        if([self inseratIsFavorite:inseratRecord]){
            inseratRecord.favorite = YES;
           [_itemsInFavorites addObject:inseratRecord];
        }
    }
    [self.delegate favoritesChanged];
}

-(BOOL)inseratIsFavorite:(InseratRecord *)inseratRecord
{
    NSManagedObjectContext *context = _managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"InseratRecord" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    // Set example predicate and sort orderings...
    NSNumber *identifier = inseratRecord.identifier;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"identifier = %@", identifier];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"identifier" ascending:YES];
    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array == nil)
    {
        // Deal with error...
    }
    if(array.count > 0)
        return YES;
    
    return NO;
}


-(void)syncWatchList:(NSArray *)inseratRecords
{
    if(_syncing)
        return;
    
    _syncing = YES;
    NSMutableArray *inseratRecordIDs = [[NSMutableArray alloc] init];
    NSMutableArray *itemsToSave = [[NSMutableArray alloc] init];
    
    for(InseratRecord *inseratRecord in inseratRecords)
    {
        [inseratRecordIDs addObject:inseratRecord.identifier];
        BOOL inList = [self inseratIsFavorite:inseratRecord];
        if(!inList){
           [itemsToSave addObject:inseratRecord];
            //[self insertNewObjectInBackground:inseratRecord];
        }
    }
    [self removeExpiredEntries:inseratRecordIDs];

    [self downloadPicturesAndSaveInseratRecords:itemsToSave];
    
}


-(void)downloadPicturesAndSaveInseratRecords:(NSMutableArray *)inseratRecords
{
    [self downloadPictureForInseratRecord:inseratRecords];
}

-(void)downloadPictureForInseratRecord:(NSMutableArray *)inseratRecords
{
    if(inseratRecords.count==0){
        NSError *error;
        
        [_managedObjectContext save:&error];
        _syncing = NO;
        return;
    }
    
    SAPictureLoader *pictureLoader = [[SAPictureLoader alloc] initWithInseratRecord: [inseratRecords objectAtIndex:0] atIndexPath:nil];
    
    [pictureLoader setCompletionHandler:^(InseratRecord *readyInserat){
        [self insertNewObjectInBackground:readyInserat];
        [inseratRecords removeObjectAtIndex:0];
        [self downloadPictureForInseratRecord:inseratRecords];
    }];
    
    [pictureLoader startImagesDownload];
}


-(void)insertNewObjectInBackground:(InseratRecord *)inseratRecord
{
    NSManagedObjectContext *context = _managedObjectContext;

    NSEntityDescription *entity = [NSEntityDescription entityForName:@"InseratRecord" inManagedObjectContext:context];
    
    CDInseratRecord *cdInseratRecord = [[CDInseratRecord alloc] initWithInseratRecord:inseratRecord Entity:entity insertIntoManagedObjectContext:context];

}

-(void)removeExpiredEntries:(NSArray *)inseratRecordIDs
{
    NSManagedObjectContext *context = _managedObjectContext;
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"InseratRecord" inManagedObjectContext:context];

    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (identifier IN %@)", inseratRecordIDs];
    [request setPredicate:predicate];

    [request setSortDescriptors:nil];
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    
    if(array!=nil)
    {
        for(CDInseratRecord *record in array)
            [context deleteObject:record];
    }
  
}




@end