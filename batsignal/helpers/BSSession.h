//
//  BSSession.h
//  batsignal
//
//  Created by Kyle Warren on 4/25/13.
//  Copyright (c) 2013 Kyle Warren. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Accounts/Accounts.h>

@class BSUser;

@interface BSSession : NSObject

@property (nonatomic) ACAccount *twitterAccount;
@property (nonatomic, readonly) BSUser *user;
@property (nonatomic, readonly) NSString *accessToken;

+ (BSSession *)defaultSession;
+ (BOOL)hasAccount;

- (void)getTwitterAccounts:(void (^)(NSArray *accounts, NSString *error))handler;
- (void)authWithTwitterAccount:(ACAccount *)account;
- (void)logOut;
- (void)expired;

@end
