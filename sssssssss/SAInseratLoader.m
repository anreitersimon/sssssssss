//
//  SAInseratLoader.m
//  LazyInseratLoad
//
//  Created by Simon Anreiter on 17.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//

#import "SAInseratLoader.h"
#import "InseratRecord.h"

@interface SAInseratLoader()
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *dataConnection;
@property (nonatomic, strong) NSMutableArray *oldData;
@property BOOL downloading;
//

@end

@implementation SAInseratLoader


- (id) initWithTargetArray:(NSMutableArray *)target BaseURL:(NSString *)baseURL IntervalSize:(NSUInteger)intervalSize
{
    self = [super init];
    if(self != nil)
    {
        _itemsLoaded = 0;
        _intervalSize = intervalSize;
        _baseURL = baseURL;
        _target = target;
        _downloading = NO;
        _oldData = nil;
    }
    return self;
}

- (void) reloadResults
{
    if(_downloading) return;
    _oldData = _target;
    
    _target = [[NSMutableArray alloc] init];
    
    NSUInteger offset = 0;
    NSUInteger limit = _itemsLoaded;
    
    _itemsLoaded = 0;
    
    NSString *url = [NSString stringWithFormat:@"%@&limit=%d&offset=%d", _baseURL, limit, offset];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    [self startDownloadfromURL:url];
}

- (void) loadMore
{
    if(_downloading) return;
    NSUInteger offset = _itemsLoaded;
    NSUInteger limit = _intervalSize;
    
    NSString *url = [NSString stringWithFormat:@"%@&limit=%d&offset=%d", _baseURL, limit, offset];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self startDownloadfromURL:url];
}

- (void) loadResults
{
    if(_downloading) return;
    
    if(_target == nil)
        _target = [[NSMutableArray alloc] init];
    
    NSUInteger offset = _itemsLoaded;
    NSUInteger limit = _intervalSize;
    
    NSString *url = [NSString stringWithFormat:@"%@&limit=%d&offset=%d", _baseURL, limit, offset];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [self startDownloadfromURL:url];
}

- (void)startDownloadfromURL:(NSString *)urlAsString
{
    self.activeDownload = [NSMutableData data];
    _downloading = YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.dataConnection = conn;
}

- (void)cancelDownload
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _downloading = NO;
    [self.dataConnection cancel];
    self.dataConnection = nil;
    self.activeDownload = nil;
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if(_oldData !=nil){
        _target = _oldData;
        _oldData = nil;
    }
    
	// Clear the activeDownload property to allow later attempts
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _downloading = NO;
    
    [self.delegate loadFailedWithError:error];

    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.dataConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter * formatter = [[NSDateFormatter  alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];

    [formatter setDoesRelativeDateFormatting:YES];
    [formatter setLocale:[NSLocale currentLocale]];
    
    _lastUpdated = [NSString stringWithFormat:@"last updated: %@ ",[formatter stringFromDate:now]];
    
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    _downloading = NO;
    NSError *error;
    
    NSArray *newObjects = [NSJSONSerialization JSONObjectWithData:self.activeDownload
                                                          options:kNilOptions
                                                            error:&error];
    
    if(newObjects.count==0)
        [self.delegate allLoaded];
    
    for(NSDictionary* object in newObjects){
        if(_target==nil)
            _target = [[NSMutableArray alloc]init];
        
        InseratRecord *inseratRecord = [[InseratRecord alloc] initWithJsonDictionary:object];
        
        [_target addObject:inseratRecord];
        _itemsLoaded++;
    }
   
    self.activeDownload = nil;
    self.dataConnection = nil;
    
    [self.delegate loadComplete:YES Date:_lastUpdated];
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Load Results"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
}

@end