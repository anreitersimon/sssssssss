//
//  Image.m
//  sssssssss
//
//  Created by Simon Anreiter on 13.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "Image.h"
#import "InseratRecord.h"
#import "CDInseratRecord.h"


@implementation Image

@dynamic imageData;
@dynamic imageURL;
@dynamic inseratRecord;


- (id)initWithInseratRecord:(UIImage *)image URL:(NSString *)imageURL Entity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if(self!=nil){
        self.imageData = UIImagePNGRepresentation(image);
        self.imageURL = imageURL;
    }
        
    return self;
}



@end
