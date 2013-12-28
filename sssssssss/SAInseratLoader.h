//
//  SAInseratLoader.h
//  LazyInseratLoad
//
//  Created by Simon Anreiter on 17.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//

#import <Foundation/Foundation.h>
//@class InseratRecord;
@class SAAppDelegate;
@class InseratRecord;

@protocol SAInseratLoaderDelegate <NSObject>
// Required means if they want to use the delegate they
// have to implement it.
@required
- (void)refreshComplete:(BOOL)complete Date:(NSString *)lastUpdated;
- (void)loadComplete:(BOOL)complete Date:(NSString *)lastUpdated;
- (void)loadFailedWithError:(NSError *)error;
- (void)allLoaded;
- (void)saveInseratRecord:(InseratRecord *)inseratRecord IntoSection:(NSString *)sectionDescription;
@end

@interface SAInseratLoader : NSObject

//@property (nonatomic, strong) InseratRecord *inseratRecord;
//@property (nonatomic, strong) NSMutableArray *newObjects;

@property (nonatomic, assign) id delegate;

@property NSUInteger itemsLoaded;
@property (nonatomic, strong) NSString *baseURL;
@property NSUInteger intervalSize;
@property (nonatomic, strong) NSMutableArray *target;
@property (nonatomic, strong) NSString * lastUpdated;

@property (nonatomic, copy) void (^completionHandler)(void);
@property (nonatomic, strong) SAAppDelegate *appDelegate;


- (void) reloadResults;
- (void) loadMore;
- (void) loadResults;

- (void)cancelDownload;



- (id) initWithTargetArray:(NSMutableArray *)target BaseURL:(NSString *)baseURL IntervalSize:(NSUInteger)intervalSize;


@end
