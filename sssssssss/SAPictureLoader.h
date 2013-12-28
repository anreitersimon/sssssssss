//
//  SAPictureLoader.h
//  LazyInseratLoad
//
//  Created by Simon Anreiter on 17.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InseratRecord;
@class SAAppDelegate;

@protocol SAPictureLoaderDelegate <NSObject>
// Required means if they want to use the delegate they
// have to implement it.
@optional
- (void)imageDownloadedForIndexPath:(NSIndexPath *)indexPath;
- (void)imageDownloadCompleteForIndexPath:(NSIndexPath *)indexPath;
- (void)imageDonwloadFailedWithErrorForIndexPath:(NSIndexPath *)indexPath Error:(NSError *)error;
- (void)imageDownloadCanceledForIndexPath:(NSIndexPath *)indexPath;
@end


@interface SAPictureLoader : NSObject 


@property NSUInteger imagesLoaded;
@property NSUInteger numberOfImages;
@property NSArray *imageURLs;
@property NSMutableArray *images;
@property (nonatomic, assign) id delegate;
@property (readwrite, copy) void (^completionHandler) (InseratRecord *);

@property (nonatomic, strong) InseratRecord *inseratRecord;

- (id)initWithInseratRecord:(InseratRecord *)inseratRecord atIndexPath:(NSIndexPath *)indexPath;

- (void)startImagesDownload;
- (void)cancelDownload;

@end
