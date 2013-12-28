//
//  Image.h
//  sssssssss
//
//  Created by Simon Anreiter on 13.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CDInseratRecord;
@class InseratRecord;

@interface Image : NSManagedObject

@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) CDInseratRecord *inseratRecord;

- (id)initWithInseratRecord:(UIImage *)image URL:(NSString *)imageURL Entity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context;

- (NSSet *)imageSetFromInseratRecord:(InseratRecord *)inseratRecord Entity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context;

@end
