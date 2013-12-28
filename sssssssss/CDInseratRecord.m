#import "CDInseratRecord.h"
#import "InseratRecord.h"
#import "Image.h"


@implementation CDInseratRecord

@dynamic dataDictionary;
@dynamic identifier;
@dynamic favorited;
@dynamic images;

- (id)initWithInseratRecord:(InseratRecord*)inseratRecord Entity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context
{
    self = [super initWithEntity:entity insertIntoManagedObjectContext:context];
    if (self != nil) {
        self.dataDictionary = inseratRecord.dictionary;
        self.identifier = inseratRecord.identifier;
        if(inseratRecord.imageLoadComplete){
            NSEntityDescription *imageEntity = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:context];
            
            [self addImages:[self imageSetFromInseratRecord:inseratRecord Entity: imageEntity insertIntoManagedObjectContext:context]];
        }
    }
    return self;
}

- (NSSet *)imageSetFromInseratRecord:(InseratRecord *)inseratRecord Entity:(NSEntityDescription*)entity insertIntoManagedObjectContext:(NSManagedObjectContext*)context{
    NSMutableSet *imageSet = [[NSMutableSet alloc] init];
    
    for(int i=0; i<inseratRecord.imageURLS.count;i++){
        [imageSet addObject:[[Image alloc] initWithInseratRecord:[inseratRecord.images objectAtIndex:i] URL:[inseratRecord.imageURLS objectAtIndex:i] Entity:entity insertIntoManagedObjectContext:context]];
    }
    return imageSet;
}

@end

