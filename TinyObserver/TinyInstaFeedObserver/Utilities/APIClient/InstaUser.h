//
//  InstaUser.h
//  TinyInstaFeedObserver
//
//  Created by Jack Lapin on 21.10.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstaUser : NSObject

@property (nonatomic, strong, readonly) NSString* login;
@property (nonatomic, strong, readonly) NSString* name;
@property (nonatomic, strong, readonly) NSString* avatarURL;

+ (InstaUser *)createUserWithLogin :(NSString *)login name:(NSString *)name avatarURLstring:(NSString *)avURLString;

- (NSArray *) colorsFromUserAvatar;

@end
