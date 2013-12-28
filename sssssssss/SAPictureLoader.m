//
//  SAPictureLoader.m
//  LazyInseratLoad
//
//  Created by Simon Anreiter on 17.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//

#import "SAPictureLoader.h"
#import "SAAppDelegate.h"
#import "InseratRecord.h"

@interface SAPictureLoader()
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *imageConnection;
@property (nonatomic, strong) NSString *requestURL;
@property (nonatomic, strong) NSMutableDictionary *imageCache;
@property (nonatomic, strong) NSTimer *timeOutTimer;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

@implementation SAPictureLoader

- (id)initWithInseratRecord:(InseratRecord *)inseratRecord atIndexPath:(NSIndexPath *)indexPath
{
    self = [super init];
    if(self != nil)
    {
        _indexPath = indexPath;
        _timeOutTimer = nil;
        _inseratRecord = inseratRecord;
        if(inseratRecord.images == nil)
            inseratRecord.images = [[NSMutableArray alloc] init];
        
        _imagesLoaded = inseratRecord.images.count;
        _imageURLs = inseratRecord.imageURLS;
    
        SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        _imageCache = appDelegate.imageCache;
    }
    return self;
}

- (void)startImagesDownload{
    //_inseratRecord.imageLoadComplete =YES;
    [self startNextImageDownload];
}

- (void)startNextImageDownload
{
    NSLog(@"djaihiusdhsai");
    self.activeDownload = [NSMutableData data];

    if(!(_imagesLoaded<_inseratRecord.imageURLS.count))
    {
        _inseratRecord.imageLoadComplete = YES;
        [self.delegate imageDownloadCompleteForIndexPath:_indexPath];
        if(_completionHandler)
           self.completionHandler(_inseratRecord);
        return;
    }
    
    _requestURL = [_imageURLs objectAtIndex:_imagesLoaded];
    UIImage *image = [_imageCache objectForKey:_requestURL];
    
    if(image)
    {
        [_inseratRecord.images addObject:image];
            _imagesLoaded++;
        
        [self.delegate imageDownloadCompleteForIndexPath:_indexPath];
        [self startNextImageDownload];
    }
    
    else
    {
       _timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                        target:self
                                      selector:@selector(a)
                                      userInfo:nil
                                       repeats:NO];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_requestURL]];
    
        // alloc+init and start an NSURLConnection; release on completion/failure
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
        self.imageConnection = conn;
    }
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
    [self.timeOutTimer invalidate];
    [self.delegate imageDownloadCanceledForIndexPath:_indexPath];
}

- (void)a{NSLog(@"Timeout");}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
    
    [self.delegate imageDonwloadFailedWithErrorForIndexPath:_indexPath Error:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_timeOutTimer invalidate];
    // Set appIcon and clear temporary data/image
    _imagesLoaded++;
    NSLog(@"Downloaded %lu/%lu", (unsigned long)_imagesLoaded, (unsigned long)_imageURLs.count);
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    
    if(_imageCache == nil)
        _imageCache = [[NSMutableDictionary alloc] init];
    
    [_imageCache setObject:image forKey:_requestURL];
    [_inseratRecord.images addObject:image];
    
    self.activeDownload = nil;
    self.imageConnection = nil;
    
    [self.delegate imageDownloadedForIndexPath:_indexPath];
    [self startNextImageDownload];
}



@end
