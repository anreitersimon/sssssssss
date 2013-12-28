//
//  CDInseratRecord.h
//  sssssssss
//
//  Created by Simon Anreiter on 13.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Image;
@class InseratRecord;

@interface CDInseratRecord : NSManagedObject

@property (nonatomic, retain) id dataDictionary;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * favorited;
@property (nonatomic, retain) NSSet *images;


- (id)initWithInseratRecord:(InseratRecord*)inseratRecord Entity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context;
@end


@interface CDInseratRecord (CoreDataGeneratedAccessors)

- (void)addImagesObject:(Image *)value;
- (void)removeImagesObject:(Image *)value;
- (void)addImages:(NSSet *)values;
- (void)removeImages:(NSSet *)values;

@end
