//
//  SAViewController.m
//  sssssssss
//
//  Created by Simon Anreiter on 06.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SAViewController.h"
#import "SAInseratLoader.h"
#import "InseratRecord.h"
#import "SAAppDelegate.h"
#import "CDInseratHandler.h"
#import "SAPictureLoader.h"
#import "SAInseratCell.h"
#import "SAInseratDetailViewController.h"
#import "UserActionHandler.h"


#define statusbarHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define kNavBarDefaultPosition CGPointMake(160, 22 + statusbarHeight) // we need this for later.  This is (iPhone) the center coordinate of a navigationBar in portrait mode.
#define kNavBarHiddenPosition CGPointMake(160, -22 + statusbarHeight)
static CGFloat scrollViewContentOffsetYThreshold = 100;

@interface SAViewController () <SAPictureLoaderDelegate, SAInseratLoaderDelegate>

@property(strong, nonatomic)CDInseratHandler *cdInseratHandler;
@property(strong, nonatomic)SAInseratLoader *inseratLoader;
@property(strong, nonatomic)UILabel *tableFooterLabel;
@property(nonatomic, strong)UserActionHandler *userActionHandler;

@property(strong, nonatomic)NSMutableDictionary *imageDownloadsInProgress;

@property(strong, nonatomic)NSDictionary *itemsInFavorites;

@property(nonatomic, strong) NSMutableDictionary *sections;
@property(nonatomic, strong) NSMutableArray *sectionNames;
@property(nonatomic, strong) UIColor *navBarTextColor;

@property CGPoint lastOffset;

@end

@implementation SAViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)saveInseratRecord:(InseratRecord *)inseratRecord IntoSection:(NSString *)sectionDescription
{
    if(_sections == nil)
        _sections = [[NSMutableDictionary alloc] init];
    if(_sectionNames == nil)
        _sectionNames = [[NSMutableArray alloc] init];
    
    NSMutableArray *data = [_sections objectForKey:sectionDescription];
    if(data == nil)
    {
        data = [[NSMutableArray alloc] init];
        [_sections setObject:data forKey:sectionDescription];
        [_sectionNames addObject:sectionDescription];
    }
    [data addObject:inseratRecord];
}

- (void)setBaseURL:(NSString *)baseURL{
    _baseURL = baseURL;
    NSLog(@"%@",_baseURL);
}


-(void)snapNavBarToPosition:(CGPoint)position
{
    
    [UIView animateWithDuration:0.1 animations:^{
        self.navigationController.navigationBar.tintColor = [_navBarTextColor colorWithAlphaComponent:[self opacityForNavBarPosition:position]];
        self.navigationController.navigationBar.layer.position = position;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    //CALayer *layer = self.navigationController.navigationBar.layer;
    
    // if the scrolling is not at the top and has passed the threshold, then set the navigationBar layer's position accordingly.

        //layer.position = kNavBarDefaultPosition;  // otherwise we are at the top and the navigation bar should be seen as if it can't scroll away.
}



- (void)viewWillDisappear:(BOOL)animated{
    //CALayer *layer = self.navigationController.navigationBar.layer;
    
    //layer.position = kNavBarDefaultPosition;
    //self.navigationController.navigationBar.tintColor = [_navBarTextColor colorWithAlphaComponent:[self opacityForNavBarPosition:kNavBarDefaultPosition]];
    //[self.navigationController.navigationBar.layer removeAllAnimations];
    [self stopAllDownloads];


}


- (void)stopAllDownloads
{
    NSArray *allDownloads = [_imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    [_imageDownloadsInProgress removeAllObjects];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self stopAllDownloads];
    [self dropOffscreenImages];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _managedObjectContext = appDelegate.managedObjectContext;
    _entries = [[NSMutableArray alloc] init];
    
    _imageDownloadsInProgress = [NSMutableDictionary dictionary];
    //NSString * baseURL = @"http://www.jimmbo.net/api/search?location=Salzburg-Österreich&order=price-desc";
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    refresh.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    
    [refresh addTarget:self
                action:@selector(reloadResults)
      forControlEvents:UIControlEventValueChanged];
    
    self.refreshControl = refresh;
    
    _tableFooterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    _tableFooterLabel.text = @"Pull To Load More";
    
    _inseratLoader = [[SAInseratLoader alloc] initWithTargetArray:_entries BaseURL:_baseURL IntervalSize:10];
    _inseratLoader.delegate = self;
    
    NSManagedObjectContext * backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext setParentContext:_managedObjectContext];
    
    _cdInseratHandler = [[CDInseratHandler alloc] initWithManagedObjectContext:backgroundContext Entries:_entries];
    _cdInseratHandler.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateFavorites)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:backgroundContext];
    
    _itemsInFavorites = [_cdInseratHandler identifiersForFavorites];
    _lastOffset = self.tableView.contentOffset;

    _navBarTextColor = self.navigationController.navigationBar.tintColor;
    
    CGFloat standardAlpha = CGColorGetAlpha([_navBarTextColor CGColor]);
    NSLog(@"Alpha: %f",standardAlpha);
    
    [_inseratLoader loadResults];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    _itemsInFavorites = [_cdInseratHandler identifiersForFavorites];
    [self.tableView reloadData];
}

-(void)updateFavorites
{
    _itemsInFavorites = [_cdInseratHandler identifiersForFavorites];
    [self.tableView reloadData];
}


- (void)dropOffscreenImages
{
    NSArray *indexPathsForVisibleCells = [self.tableView indexPathsForVisibleRows];

    NSUInteger firstSectionBorder = [[indexPathsForVisibleCells firstObject] row] -1;
    NSUInteger lastSectionBorder = [[indexPathsForVisibleCells lastObject] row] +1;
    
    NSIndexSet *firstSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, firstSectionBorder)];
    NSIndexSet *lastSection = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(lastSectionBorder, [_entries count] - lastSectionBorder )];
    
    [[_entries objectsAtIndexes:firstSection] makeObjectsPerformSelector:@selector(dropImages)];
    [[_entries objectsAtIndexes:lastSection] makeObjectsPerformSelector:@selector(dropImages)];
}

#pragma mark - InseratLoader Delegate Methods

-(void)reloadResults
{
    [_inseratLoader reloadResults];
}

- (void)refreshComplete:(BOOL)complete Date:(NSString *)lastUpdated{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)loadComplete:(BOOL)complete Date:(NSString *)lastUpdated
{
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:lastUpdated];
    [self.refreshControl endRefreshing];
    self.tableView.tableFooterView=_tableFooterLabel;
    [self.tableView reloadData];
}

- (void)loadFailedWithError:(NSError *)error{
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
    }
    
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Load Results"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];

}

-(void)allLoaded
{
    _tableFooterLabel.text = [NSString stringWithFormat:@"%lu Results", (unsigned long)_entries.count];
}

#pragma mark - Core Data Inserat Handler Delegate Methods

- (void)favoritesChanged{
    [self.tableView reloadData];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(_entries.count == 0)
        return 7;
    return _entries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_entries.count==0)
        return 60;
    return 312;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    CALayer *layer = self.navigationController.navigationBar.layer;
    
    layer.position = kNavBarDefaultPosition;
    self.navigationController.navigationBar.tintColor = [_navBarTextColor colorWithAlphaComponent:[self opacityForNavBarPosition:kNavBarDefaultPosition]];
    [self.navigationController.navigationBar.layer removeAllAnimations];
     */
    [self stopAllDownloads];
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        InseratRecord *object = [_entries objectAtIndex:indexPath.row];
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    static NSString *InseratCellIdentifier = @"InseratCell";
    
    // add a placeholder cell while waiting on table data
    NSUInteger entriesCount = [self.entries count];
    UITableViewCell *cell;
	if (entriesCount == 0)
	{
        
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if(indexPath.row == 0)
             cell.detailTextLabel.text = @"Loading…";
		
		return cell;
    }
    

    if (entriesCount > 0)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:InseratCellIdentifier];

        if(cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"SAInseratCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
    
        [self configureCell:(SAInseratCell *)cell atIndexPath:indexPath];
    }
    return cell;
}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSUInteger entriescount = [_entries count];
    if (!decelerate && entriescount>0)
	{
        [self loadImagesForOnscreenRows];
        CALayer *layer = self.navigationController.navigationBar.layer;
        
        CGFloat diffup =  layer.position.y - kNavBarHiddenPosition.y;
        CGFloat diffdown = kNavBarDefaultPosition.y - layer.position.y;
        
        if(diffup < diffdown)
            [self snapNavBarToPosition:kNavBarHiddenPosition];
        else
        {
            [self snapNavBarToPosition:kNavBarDefaultPosition];
        }
    }
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h + reload_distance) {
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        spinner.frame = CGRectMake(0, 0, 320, 44);
        self.tableView.tableFooterView = spinner;
        
        [_inseratLoader performSelector:@selector(loadMore) withObject:nil afterDelay:1.0];
        NSLog(@"load more rows");
    }
}

-(CGFloat)opacityForNavBarPosition:(CGPoint)position
{
    CGFloat standardAlpha = CGColorGetAlpha([_navBarTextColor CGColor]);
    CGFloat percent = ( position.y -kNavBarHiddenPosition.y )/ 44.0;
    return percent * standardAlpha;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    /*CALayer *layer = self.navigationController.navigationBar.layer;
    
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat distance = contentOffsetY -_lastOffset.y;
    
    UIEdgeInsets inset = scrollView.contentInset;
    float y = inset.top;
    
    if( y+contentOffsetY > scrollViewContentOffsetYThreshold){
        CGPoint newNavBarPosition = CGPointMake(layer.position.x, layer.position.y - distance);
        if (newNavBarPosition.y < kNavBarHiddenPosition.y) {
            layer.position = kNavBarHiddenPosition;
        }
        else if(newNavBarPosition.y > kNavBarDefaultPosition.y)
        {
            layer.position = kNavBarDefaultPosition;
        }
        else
        {
            layer.position = newNavBarPosition;
        }
        self.navigationController.navigationBar.tintColor = [_navBarTextColor colorWithAlphaComponent:[self opacityForNavBarPosition:newNavBarPosition]];
    }
    _lastOffset=scrollView.contentOffset;
     */
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    /*
    CALayer *layer = self.navigationController.navigationBar.layer;
    
    CGFloat diffup =  layer.position.y - kNavBarHiddenPosition.y;
    CGFloat diffdown = kNavBarDefaultPosition.y - layer.position.y;
    
    if(diffup < diffdown)
        [self snapNavBarToPosition:kNavBarHiddenPosition];
    else
    {
        [self snapNavBarToPosition:kNavBarDefaultPosition];
    }
    
     */
    if(_entries.count>0)
        [self loadImagesForOnscreenRows];
}

- (void)configureCell:(SAInseratCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    InseratRecord *inseratRecord = [_entries objectAtIndex:indexPath.row];
    
    inseratRecord.favorite=NO;
    
    if([[_itemsInFavorites objectForKey:inseratRecord.identifier] isEqualToString:@"true"])
    {
        inseratRecord.favorite=YES;
    }

    
    [cell initCellwithInserat:inseratRecord andParentViewController:self];
   
    if (inseratRecord.imageLoadComplete == NO)
    {
        if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
        {
            [self startImagesDownloadforIndexPath:indexPath];
        }
        // if a download is deferred or in progress, return a placeholder image
        //cell.imageView.image = [UIImage imageNamed:@"002.jpeg"];
    }
}



-(void)toggleInseratRecordatIndexPath:(NSIndexPath *)indexPath
{
    InseratRecord *inseratRecord = [_entries objectAtIndex:indexPath.row];
    if(_userActionHandler==nil)
        _userActionHandler = [[UserActionHandler alloc] init];
    [_userActionHandler toggleUserWatchList:inseratRecord];
    
    if(inseratRecord.favorite){
        [_cdInseratHandler deleteObject:inseratRecord];
        NSLog(@"unfavorited");
    }
    else{
        [_cdInseratHandler insertNewInserat:inseratRecord];
        NSLog(@"favorited");
    }
}


#pragma mark - Image Loader Methods

- (void)loadImagesForOnscreenRows
{
    if ([self.entries count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            [self startImagesDownloadforIndexPath:indexPath];
        }
    }
}

- (void)startImagesDownloadforIndexPath:(NSIndexPath *)indexPath
{
    InseratRecord *inseratRecord = [self.entries objectAtIndex:indexPath.row];
    if(inseratRecord.imageLoadComplete) return;
    
    SAPictureLoader *pictureLoader = [_imageDownloadsInProgress objectForKey:indexPath];
    if(pictureLoader == nil){
        pictureLoader = [[SAPictureLoader alloc] initWithInseratRecord:inseratRecord atIndexPath:indexPath];
        pictureLoader.delegate = self;
        [_imageDownloadsInProgress setObject:pictureLoader forKey:indexPath];
        
        [pictureLoader startImagesDownload];
    }
}

- (void)imageDownloadedForIndexPath:(NSIndexPath *)indexPath
{
    SAInseratCell *cell = (SAInseratCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell addNextPicture];
}

- (void)imageDownloadCompleteForIndexPath:(NSIndexPath *)indexPath
{
    [_imageDownloadsInProgress removeObjectForKey:indexPath];
}

-(void)imageDownloadCanceledForIndexPath:(NSIndexPath *)indexPath
{
    [_imageDownloadsInProgress removeObjectForKey:indexPath];
}

- (void)imageDonwloadFailedWithErrorForIndexPath:(NSIndexPath *)indexPath Error:(NSError *)error
{
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
