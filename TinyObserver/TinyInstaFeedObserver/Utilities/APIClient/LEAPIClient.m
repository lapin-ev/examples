//
//  LEAPIClient.m
//  TinyInstaFeedObserver
//
//  Created by Jack Lapin on 08.10.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import "LEAPIClient.h"
#import <AFNetworking.h>

static const NSString * kCountPagination = @"10";

#pragma mark Instagram connect

static NSString *const kBaseRequestURL = @"https://api.instagram.com/v1/tags/automotive/media/recent?";


@implementation LEAPIClient

+ (void) getDataNextURL:(NSString *)nextURL completeBlock:(LESuccesBlock)block failure:(LEFailureBlock)failure {
    NSString *urlString = nextURL ? nextURL : kBaseRequestURL;
    NSDictionary *params = @{@"access_token": [[NSUserDefaults standardUserDefaults] stringForKey:@"token"], @"count":kCountPagination};
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:urlString
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             block(responseObject);
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             failure(error);
         }];
}

@end
