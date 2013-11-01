//
//  SADetailViewController.h
//  sssssssss
//
//  Created by Simon Anreiter on 01.11.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SADetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
