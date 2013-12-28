//
//  SALogInViewController.h
//  Keychainsample
//
//  Created by Simon Anreiter on 11.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SAAccountViewController;

@interface SALogInViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@property (weak, nonatomic) SAAccountViewController *parentController;



-(void)setParentController:(SAAccountViewController *)viewController;

@end
