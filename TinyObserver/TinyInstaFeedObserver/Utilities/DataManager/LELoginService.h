//
//  LELoginService.h
//  TinyInstaFeedObserver
//
//  Created by Jack Lapin on 21.10.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LELoginService : NSObject

+ (void) loginWithUrl :(NSURL *) url;
+ (void) startLoginAction;

@end
