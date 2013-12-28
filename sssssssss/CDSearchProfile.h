//
//  CDSearchProfile.h
//  sssssssss
//
//  Created by Simon Anreiter on 13.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CDSearchProfile : NSManagedObject

@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSNumber * max_cost;
@property (nonatomic, retain) NSNumber * min_size;
@property (nonatomic, retain) NSNumber * min_rooms;
@property (nonatomic, retain) NSDate * timeStamp;


- (id)initWithEntity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context;

- (NSString *)createBaseURL;
- (NSDictionary *)dictionaryWithParameters;
@end
