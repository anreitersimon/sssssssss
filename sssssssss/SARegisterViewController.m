//
//  SARegisterViewController.m
//  Keychainsample
//
//  Created by Simon Anreiter on 04.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SARegisterViewController.h"
#import "KeychainItemWrapper.h"
#import "SAAppDelegate.h"
#import "UserActionHandler.h"
#import "SAAccountViewController.h"


@interface SARegisterViewController ()

@property(nonatomic, weak) KeychainItemWrapper *keychain;
@property(nonatomic, weak) UITextField *activeTextField;

@end

@implementation SARegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.statusLabel.hidden=YES;
    SAAppDelegate *appDelegate = [[ UIApplication sharedApplication] delegate];
    self.keychain = [appDelegate keychain];
    
    [self.registerButton addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];

    self.emailTextfield.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextfield.delegate=self;
    self.passwordTextField.delegate=self;
    self.passwordConfirmationTextField.delegate=self;

    [self configureRegisterView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];

	// Do any additional setup after loading the view, typically from a nib.
}

-(void)setParentController:(SAAccountViewController *)parentController
{
    _parentController=parentController;
}


-(void)configureRegisterView
{
    self.passwordTextField.text=@"";
    self.passwordConfirmationTextField.text=@"";
    self.statusLabel.hidden=YES;
    self.passwordConfirmationTextField.hidden=NO;
    self.registerButton.enabled=NO;
    [self.cancelButton addTarget:self action:@selector(dismissViewControllerAnimated) forControlEvents:UIControlEventTouchUpInside];
}

-(void)dismissViewControllerAnimated
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)registerButtonPressed
{
    self.emailTextfield.userInteractionEnabled=NO;
    self.passwordTextField.userInteractionEnabled=NO;
    self.passwordConfirmationTextField.userInteractionEnabled=NO;
    self.registerButton.userInteractionEnabled=NO;
    
    [self dismissKeyboard];
    
    if (self.emailTextfield.text&&self.passwordConfirmationTextField.text&&self.passwordTextField.text){
        UserActionHandler *userActionHandler = [[UserActionHandler alloc] init];
        [userActionHandler setCompletionHandler:^(NSData *response){
            NSError *error;
            //NSString *responsestring = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            
            NSDictionary *status = [NSJSONSerialization JSONObjectWithData:response
                                                                  options:kNilOptions
                                                                    error:&error];
            

                [self registerCompletedWithStatus:status];

            
        }];
        
        [userActionHandler signUpUser:self.emailTextfield.text Password:self.passwordTextField.text PasswordConfirmation:self.passwordConfirmationTextField.text];
    }
}

-(void)registerCompletedWithStatus:(NSDictionary *)status
{
    self.emailTextfield.userInteractionEnabled=YES;
    self.passwordTextField.userInteractionEnabled=YES;
    self.passwordConfirmationTextField.userInteractionEnabled=YES;
    self.registerButton.userInteractionEnabled=YES;
    
    if([[status objectForKey:@"status"] isEqualToString:@"success"])
    {
        self.statusLabel.text = @"Registrierung Erfolgreich";
        self.statusLabel.textColor = [UIColor greenColor];
        
        if(_parentController!=nil)
            [_parentController userActionComplete:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        NSDictionary *errors = [status objectForKey:@"errors"];
        self.statusLabel.text = @"Registrierung Fehlgeschlagen";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if(_emailTextfield.text && _passwordTextField.text && _passwordConfirmationTextField.text
       && [_passwordTextField.text isEqualToString:_passwordConfirmationTextField.text])
        _registerButton.enabled = YES;
    else
        _registerButton.enabled = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.emailTextfield)
        [self.passwordTextField becomeFirstResponder];
    else if(textField == self.passwordTextField)
        [self.passwordConfirmationTextField becomeFirstResponder];
    
    else if(textField == self.passwordConfirmationTextField)
        [textField resignFirstResponder];
    
    return NO;
}


@end
