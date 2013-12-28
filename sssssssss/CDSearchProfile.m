//
//  CDSearchProfile.m
//  sssssssss
//
//  Created by Simon Anreiter on 13.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "CDSearchProfile.h"


@implementation CDSearchProfile

@dynamic location;
@dynamic type;
@dynamic max_cost;
@dynamic min_size;
@dynamic min_rooms;
@dynamic timeStamp;


- (id)initWithEntity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    return self;
}

- (NSString *)createBaseURL
{
    
    NSDictionary *dictionary = [self dictionaryWithParameters];
    
    NSMutableString *baseURL = [[NSMutableString alloc] initWithString:@"http://www.jimmbo.net/api/search?"];
    
    NSObject *param = [dictionary objectForKey:@"location"];
    if(param!=nil)
        [baseURL appendString:[NSString stringWithFormat:@"location=%@&",param]];
    
    param = [dictionary objectForKey:@"rooms_min"];
    if(param!=nil)
        [baseURL appendString:[NSString stringWithFormat:@"rooms_min=%@&",param]];
    
    param = [dictionary objectForKey:@"size_min"];
    if(param!=nil)
        [baseURL appendString:[NSString stringWithFormat:@"size_min=%@&",param]];
    
    param = [dictionary objectForKey:@"costs_max"];
    if(param!=nil)
        [baseURL appendString:[NSString stringWithFormat:@"costs_max=%@&",param]];
    
    param = [dictionary objectForKey:@"realty_type"];
    if(param!=nil)
        [baseURL appendString:[NSString stringWithFormat:@"realty_type=%@&",param]];
    [baseURL appendString:@"order=date-desc"];
    NSLog(@"%@",baseURL);
    
    return baseURL;
}

- (NSDictionary *)dictionaryWithParameters
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    if(self.max_cost)
        [dictionary setObject:self.max_cost forKey:@"costs_max"];
    if(self.min_rooms)
        [dictionary setObject:self.min_rooms forKey:@"rooms_min"];
    if(self.min_size)
        [dictionary setObject:self.min_size forKey:@"size_min"];
    if(self.location)
        [dictionary setObject:self.location forKey:@"location"];
    if(self.type)
        [dictionary setObject:self.type forKey:@"realty_type"];
    
    return dictionary;
}


@end
