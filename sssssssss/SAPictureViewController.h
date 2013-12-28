//
//  SAPictureViewController.h
//  LazyInseratLoad
//
//  Created by Simon Anreiter on 22.10.13.
//  Copyright (c) 2013 Simon Anreiter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAPictureViewController : UIViewController <UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView *mainScrollView;
-(void)setImages:(NSMutableArray *)images ActivePage:(NSUInteger)activePage;


@end
