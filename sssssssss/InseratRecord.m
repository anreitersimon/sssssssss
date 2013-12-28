//
//  InseratRecord.m
//  sssssssss
//
//  Created by Simon Anreiter on 06.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "InseratRecord.h"
static NSArray *typeMieten;
static NSArray *typeKaufen;
static NSNumberFormatter *numberFormatter;



@implementation InseratRecord


-(id)initWithJsonDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    
    _dictionary = dictionary;
    _identifier = [dictionary objectForKey:@"id"];
    _imageURLS = [dictionary objectForKey:@"picture_paths"];
    _favorite = NO;
    _imageLoadComplete = NO;
    _images = nil;
    _activePage = 0;
    
    if([[self.dictionary objectForKey:@"currency"] isEqualToString:@"EUR"])
        _currency = @" €";
    if([[self.dictionary objectForKey:@"currency"] isEqualToString:@"USD"])
        _currency = @" $";
    
    //NSLog(@"New InseratRecord \n Created At: %@ \n City: %@\n PlaceholderPictures: %d",_createdAt, _city, _images.count);
    
    return self;
}

-(NSArray *)immoTypeMieten
{
    if ( typeMieten  == nil)
    {
        typeMieten =[NSArray arrayWithObjects:@"Mietwohnung",@"Miethaus", @"WG-Zimmer", @"Proberaum", @"Garage-Stellplatz",@"Bürofläche-Miete", nil];
    }
    return typeMieten;
}

-(NSArray *)immoTypeKaufen
{
    if ( typeKaufen  == nil)
    {
        typeKaufen =[NSArray arrayWithObjects:@"Mietwohnung",@"Miethaus", @"WG-Zimmer", @"Proberaum", @"Garage-Stellplatz",@"Bürofläche-Miete", nil];
    }
    return typeKaufen;
}

-(NSNumberFormatter *)formatter{
    if(numberFormatter==nil){
        numberFormatter =[[NSNumberFormatter alloc] init];
        [numberFormatter setGroupingSize:3];
        [numberFormatter setGroupingSeparator:@"."];
        
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return numberFormatter;
}

-(void)dropImages
{
    _images = nil;
    _imageLoadComplete = NO;
}


-(NSDate *)createdAtDate
{
    NSString *created_at_string = [self.dictionary objectForKey:@"created_at"];
    NSRange range = NSMakeRange(0, 10);
    
    created_at_string = [created_at_string substringWithRange:range];

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];

    return [formatter dateFromString:created_at_string];
    
}

-(NSDate *)lastUpdatedDate
{
    NSString *updated_at_string = [self.dictionary objectForKey:@"updated_at"];
    NSRange range = NSMakeRange(0, 10);

    updated_at_string = [updated_at_string substringWithRange:range];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter dateFromString:updated_at_string];
    
}

-(BOOL)updatedDateEqualsCreatedDate
{
    NSString *created_at_string = [self.dictionary objectForKey:@"created_at"];
    NSString *updated_at_string = [self.dictionary objectForKey:@"updated_at"];
    NSRange range = NSMakeRange(0, 10);
    created_at_string = [created_at_string substringWithRange:range];
    updated_at_string = [updated_at_string substringWithRange:range];
    
    return [created_at_string isEqual:updated_at_string];
}

-(NSString *)getRelativeDateFrom:(NSDate *)now To:(NSDate *)then
{
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                                   fromDate:then
                                                     toDate:now
                                                    options:0];
        NSString *displayString;
        if(components.month==0 && components.year==0)
        {
            if(components.day<7){
                switch (components.day) {
                    case 0:
                        displayString = @"Heute";
                        break;
                    case 1:
                        displayString = @"Gestern";
                        break;
                    case 2:
                        displayString = @"Vorgestern";
                        break;
                    default:
                        displayString = [NSString stringWithFormat:@"Vor %lu Tagen", (unsigned long)components.day];
                        break;
                }
            }
            else
            {
                NSUInteger weeks = components.day / 7;
                displayString = [NSString stringWithFormat:@"Vor %lu Wochen", (unsigned long)weeks];
            }
        }
        else if(components.year==0)
        {
            displayString = [NSString stringWithFormat:@"Vor %lu Monaten", (unsigned long)components.month];
        }
        else
        {
            displayString = [NSString stringWithFormat:@"Vor %lu Jahren", (unsigned long)components.year];
        }

        
        return displayString;
}

-(NSString *)getCostFormatted:(NSString *)format
{
    BOOL mietenType = NO;
    NSString *realtyType = [self.dictionary objectForKey:@"realty_type"];
    
    for(NSString *type in [self immoTypeMieten]){
        if([realtyType isEqualToString:type]){
            mietenType = YES;
            break;
        }
    }
    
    NSNumber *costsNumber = [self.dictionary objectForKey:@"leasing_costs"];
    NSString *costsString = [[self formatter] stringFromNumber:costsNumber];
    
    costsString = [costsString stringByAppendingString:_currency];
    
    if([realtyType isEqualToString:@"WG-Zimmer"] && format == kDetailFormat)
    {
            costsString = [costsString stringByAppendingString:@" pro Zimmer"];
        return costsString;
    }
    
    NSNumber *leasingCostMax =  [self.dictionary objectForKey:@"leasing_costs_max"];
    if([realtyType isEqualToString:@"WG-Zimmer"] && format == kListFormat)
    {
        if((NSNull *)leasingCostMax!=[NSNull null])
        {
            NSString *leasingCostsMaxString = [[self formatter] stringFromNumber:costsNumber];
            costsString = [costsString stringByAppendingString:[NSString stringWithFormat:@" - %@%@",leasingCostsMaxString,_currency]];
        }
    }
    
    if(mietenType){
        costsString = [costsString stringByAppendingString:@" monatl."];
        if(format == kDetailFormat)
        {
            costsString = [costsString stringByAppendingString:@" Fixkosten"];
        }
    }
    else if(format == kDetailFormat)
    {
        costsString = [costsString stringByAppendingString:@" Kaufpreis"];
    }
    
    return costsString;
}

-(NSString *)getAdressFormatted:(NSString *)format
{

    NSString *postalCode = [self.dictionary objectForKey:@"postalcode"];
    NSString *ort = [self.dictionary objectForKey:@"city"];
    
    return [NSString stringWithFormat:@"%@ %@",postalCode, ort];
}

-(NSAttributedString *)getSummaryFormattedForList
{
    NSAttributedString *result;
    NSArray *strings;
    
    NSString *sizeString = [NSString stringWithFormat:@"%@",[self.dictionary objectForKey:@"size"]];
    sizeString = [sizeString stringByAppendingString:@" m²"];
    
    NSString *roomsString = [NSString stringWithFormat:@"%@",[self.dictionary objectForKey:@"rooms"]];
    NSString *price = [self getCostFormatted:kListFormat];
    
    
    roomsString = [roomsString stringByAppendingString:@" Z."];

    
    NSString *realtyType = [self.dictionary objectForKey:@"realty_type"];
    //Mietwohnung, Miethaus ,Büro(Miete), Eigentumswohnung, Eigentumshaus
    if([realtyType isEqualToString:@"Mietwohnung"] ||
       [realtyType isEqualToString:@"Miethaus"] ||
       [realtyType isEqualToString:@"Eigentumswohnung"] ||
       [realtyType isEqualToString:@"Eigentumshaus"]||
       [realtyType isEqualToString:@"Bürofläche (Miete)"]||
       [realtyType isEqualToString:@"Bürofläche (Ankauf)"])
    {
        strings = [NSArray arrayWithObjects:sizeString, roomsString, price, nil];
    }
    
    else if([realtyType isEqualToString:@"WG-Zimmer"])
    {
        NSString *apartmentShareExisting = [self.dictionary objectForKey:@"apartment_share_existing"];
        NSString *apartmentShareWanted = [self.dictionary objectForKey:@"apartment_share_wanted"];
        
        NSArray *existing = [apartmentShareExisting componentsSeparatedByString:@","];
        NSArray *wanted = [apartmentShareWanted componentsSeparatedByString:@","];
        
        NSString *sizeWG = [NSString stringWithFormat:@"%luer WG",(unsigned long)(existing.count+wanted.count) ];
        
        strings = [NSArray arrayWithObjects:sizeWG, sizeString, price, nil];
    }

    
    else if([realtyType isEqualToString:@"Proberaum"])
    {
        strings = [NSArray arrayWithObjects:@"Proberaum", sizeString, price, nil];
    }
    
    else if([realtyType isEqualToString:@"Garage/Stellplatz"])
    {
        strings = [NSArray arrayWithObjects:@"Garage/Stellplatz", price, nil];
    }
    else if([realtyType isEqualToString:@"Baugrund"])
    {
        strings = [NSArray arrayWithObjects:@"Baugrund",sizeString, price, nil];
    }
    

    result = [self StringWithSeparator:strings Atrributes:@[] ];
    return result;
}

-(NSAttributedString *)getSummaryFormattedForDetail
{
    NSAttributedString *result;
    NSArray *strings;
    
    NSString *sizeString = [NSString stringWithFormat:@"%@",[self.dictionary objectForKey:@"size"]];
    sizeString = [sizeString stringByAppendingString:@" m²"];
    
    NSString *roomsString = [NSString stringWithFormat:@"%@",[self.dictionary objectForKey:@"rooms"]];    
    
    roomsString = [roomsString stringByAppendingString:@" Z."];
    
    
    NSString *realtyType = [self.dictionary objectForKey:@"realty_type"];
    realtyType = [realtyType stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
   
    
    if([realtyType isEqualToString:@"Mietwohnung"] ||
       [realtyType isEqualToString:@"Miethaus"] ||
       [realtyType isEqualToString:@"Eigentumswohnung"] ||
       [realtyType isEqualToString:@"Eigentumshaus"]||
       [realtyType isEqualToString:@"Bürofläche (Miete)"]||
       [realtyType isEqualToString:@"Bürofläche (Ankauf)"])
    {
         strings = [NSArray arrayWithObjects:realtyType, sizeString, roomsString,nil];
    }
    
    else if([realtyType isEqualToString:@"WG/Zimmer"])
    {
        NSString *apartmentShareExisting = [self.dictionary objectForKey:@"apartment_share_existing"];
        NSString *apartmentShareWanted = [self.dictionary objectForKey:@"apartment_share_wanted"];
        
        NSArray *existing = [apartmentShareExisting componentsSeparatedByString:@","];
        NSArray *wanted = [apartmentShareWanted componentsSeparatedByString:@","];
        
        NSString *sizeWG = [NSString stringWithFormat:@"%luer WG",(unsigned long)(existing.count+wanted.count) ];
        
        strings = [NSArray arrayWithObjects:sizeWG, sizeString, roomsString, nil];
    }



    
    else if([realtyType isEqualToString:@"Proberaum"])
    {
        strings = [NSArray arrayWithObjects:@"Proberaum", [sizeString stringByAppendingString:@" Proberaumfläche"], nil];
    }
    
    else if([realtyType isEqualToString:@"Garage/Stellplatz"])
    {
        strings = [NSArray arrayWithObjects:@"Garage/Stellplatz", [self getCostFormatted:kDetailFormat] , nil];
    }
    else if([realtyType isEqualToString:@"Baugrund"])
    {
        strings = [NSArray arrayWithObjects:@"Baugrund",[sizeString stringByAppendingString:@"Grundstückfläche"] ,  nil];
    }
    
    result = [self StringWithSeparator:strings Atrributes:@[kBoldTextAttribute] ];
    return result;
}

-(NSAttributedString *)StringWithSeparator:(NSArray *)items Atrributes:(NSArray *)attributes
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]init];
    NSAttributedString *separator = [[NSAttributedString alloc] initWithString:@" / " attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor] }];
    
    //UIFont *font = [UIFont systemFontOfSize:17];
    NSDictionary *attribute = nil;
    UIFont *newFont = [UIFont boldSystemFontOfSize:17];
    
    if([attributes containsObject:kBoldTextAttribute])
        attribute = @{ NSFontAttributeName : newFont};
    
    int i=1;
    
    NSString *string = [items objectAtIndex:0];
    NSAttributedString *toAppend = [[NSAttributedString alloc] initWithString:string attributes:attribute];
    [result appendAttributedString:toAppend];
    
    
    for(;i<items.count;i++){
        [result appendAttributedString:separator];
        NSString *string = [items objectAtIndex:i];
        NSAttributedString *toAppend = [[NSAttributedString alloc] initWithString:string attributes:attribute];
        [result appendAttributedString:toAppend];
    }
    
    return result;
}

-(NSArray *)additionalCostsFormatted
{
    NSNumber *zero = [NSNumber numberWithInt:0];
    NSMutableArray *additionalCosts = [[NSMutableArray alloc] init];
    NSString *realtyType = [self.dictionary objectForKey:@"realty_type"];
    if([realtyType isEqualToString:@"Mietwohnung"]||[realtyType isEqualToString:@"Miethaus"])
    {
        NSNumber *addCost =[self.dictionary objectForKey:@"operation_costs"];
        NSString *addCostString = nil;
        
        if(!((NSNull *)addCost==[NSNull null] ||  [addCost isEqualToNumber:zero]))
        {
            addCostString = [[self formatter] stringFromNumber:  addCost];
            addCostString = [NSString stringWithFormat:@"%@%@ Betriebskosten",addCostString,_currency];
            [additionalCosts addObject:@{kSecondAdditionKey:addCostString}];
        }
        
        addCost =[self.dictionary objectForKey:@"cooperative_flat_costs"];
        addCostString = nil;
        if(!((NSNull *)addCost==[NSNull null] ||  [addCost isEqualToNumber:zero]))
        {
            addCostString = [[self formatter] stringFromNumber:  addCost];
            addCostString = [NSString stringWithFormat:@"%@%@ Genossenschaft",addCostString,_currency];
            [additionalCosts addObject:@{kSecondAdditionKey:addCostString}];
        }
        
        addCost =[self.dictionary objectForKey:@"transfer_costs"];
        addCostString = nil;
        if(!((NSNull *)addCost==[NSNull null] ||  [addCost isEqualToNumber:zero]))
        {
            addCostString = [[self formatter] stringFromNumber:  addCost];
            addCostString = [NSString stringWithFormat:@"%@%@ Ablöse",addCostString,_currency];
            [additionalCosts addObject:@{kSecondAdditionKey:addCostString}];
        }
        
        addCost =[self.dictionary objectForKey:@"additional_costs"];
        addCostString = nil;
        if(!((NSNull *)addCost==[NSNull null] ||  [addCost isEqualToNumber:zero]))
        {
            addCostString = [[self formatter] stringFromNumber:  addCost];
            addCostString = [NSString stringWithFormat:@"ca. %@%@ Strom + Heizk./Monat",addCostString,_currency];
            [additionalCosts addObject:@{kAdditionKey:addCostString}];
        }
        
        addCost =[self.dictionary objectForKey:@"deposit_costs"];
        addCostString = nil;
        if(!((NSNull *)addCost==[NSNull null] ||  [addCost isEqualToNumber:zero]))
        {
            addCostString = [[self formatter] stringFromNumber:  addCost];
            addCostString = [NSString stringWithFormat:@"%@%@ Kaution",addCostString,_currency];
            [additionalCosts addObject:@{kAdditionKey:addCostString}];
        }
    }
    return additionalCosts;
}


@end
