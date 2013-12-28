//
//  SAAccountViewController.h
//  sssssssss
//
//  Created by Simon Anreiter on 18.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SAAccountViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *loggedInLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIButton *logoutLabel;
@property (weak, nonatomic) IBOutlet UIButton *registerLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginLabel;
@property (weak, nonatomic) IBOutlet UIButton *startSearchButton;


-(void)userActionComplete:(BOOL)success;

@end
