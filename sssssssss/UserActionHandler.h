//
//  UserActionHandler.h
//  Keychainsample
//
//  Created by Simon Anreiter on 04.12.13.
//  Copyright (c) 2013 INFOUND. All rights reserved.
//

#import <Foundation/Foundation.h>
@class InseratRecord;

@interface UserActionHandler : NSObject<NSURLConnectionDelegate>

@property(readwrite,copy) void (^completionHandler) (NSData *);

-(void)signUpUser:(NSString *)email Password:(NSString *)password PasswordConfirmation:(NSString *)passwordConfirmation;
-(void)signInUser:(NSString *)username Password:(NSString *)password;
-(void)logout;
-(void)toggleUserWatchList:(InseratRecord *)inseratRecord;
-(void)toggleUserWatchListItemWithIdentifier:(NSNumber *)identifier;
-(void)getUserWatchList;


@end
