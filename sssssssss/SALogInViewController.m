//
//  SALogInViewController.m
//  Keychainsample
//
//  Created by Simon Anreiter on 11.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SALogInViewController.h"
#import "KeychainItemWrapper.h"
#import "SAAppDelegate.h"
#import "UserActionHandler.h"
#import "SAAccountViewController.h"

@interface SALogInViewController ()

@property(nonatomic, weak) KeychainItemWrapper *keychain;
@property(nonatomic, weak) UITextField *activeTextField;

@end

@implementation SALogInViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    self.statusLabel.hidden=YES;
    SAAppDelegate *appDelegate = [[ UIApplication sharedApplication] delegate];
    self.keychain = [appDelegate keychain];
    
    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.delegate=self;
    self.passwordTextField.delegate=self;

    [self configureLogInView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)configureLogInView
{
    self.passwordTextField.text=@"";
    self.statusLabel.hidden=YES;
    self.loginButton.enabled=NO;
    [self.cancelButton addTarget:self action:@selector(dismissViewControllerAnimated) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dismissViewControllerAnimated
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setParentController:(SAAccountViewController *)parentController
{
    _parentController=parentController;
}

- (void)loginButtonPressed
{
    self.emailTextField.userInteractionEnabled=NO;
    self.passwordTextField.userInteractionEnabled=NO;
    self.loginButton.userInteractionEnabled=NO;
    
    [self dismissKeyboard];
    
    if (self.emailTextField.text&& self.passwordTextField.text){
        UserActionHandler *userActionHandler = [[UserActionHandler alloc] init];
        [userActionHandler setCompletionHandler:^(NSData *response){
            NSError *error;
          
            NSDictionary *status = [NSJSONSerialization JSONObjectWithData:response
                                                                   options:kNilOptions
                                                                     error:&error];
            
            [self loginCompletedWithStatus:status];
            
            
        }];
        
        [userActionHandler signInUser:self.emailTextField.text Password:self.passwordTextField.text];
    }
}

-(void)loginCompletedWithStatus:(NSDictionary *)status
{
    self.emailTextField.userInteractionEnabled=YES;
    self.passwordTextField.userInteractionEnabled=YES;
    self.loginButton.userInteractionEnabled=YES;
    
    if([[status objectForKey:@"status"] isEqualToString:@"success"])
    {
        self.statusLabel.text = @"Login Erfolgreich";
        self.statusLabel.textColor = [UIColor greenColor];
        NSString *authToken = [status objectForKey:@"authentication_token"];
        
        [_keychain saveEmail:self.emailTextField.text];
        [_keychain savePassword:self.passwordTextField.text];
        [_keychain saveAuthenticationToken:authToken];
        
        if(_parentController!=nil)
            [_parentController userActionComplete:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else
    {
        NSDictionary *errors = [status objectForKey:@"errors"];
        self.statusLabel.text = @"Login Fehlgeschlagen";
        NSArray *emailErrors = [errors objectForKey:@"email"];
        if(emailErrors!=nil)
        {
            for(NSString *error in emailErrors){
                if([error isEqual:@"has already been taken"]){
                    self.statusLabel.text = @"Email-Adresse schon benutzt";
                }
            }
        }
        
        self.statusLabel.textColor = [UIColor redColor];
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.statusLabel.hidden = NO;
    }];
}

-(void)dismissKeyboard
{
    [_activeTextField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _activeTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(_emailTextField.text && _passwordTextField.text )
        _loginButton.enabled = YES;
    else
        _loginButton.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if(textField == self.emailTextField)
            [self.passwordTextField becomeFirstResponder];
    else if(textField == self.passwordTextField)
        [textField resignFirstResponder];
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
