//
//  SAPanCell.m
//  dddd
//
//  Created by Simon Anreiter on 04.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//
#import "SAInseratCell.h"
#import "SAAppDelegate.h"
#import "InseratRecord.h"
#import "SAAppDelegate.h"
#import "SAViewController.h"
//#import "SACoreDataInseratHandler.h"

@interface  SAInseratCell()

@property NSUInteger imagesLoaded;
@property (weak, nonatomic) UITableViewController *parentViewController;

//@property (strong, nonatomic) SACoreDataInseratHandler *inseratHandler;

@end


@implementation SAInseratCell



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    
    return self;
}



-(void) initCellwithInserat:(InseratRecord *)inseratRecord andParentViewController:(UITableViewController*)parentViewController{
    
    NSLog(@"New Cell");

    _inseratRecord = inseratRecord;
    _parentViewController = parentViewController;
    
    if(inseratRecord.favorite==YES)
        [self.favoriteButton setTitle:@"vorgemerkt" forState:UIControlStateNormal];
    else
        [self.favoriteButton setTitle:@"vormerken" forState:UIControlStateNormal];

    NSString *text = [_inseratRecord getRelativeDateFrom:[NSDate date] To:[_inseratRecord lastUpdatedDate]];;

    if([_inseratRecord updatedDateEqualsCreatedDate]){
        text = [text stringByAppendingString:@" inseriert"];
    }
    else
    {
        text = [text stringByAppendingString:@" aktualisiert"];
    }
    
    self.createdOnLabel.text = text;
    
    self.firstDetailLabel.text = [_inseratRecord getAdressFormatted:nil];
    NSAttributedString *summaryText = [_inseratRecord getSummaryFormattedForList];
    self.secondDetailLabel.attributedText =summaryText;
    //self.adressLabel.text=inseratRecord.adress;
   // self.detailsLabel.text=@"Beispieltext";
    
    [self.favoriteButton addTarget:self action:@selector(toggleFavorites) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped)];
    [tapGesture setNumberOfTouchesRequired:1];
    [tapGesture setNumberOfTapsRequired:1];
    [self.scrollView addGestureRecognizer:tapGesture];
    
    if(_inseratRecord.images.count>0){
       [self scrollViewWithImages];
    }
    else
    {
        [self scrollViewWithPlaceHolderImage];
    }

    }

-(void)addNextPicture
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * _inseratRecord.images.count, self.scrollView.frame.size.height);
    
    NSLog(@"Adding Picture: %lu", (unsigned long)_inseratRecord.images.count);
    
    NSUInteger page = _inseratRecord.images.count-1;
    
        CGRect frame = self.scrollView.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        frame = CGRectInset(frame, 5.0f, 0.0f);
        
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[_inseratRecord.images objectAtIndex:page]];
        
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
        newPageView.frame = frame;
        
        [self.scrollView addSubview:newPageView];
}

-(NSIndexPath *)indexPathForSelf
{
    UIView *view = self.superview;
    while(! [view isKindOfClass:[UITableView class]]){
        view = [view superview];
    }
    
    return [(UITableView *)view indexPathForCell:self];
}

-(void)scrollViewTapped
{
    [_parentViewController.tableView selectRowAtIndexPath:[self indexPathForSelf] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [_parentViewController performSegueWithIdentifier:@"showDetail" sender:nil];
}
-(void)populateTextFields
{
    NSString *type = [_inseratRecord.dictionary objectForKey:@"realty_type"];
    
    NSString *postalCode = [_inseratRecord.dictionary objectForKey:@"postalcode"];
    NSString *ort = [_inseratRecord.dictionary objectForKey:@"city"];
    
    NSAttributedString *separator = [[NSAttributedString alloc] initWithString:@" / " attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor] }];
    
    NSString *sizeString = [NSString stringWithFormat:@"%@",[_inseratRecord.dictionary objectForKey:@"size"]];
    sizeString = [sizeString stringByAppendingString:@" m²"];
    
    NSString *roomsString = [NSString stringWithFormat:@"%@",[_inseratRecord.dictionary objectForKey:@"rooms"]];
    roomsString = [roomsString stringByAppendingString:@" Z."];
    
    NSString *costsString = [_inseratRecord getCostFormatted:kListFormat];
    
    NSAttributedString *size = [[NSAttributedString alloc] initWithString:sizeString ];
    
    NSAttributedString *rooms = [[NSAttributedString alloc] initWithString:roomsString ];
    
    NSAttributedString *cost = [[NSAttributedString alloc] initWithString:costsString ];
   

    
    self.firstDetailLabel.text = [NSString stringWithFormat:@"%@ %@",postalCode, ort];
    
    NSMutableAttributedString *secondDetail = [[NSMutableAttributedString alloc] init];
    [secondDetail appendAttributedString:size];
    [secondDetail appendAttributedString:separator];
    [secondDetail appendAttributedString:rooms];
    [secondDetail appendAttributedString:separator];
    [secondDetail appendAttributedString:cost];
    
    //self.secondDetailLabel.text = [NSString stringWithFormat:@"%@m2 / %@Z. / %@Eur",size,rooms,cost];
    
    self.secondDetailLabel.attributedText = secondDetail;
    
    if([type isEqualToString:@"Mietwohnung"]||[type isEqualToString:@"Miethaus"]||[type isEqualToString:@"Bürofläche-Miete"])
    {
        
    }
}

-(NSString *)stringForDateDisplaying:(NSDate *)date Type:(NSString *)type
{
    NSDate *dateA = date;
    NSDate *dateB = [NSDate date];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit
                                               fromDate:dateA
                                                 toDate:dateB
                                                options:0];
    NSString *displayString;
    if(components.month==0 && components.year==0)
    {
        if(components.day<7){
            switch (components.day) {
                case 0:
                    displayString = [NSString stringWithFormat:@"Heute %@",type];
                    break;
                case 1:
                    displayString = [NSString stringWithFormat:@"Gestern %@",type];
                    break;
                case 2:
                    displayString = [NSString stringWithFormat:@"Vorgestern %@",type];
                    break;
                default:
                    displayString = [NSString stringWithFormat:@"Vor %lu Tagen %@", (unsigned long)components.day, type];
                    break;
            }
        }
        else
        {
            NSUInteger weeks = components.day / 7;
            displayString = [NSString stringWithFormat:@"Vor %lu Wochen %@", (unsigned long)weeks, type];
        }
    }
    else if(components.year==0)
    {
         displayString = [NSString stringWithFormat:@"Vor %lu Monaten %@", (unsigned long)components.month, type];
    }
    else
    {
        displayString = [NSString stringWithFormat:@"Vor %lu Jahren %@", (unsigned long)components.year, type];
    }
    
    
    NSLog(@"Difference in date components: %i/%i/%i", components.day, components.month, components.year);
    
    return displayString;
}

-(void)toggleFavorites
{
    [(SAViewController *)_parentViewController toggleInseratRecordatIndexPath:[self indexPathForSelf]];
}

-(void)scrollViewWithImages
{
    if(_inseratRecord.images.count == 1)
    {
        UIImageView *newPageView = [[UIImageView alloc] initWithImage:[_inseratRecord.images objectAtIndex:0]];
        CGRect frame = self.scrollView.frame;
        frame.origin.x = 5;
        
        newPageView.frame = frame;
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width + 10, self.scrollView.frame.size.height);
        
        [self.scrollView addSubview:newPageView];
    }
    
    else{
    
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * _inseratRecord.images.count, self.scrollView.frame.size.height);
    
    //NSLog(@"NumberOfPics: %lu", (unsigned long)_inseratRecord.images.count);

        for(int page=0; page<_inseratRecord.images.count; page++){
            CGRect frame = self.scrollView.bounds;
            frame.origin.x = frame.size.width * page;
            frame.origin.y = 0.0f;
            frame = CGRectInset(frame, 5.0f, 0.0f);
        
            UIImageView *newPageView = [[UIImageView alloc] initWithImage:[_inseratRecord.images objectAtIndex:page]];
        
            newPageView.contentMode = UIViewContentModeScaleAspectFit;
            newPageView.frame = frame;
        
            [self.scrollView addSubview:newPageView];
        }
    
        [self.scrollView setContentOffset:CGPointMake((self.scrollView.bounds.size.width)*_inseratRecord.activePage, 0)];
    }
}


-(void)scrollViewWithPlaceHolderImage
{
    CGRect frame = self.scrollView.bounds;
    UIView *newPageView = newPageView = [self newPlaceHolderWithFrame:frame];

    [self.scrollView addSubview:newPageView];
}

-(UIView *)newPlaceHolderWithFrame:(CGRect)frame
{
    UIView *placeHolder = [[UIView alloc] initWithFrame:frame];
    //placeHolder.backgroundColor = [UIColor lightGrayColor];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGRect avFrame = CGRectMake((frame.size.width - 25)/2.0,(frame.size.height - 25)/2.0, 25, 25);
    activityIndicator.frame = avFrame;
    [placeHolder addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    return placeHolder;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    
    _inseratRecord.activePage = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    //NSLog(@"ContentOffset: %f", self.scrollView.contentOffset.x);
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
