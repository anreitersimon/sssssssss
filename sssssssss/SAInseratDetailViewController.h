//
//  SAInseratDetailViewController.h
//  sssssssss
//
//  Created by Simon Anreiter on 22.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class InseratRecord;

@interface SAInseratDetailViewController : UITableViewController<MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) InseratRecord *inseratRecord;
@property CLLocationCoordinate2D center;

- (void)setDetailItem:(InseratRecord *)inseratRecord;

@end
