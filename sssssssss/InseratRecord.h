//
//  InseratRecord.h
//  sssssssss
//
//  Created by Simon Anreiter on 06.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *kDetailFormat = @"longFormat";
static NSString *kListFormat = @"shortFormat";

static NSString *kAdditionKey = @"additionKey";
static NSString *kSecondAdditionKey = @"secondAdditionKey";

static NSString *kBoldTextAttribute = @"boldText";
static NSString *kGreyTextAttribute = @"greyText";

@interface InseratRecord : NSObject

@property(nonatomic, strong) NSNumber *identifier;
@property(nonatomic, strong) NSDictionary *dictionary;
@property BOOL favorite;
@property BOOL imageLoadComplete;
@property(nonatomic, strong) NSArray *imageURLS;
@property(nonatomic, strong) NSMutableArray *images;
@property NSUInteger activePage;
@property NSString *currency;


-(id)initWithJsonDictionary:(NSDictionary*)dictionary;
-(void)dropImages;

-(NSDate *)createdAtDate;
-(NSDate *)lastUpdatedDate;
-(BOOL)updatedDateEqualsCreatedDate;
-(NSString *)getRelativeDateFrom:(NSDate *)now To:(NSDate *)then;
-(NSString *)getCostFormatted:(NSString *)format;
-(NSArray *)additionalCostsFormatted;
-(NSAttributedString *)getSummaryFormattedForList;
-(NSAttributedString *)getSummaryFormattedForDetail;
-(NSString *)getAdressFormatted:(NSString *)format;
@end
