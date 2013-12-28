//
//  UserActionHandler.m
//  Keychainsample
//
//  Created by Simon Anreiter on 04.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import "UserActionHandler.h"
#import "SAAppDelegate.h"
#import "KeychainItemWrapper.h"
#import "InseratRecord.h"

static NSString *APIKey = @"EMvMRxgTbZq5RASoAbzJd9CZS5sumAfJ0Zm2ih2g";

@interface UserActionHandler ()
@property (nonatomic, strong) NSMutableData *activeDownload;
@property (nonatomic, strong) NSURLConnection *dataConnection;
@end

@implementation UserActionHandler


-(id)init
{
    self = [super init];
    return self;
}

-(void)signUpUser:(NSString *)email Password:(NSString *)password PasswordConfirmation:(NSString *)passwordConfirmation
{
    if(![password isEqualToString:passwordConfirmation]){
        //Existiert schon handeln
        NSLog(@"Password doesnt match confirmation");
        return;
    }
    self.activeDownload = [NSMutableData data];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlAsString = @"http://www.jimmbo.net/api/sign_up";
    NSString *params = [NSString stringWithFormat:@"api_key=%@&email=%@&password=%@&password_confirmation=%@",APIKey,email,password,passwordConfirmation];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.dataConnection = conn;
}


-(void)signInUser:(NSString *)email Password:(NSString *)password
{
    self.activeDownload = [NSMutableData data];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *urlAsString = @"http://www.jimmbo.net/api/sign_in";
    NSString *params = [NSString stringWithFormat:@"api_key=%@&email=%@&password=%@&",APIKey,email,password];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.dataConnection = conn;
}

-(void)logout
{
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    KeychainItemWrapper *keyChain = [appDelegate keychain];
    
    [keyChain resetKeychainItem];
}

-(void)toggleUserWatchList:(InseratRecord *)inseratRecord
{
    [self toggleUserWatchListItemWithIdentifier:inseratRecord.identifier];
}

-(void)toggleUserWatchListItemWithIdentifier:(NSNumber *)identifier
{
    self.activeDownload = [NSMutableData data];
    
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    KeychainItemWrapper *keyChain = [appDelegate keychain];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSString *urlAsString = @"http://www.jimmbo.net/api/toggle_watchlist_item";
    NSString *params = [NSString stringWithFormat:@"api_key=%@&authentication_token=%@&realty_id=%@",APIKey,[keyChain getAuthenticationToken],identifier ];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.dataConnection = conn;
}

-(void)getUserWatchList
{
    self.activeDownload = [NSMutableData data];
    
    SAAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    KeychainItemWrapper *keyChain = [appDelegate keychain];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSString *urlAsString =[NSString stringWithFormat:@"http://www.jimmbo.net/api/get_user_watchlist?api_key=%@&authentication_token=%@&limit=%d&offset=%d",APIKey,[keyChain getAuthenticationToken],100,0];
    
    urlAsString = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlAsString]];
    [request setHTTPMethod:@"GET"];

    
    // alloc+init and start an NSURLConnection; release on completion/failure
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.dataConnection = conn;
}


#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [self handleError:error];
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.dataConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if(self.completionHandler)
    {
        self.completionHandler(self.activeDownload);
    }
    
    self.activeDownload = nil;
    self.dataConnection = nil;
}

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Message"
														message:errorMessage
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
}
@end
