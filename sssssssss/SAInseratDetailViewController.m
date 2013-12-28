//
//  SAInseratDetailViewController.m
//  sssssssss
//
//  Created by Simon Anreiter on 22.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SAInseratDetailViewController.h"
#import "SAPictureLoader.h"
#import "InseratRecord.h"
#import "SAPictureViewController.h"

#define kContentTag 2
#define kDetailTag 3


static NSString *kMapCell = @"mapCell";
static NSString *kPictureCell = @"picturesCell";
static NSString *kTitleCell = @"titleCell";
static NSString *kSummaryCell = @"summaryCell";
static NSString *kstandardCell = @"standardCell";
static NSString *kAdditionCell = @"additionCell";
static NSString *kDescriptionCell = @"descriptionCell";

static NSString *kTitleKey = @"titleKey";
static NSString *kDetailKey = @"detailKey";
static NSString *kAttributeKey = @"attributeKey";


//static NSString *s

@interface SAInseratDetailViewController ()<SAPictureLoaderDelegate>

@property (nonatomic, strong) NSMutableArray *cellTypes;
@property (nonatomic, strong) NSMutableArray *entries;

@property (nonatomic, strong) NSString *realtyType;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) SAPictureLoader *pictureLoader;
@property (nonatomic, strong) NSIndexPath *indexPathForPictureCell;

@property (nonatomic, strong) NSMutableArray *firstSectionTypes;
@property (nonatomic, strong) NSMutableArray *firstSectionContent;
@property (nonatomic, weak) UILabel *descriptionLabel;



@end

@implementation SAInseratDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
     //self.tableView.contentInset = UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0);
    
    _realtyType = [_inseratRecord.dictionary objectForKey:@"realty_type"];
    
    NSMutableArray *firstSectionTypes = [[NSMutableArray alloc] init];
    NSMutableArray *firstSectionEntries = [[NSMutableArray alloc] init];
    
    NSMutableArray *secondSectionTypes = [[NSMutableArray alloc] init];
    NSMutableArray *secondSectionEntries = [[NSMutableArray alloc] init];
    
    NSMutableArray *thirdSectionTypes = [[NSMutableArray alloc] init];
    NSMutableArray *thirdSectionEntries = [[NSMutableArray alloc] init];
    
    
    NSNumber *lat = [_inseratRecord.dictionary objectForKey:@"google_lat"];
    NSNumber *lng = [_inseratRecord.dictionary objectForKey:@"google_lng"];
    
    if(!_inseratRecord.imageLoadComplete)
       [self startImagesDownload];
    
    NSNull *null = [NSNull null];
    
    if((NSNull *)lat!=null && (NSNull *)lng!=null){
        [firstSectionTypes addObject:kMapCell];
        [firstSectionEntries addObject:[@{@"lat":lat, @"lng":lng}mutableCopy] ];
    }
    
    [firstSectionTypes addObject:kTitleCell];
    [firstSectionEntries addObject:@{}];
    
    [firstSectionTypes addObject:kPictureCell];
    [firstSectionEntries addObject:@{}];
    
    [firstSectionTypes addObject:kSummaryCell];
    [firstSectionEntries addObject:@[@"realty_type", @"size", @"rooms"]];
    
    
    [secondSectionTypes addObject:kstandardCell];
    [secondSectionEntries addObject:@{kTitleKey:[_inseratRecord getCostFormatted:kDetailFormat], kAttributeKey:kBoldTextAttribute}];
    
    [self insertAdditionalCostData:secondSectionTypes SectionEntries:secondSectionEntries];
    
    [thirdSectionTypes addObject:kDescriptionCell];
    [thirdSectionEntries addObject:@{kTitleKey:[_inseratRecord.dictionary objectForKey:@"description"]}];
    
    

    _cellTypes = [[NSMutableArray alloc] initWithObjects:firstSectionTypes, secondSectionTypes, thirdSectionTypes, nil];
    _entries = [[NSMutableArray alloc] initWithObjects:firstSectionEntries, secondSectionEntries,thirdSectionEntries ,  nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //_center.latitude = [[_inseratRecord.data objectForKey:@"google_lat"] doubleValue];
    //_center.longitude = [[_inseratRecord.data objectForKey:@"google_lng"] doubleValue];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=NO;
}

- (CGFloat)heightForDescriptionCell
{
    NSString *descriptionText = [_inseratRecord.dictionary objectForKey:@"description"];
    CGSize maxSize = CGSizeMake(280, MAXFLOAT);
    UIFont *font = [UIFont systemFontOfSize:17];
    
    CGRect labelRect = [descriptionText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    
    NSLog(@"size %@", NSStringFromCGSize(labelRect.size));
    return labelRect.size.height;
}

-(void)configureAdditionCell:(UITableViewCell *)cell Text:(NSString *)text
{
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kContentTag];
    titleLabel.text = text;
}

-(void)configureDescriptionCell:(UITableViewCell *)cell
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 11, 280, [self heightForDescriptionCell])];
    
    NSString *descriptionText = [_inseratRecord.dictionary objectForKey:@"description"];
    label.text = descriptionText;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [label sizeToFit];
    label.frame = CGRectMake(20, 11, 280, [self heightForDescriptionCell]);
    
    [cell addSubview:label];
}

-(void)insertAdditionalCostData:(NSMutableArray *)sectionTypes SectionEntries:(NSMutableArray *)sectionEntries
{
    NSArray *additionalCosts = [_inseratRecord additionalCostsFormatted];
    
    for(NSDictionary *data in additionalCosts)
    {
        NSString *key = [[data allKeys] objectAtIndex:0];
        if(key == kSecondAdditionKey)
        {
            [sectionTypes addObject:kstandardCell];
            [sectionEntries addObject:@{kTitleKey:[data objectForKey:kSecondAdditionKey], kAttributeKey:kGreyTextAttribute}];
        }
        else if(key == kAdditionKey)
        {
            [sectionTypes addObject:kAdditionCell];
            [sectionEntries addObject:[data objectForKey:kAdditionKey]];
        }
    }
}

-(void)configureTitleCell:(UITableViewCell*)cell
{
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kContentTag];
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:kDetailTag];
    NSDate *date = [_inseratRecord lastUpdatedDate];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setLocale:[NSLocale currentLocale]];
    
    NSString *dateString = [NSString stringWithFormat:@"Zuletzt aktualisiert: %@",[formatter stringFromDate:date]];
    
    UIFont *font = [UIFont systemFontOfSize:17];
    UIFont *newFont = [UIFont boldSystemFontOfSize:17];
    
    NSString *postalCode = [_inseratRecord.dictionary objectForKey:@"postalcode"];
    NSString *city = [_inseratRecord.dictionary objectForKey:@"city"];
    
    NSAttributedString *cityAndCode = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@", %@ %@", postalCode, city] attributes:@{ NSFontAttributeName : font}];
    
    NSString *streetString = [_inseratRecord.dictionary objectForKey:@"street"];
    
    NSMutableAttributedString *street = [[NSMutableAttributedString alloc] initWithString:streetString attributes:@{ NSFontAttributeName : newFont}];
    [street appendAttributedString:cityAndCode];
    
    titleLabel.attributedText = street;
    detailLabel.text = dateString;
}

-(void)configureMapCell:(UITableViewCell *)cell Latitude:(double)lat Longitude:(double)lng
{
    MKMapView *mapView = (MKMapView *)[cell viewWithTag:kContentTag];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lng);
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    [annotation setCoordinate:center];
    //[annotation setTitle:@"Title"]; //You can set the subtitle too
    [mapView addAnnotation:annotation];
    [mapView setRegion:MKCoordinateRegionMakeWithDistance(center, 600, 600) animated:NO ];
}

-(void)configureSummaryCell:(UITableViewCell *)cell Keys:(NSArray *)keys
{
    UILabel *label = (UILabel *)[cell viewWithTag:kContentTag];
    label.attributedText = [_inseratRecord getSummaryFormattedForDetail];
}

-(void)configureStandardCell:(UITableViewCell *)cell Data:(NSDictionary *)data
{
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:kContentTag];
    
    CGFloat fontSize = [titleLabel.font pointSize];
     UIFont *newFont = [UIFont boldSystemFontOfSize:fontSize];
    
    NSDictionary *attribute = nil;
    if([data objectForKey:kAttributeKey] == kBoldTextAttribute){
        attribute = @{ NSFontAttributeName : newFont};
    }
    if([data objectForKey:kAttributeKey] == kGreyTextAttribute){
        attribute = @{NSForegroundColorAttributeName:[UIColor lightGrayColor] };
    }
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc]initWithString:[data objectForKey:kTitleKey] attributes:attribute];
    titleLabel.attributedText = text;
}

-(NSAttributedString *)StringWithSeparator:(NSArray *)items
{
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc]init];
    NSAttributedString *separator = [[NSAttributedString alloc] initWithString:@" / " attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor] }];
    
    //UIFont *font = [UIFont systemFontOfSize:17];
    UIFont *newFont = [UIFont boldSystemFontOfSize:17];
    
    int i=1;
    
    NSString *string = [items objectAtIndex:0];
    NSAttributedString *toAppend = [[NSAttributedString alloc] initWithString:string attributes:@{ NSFontAttributeName : newFont}];
    [result appendAttributedString:toAppend];
    
    
    for(;i<items.count;i++){
        [result appendAttributedString:separator];
        NSString *string = [items objectAtIndex:i];
        NSAttributedString *toAppend = [[NSAttributedString alloc] initWithString:string attributes:@{ NSFontAttributeName : newFont}];
        [result appendAttributedString:toAppend];
    }
    
    return result;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDetailItem:(InseratRecord *)inseratRecord
{
    _inseratRecord = inseratRecord;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _cellTypes.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[_cellTypes objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    NSArray *types = [_cellTypes objectAtIndex:indexPath.section];
    NSArray *entries = [_entries objectAtIndex:indexPath.section];
    
    if([types objectAtIndex:indexPath.row]==kMapCell){
        cell = [tableView dequeueReusableCellWithIdentifier:kMapCell forIndexPath:indexPath];
        NSDictionary *coordinates = [entries objectAtIndex:indexPath.row];
        NSNumber *lat = [coordinates objectForKey:@"lat"];
        NSNumber *lng = [coordinates objectForKey:@"lng"];
        [self configureMapCell:cell Latitude:[lat doubleValue] Longitude:[lng doubleValue]];
    }
    if([types objectAtIndex:indexPath.row]==kPictureCell){
        _indexPathForPictureCell = indexPath;
        cell = [tableView dequeueReusableCellWithIdentifier:kPictureCell forIndexPath:indexPath];
        UICollectionView *collectionView = (UICollectionView *)[cell viewWithTag:kContentTag];
        
        _collectionView = collectionView;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        UITapGestureRecognizer *collectionViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedCollectionView:)];
        [collectionViewTap setNumberOfTouchesRequired:1];
        
        [self.collectionView addGestureRecognizer:collectionViewTap];
    }
    
    if([types objectAtIndex:indexPath.row]==kstandardCell){
        cell = [tableView dequeueReusableCellWithIdentifier:kstandardCell forIndexPath:indexPath];
        [self configureStandardCell:cell Data:[entries objectAtIndex:indexPath.row]];

    }
    
    if([types objectAtIndex:indexPath.row]==kTitleCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kTitleCell forIndexPath:indexPath];
        [self configureTitleCell:cell];
    }
    
    if([types objectAtIndex:indexPath.row]==kSummaryCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kSummaryCell forIndexPath:indexPath];
        NSArray *keys = [entries objectAtIndex:indexPath.row];
        [self configureSummaryCell:cell Keys:keys];
    }
    
    if([types objectAtIndex:indexPath.row]==kAdditionCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kAdditionCell forIndexPath:indexPath];
        [self configureAdditionCell:cell Text:[entries objectAtIndex:indexPath.row]];
    }
    
    if([types objectAtIndex:indexPath.row]==kDescriptionCell)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kDescriptionCell forIndexPath:indexPath];
        [self configureDescriptionCell:cell ];
    }

    if(indexPath.row==entries.count-1)
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    else
        cell.separatorInset = UIEdgeInsetsMake(0, 320, 0, 0);
    // Configure the cell...
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *types = [_cellTypes objectAtIndex:indexPath.section];
    NSString *reuseIdentifier = [types objectAtIndex:indexPath.row];;
    
    if([reuseIdentifier isEqual:kMapCell])
        return 160;
    else if([reuseIdentifier isEqual:kTitleCell])
        return 60;
    
    else if([reuseIdentifier isEqual:kPictureCell]){
        NSUInteger rows = _inseratRecord.imageURLS.count/4;
        if(_inseratRecord.imageURLS.count %4 != 0)
            rows++;
        return rows*79;
    }
    
    else if([reuseIdentifier isEqual:kDescriptionCell])
    {
        return [self heightForDescriptionCell] +22;
    }
    
    else if([reuseIdentifier isEqual:kstandardCell] || [reuseIdentifier isEqual:kAdditionCell])
    {
        return 38;
    }
    
    return 44;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _inseratRecord.imageURLS.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"pictureCell";
    static NSString *placeHolderIdentifier = @"placeHolderCell";
    UICollectionViewCell *cell;
    if(indexPath.row<_inseratRecord.images.count){
    
         cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    
        imageView.image = [_inseratRecord.images objectAtIndex:indexPath.row];
    }
    else
    {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:placeHolderIdentifier forIndexPath:indexPath];
        [cell addSubview:[self newPlaceHolderWithFrame:CGRectMake(0, 0, 78, 78)]];
    }
    
    return cell;
}

-(void) tappedCollectionView:(UITapGestureRecognizer *)recognizer
{
    CGPoint tapLocation = [recognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    [_collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredVertically];
    [self performSegueWithIdentifier:@"showPictures" sender:nil];
    
}

- (void)startImagesDownload
{
    InseratRecord *inseratRecord = _inseratRecord;
    if(inseratRecord.imageLoadComplete) return;
    
    if(_pictureLoader==nil)
        _pictureLoader = [[SAPictureLoader alloc] initWithInseratRecord:_inseratRecord atIndexPath:nil];
    _pictureLoader.delegate = self;
    [_pictureLoader startImagesDownload];
}

- (void)imageDownloadedForIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView reloadData];
}

- (void)imageDownloadCompleteForIndexPath:(NSIndexPath *)indexPath
{
}

-(void)imageDownloadCanceledForIndexPath:(NSIndexPath *)indexPath
{
}

- (void)imageDonwloadFailedWithErrorForIndexPath:(NSIndexPath *)indexPath Error:(NSError *)error
{
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



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"showPictures"]) {
        NSIndexPath *indexPath = [_collectionView.indexPathsForSelectedItems objectAtIndex:0];
        [[segue destinationViewController] setImages:_inseratRecord.images ActivePage:indexPath.row];
    }
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
