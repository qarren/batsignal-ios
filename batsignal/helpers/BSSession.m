//
//  BSSession.m
//  batsignal
//
//  Created by Kyle Warren on 4/25/13.
//  Copyright (c) 2013 Kyle Warren. All rights reserved.
//

#import "BSSession.h"

#import <Social/Social.h>
#import <TWAPIManager.h>

#import "KWRequest.h"
#import "BSUser.h"

@interface BSSession ()

@property (nonatomic) ACAccountStore *accountStore;

@end

@implementation BSSession

@synthesize user = _user;

+ (BSSession *)defaultSession
{
    static BSSession *session = nil;
    if (!session) {
        session = [[BSSession alloc] init];
    }
    return session;
}

+ (BOOL)hasAccount
{
    return [BSSession defaultSession].user != nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
        
        _user = [BSUser find:[[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]];
        NSLog(@"user default id %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]);
        [self attemptToGrabTwitterAccount];
    }
    return self; 
}

- (void)attemptToGrabTwitterAccount
{
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
    self.twitterAccount = [accounts lastObject];
}

- (void)auth
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [self.accountStore requestAccessToAccountsWithType:accountType options:NULL completion:^(BOOL granted, NSError *error) {
            if (granted) {
                [self attemptToGrabTwitterAccount];
                
                NSLog(@"Logged in with %@ %@ %@", self.twitterAccount.username, self.twitterAccount.credential, self.twitterAccount.identifier);
                
                [TWAPIManager registerTwitterAppKey:@"YtG2yx3ltHAFx7RtXtKoA" andAppSecret:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"TWITTER_SECRET"]];
                [TWAPIManager performReverseAuthForAccount:self.twitterAccount withHandler:^(NSData *responseData, NSError *error) {
                    NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                    NSString *path = [NSString stringWithFormat:@"/auth/twitter_reverse/callback?%@", string];
                    
                    [KWRequest get:path callback:^(id response) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"session:authed" object:nil];
                        });
                        
                        _user = [BSUser findOrCreateWithDict:response];
                        [_user save];
                        [[NSUserDefaults standardUserDefaults] setValue:self.user.id forKey:@"userId"];
                        NSLog(@"user default id %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]);
                        
                        NSLog(@"response %@", response);
                    }];
                    
                    NSLog(@"got the creds %@", string);
                }];
                
                return;
                
                [KWRequest get:@"/twitter_reverse_auth_token" callback:^(NSDictionary *data) {
                    if (data) {
                        NSString *signedReverseAuthSig = data[@"sig"];
                        
                        NSLog(@"sig %@", signedReverseAuthSig);
                        
                        // step 2
                        NSDictionary *params = @{@"x_reverse_auth_target": @"YtG2yx3ltHAFx7RtXtKoA",
                                                 @"x_reverse_auth_parameters": signedReverseAuthSig};
                        
                        NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
                        SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                requestMethod:SLRequestMethodPOST
                                                                          URL:url
                                                                   parameters:params];
                        
                        
                        [request setAccount:self.twitterAccount];
                        [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                            NSString *string = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                            NSLog(@"got the creds %@ %@", string, urlResponse);
                        }];
                    } else {
                        NSLog(@"reverse auth failed");
                    }
                }];
            } else {
                // access not granted :(
                NSLog(@"Access denied");
            }
        }];
    } else {
        // not available :(
        NSLog(@"No accounts available");
    }
}

@end
