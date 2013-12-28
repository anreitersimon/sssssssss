//
//  SARegisterViewController.h
//  Keychainsample
//
//  Created by Simon Anreiter on 04.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Security/Security.h>
@class SAAccountViewController;

@interface SARegisterViewController : UIViewController<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UITextField *emailTextfield;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmationTextField;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) SAAccountViewController *parentController;



-(void)setParentController:(SAAccountViewController *)parentController;
-(void)registerSuccessFull:(BOOL)success;

@end
