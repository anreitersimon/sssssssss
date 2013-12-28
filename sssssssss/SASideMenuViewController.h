//
//  SASideMenuViewController.h
//  sssssssss
//
//  Created by Simon Anreiter on 13.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SASideMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UIViewController *currentViewController;
@property (strong, nonatomic) UIViewController *nextViewController;

@property (strong, nonatomic) UIView *currentView;
@property (strong, nonatomic) UIView *nextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property(nonatomic,strong) NSString *activeViewControllerIdentifier;
@property (nonatomic, strong) UIView *containerView;

@end