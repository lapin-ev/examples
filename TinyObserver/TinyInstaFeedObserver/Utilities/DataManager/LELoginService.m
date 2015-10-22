//
//  LELoginService.m
//  TinyInstaFeedObserver
//
//  Created by Jack Lapin on 21.10.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import "LELoginService.h"
#import <AFNetworking.h>
#import "LEAPIClient.h"
#import "InstaUser.h"

#pragma mark Instagram connect

static NSString *const kTokenRequestURL = @"https://api.instagram.com/oauth/access_token";
static NSString *const kBaseRequestURL = @"https://api.instagram.com/v1/tags/automotive/media/recent?";
static NSString *const kAuthRequestURL = @"https://api.instagram.com/oauth/authorize/";
static NSString *const kClientID = @"26b5f5babdea4c788158b2e892094435";
static NSString *const kClientSecret = @"5d8c265251f0435cb910e1b74745840e";
static NSString *const kGrant_type = @"authorization_code";
static NSString *const kRedirectURI = @"tinyInstaFeedObserver://";
static NSString *const kScope = @"basic+likes";
static NSString *const kResponseType = @"code&scope=basic+likes";

@implementation LELoginService

+(void)startLoginAction {
    NSString *fullAuthUrlString = [[NSString alloc]
                                   initWithFormat:@"%@?client_id=%@&redirect_uri=%@&response_type=%@",
                                   kAuthRequestURL,
                                   kClientID,
                                   kRedirectURI,
                                   kResponseType];
    NSURL *authUrl = [NSURL URLWithString:fullAuthUrlString];
    [[UIApplication sharedApplication] openURL:authUrl];
}

+ (void)loginWithUrl:(NSURL *)url {
    NSString *code = [url absoluteString];
    code = [code stringByReplacingOccurrencesOfString:@"tinyinstafeedobserver:?code=" withString:@""];
    [self getTokenWithCode:code complete:^(NSDictionary *answer) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationTokenWasAcquiredReadyToParce object:answer];
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
}

+ (void) getTokenWithCode:(NSString *)code complete:(LESuccesBlock)complBlock failure:(LEFailureBlock)failure
{
    __block NSString *userName = @"";
    NSDictionary *params =
    @{@"code":code,
      @"client_id":kClientID,
      @"client_secret":kClientSecret,
      @"grant_type":kGrant_type,
      @"redirect_uri":kRedirectURI
      };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager POST:kTokenRequestURL
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"%@", responseObject);
              NSString *token = [responseObject objectForKey:@"access_token"];
              [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
              [[NSUserDefaults standardUserDefaults] setObject:[[responseObject objectForKey:@"user"] objectForKey:@"profile_picture"] forKey:@"userAvURLString"];
              [[NSUserDefaults standardUserDefaults] setObject:[[responseObject objectForKey:@"user"] objectForKey:@"full_name"] forKey:@"fullUserName"];
              [[NSUserDefaults standardUserDefaults] setObject:[[responseObject objectForKey:@"user"] objectForKey:@"username"] forKey:@"userLogin"];
              userName = [[responseObject objectForKey:@"user"] objectForKey:@"username"];
              if (userName.length > 0 ) {
                  [[NSNotificationCenter defaultCenter] postNotificationName:NotificationLoginWasAcquired object:userName];
              }
              [LEAPIClient getDataNextURL:nil completeBlock:complBlock failure:failure];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
              failure(error);
          }];
}

@end
