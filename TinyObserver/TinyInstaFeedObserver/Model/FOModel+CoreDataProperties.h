//
//  FOModel+CoreDataProperties.h
//  TinyInstaFeedObserver
//
//  Created by Jack Lapin on 14.10.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FOModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FOModel (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *caption;
@property (nonatomic) NSTimeInterval dateAdded;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *modelID;

@end

NS_ASSUME_NONNULL_END
