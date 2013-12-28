//
//  SAAccountViewController.m
//  sssssssss
//
//  Created by Simon Anreiter on 18.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "SAAccountViewController.h"
#import "KeychainItemWrapper.h"
#import "SAAppDelegate.h"
#import "SALogInViewController.h"
#import "SARegisterViewController.h"

#define kappDelegate [[UIApplication sharedApplication] delegate]

@interface SAAccountViewController ()
@property(nonatomic,weak) KeychainItemWrapper *keychain;

@end

@implementation SAAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    SAAppDelegate *appDelegate =[[UIApplication sharedApplication] delegate];
    _keychain = [appDelegate keychain];
    
    [self.logoutLabel addTarget:self action:@selector(logoutUser) forControlEvents:UIControlEventTouchUpInside];
    [self.startSearchButton addTarget:self action:@selector(startSearch) forControlEvents:UIControlEventTouchUpInside];
    
    if([[_keychain getAuthenticationToken] isEqualToString:@""] || [_keychain getAuthenticationToken]==nil)
    {
        [self configureNotLoggedInView];
    }
    else
    {
        [self configureLoggedInView];
    }
	// Do any additional setup after loading the view.
}

- (void)startSearch
{
    SAAppDelegate *appDelegate =[[UIApplication sharedApplication] delegate];
    UIViewController *searchViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Suche"];
    appDelegate.window.rootViewController=searchViewController;
}

-(void)configureLoggedInView
{
    self.logoutLabel.hidden=NO;
    self.registerLabel.hidden=YES;
    self.loggedInLabel.hidden=NO;
    self.loggedInLabel.text=@"Eingeloggt als";
    self.loginLabel.hidden=YES;
    self.emailLabel.text = [_keychain getEmail];
}

-(void)configureNotLoggedInView
{
    self.logoutLabel.hidden=YES;
    self.registerLabel.hidden=NO;
    self.loggedInLabel.hidden=NO;
    self.loggedInLabel.text=@"Nicht eingeloggt";
    self.loginLabel.hidden=NO;
    self.emailLabel.hidden=YES;
}

-(void)userActionComplete:(BOOL)success
{
    if(success)
        [self configureLoggedInView];
}

- (void)logoutUser
{
    [_keychain resetKeychainItem];
    [self configureNotLoggedInView];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLoginScreen"] || [[segue identifier] isEqualToString:@"showRegisterScreen"]) {

        [[segue destinationViewController] setParentController:self];
    }
}

@end
