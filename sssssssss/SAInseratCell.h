//
//  SAPanCell.h
//  dddd
//
//  Created by Simon Anreiter on 04.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class InseratRecord;
@class SAAppDelegate;

@interface SAInseratCell : UITableViewCell <UIScrollViewDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic,strong) InseratRecord *inseratRecord;
@property (nonatomic, strong) SAAppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *createdOnLabel;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UILabel *firstDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondDetailLabel;


-(void) initCellwithInserat:(InseratRecord *)inseratRecord andParentViewController:(UITableViewController*)parentViewController;
-(void)addNextPicture;


@end

