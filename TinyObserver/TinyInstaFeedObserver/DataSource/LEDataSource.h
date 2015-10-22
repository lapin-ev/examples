//
//  LEDataSource.h
//  CarManufacturers
//
//  Created by Jack Lapin on 05.09.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FOModel+CoreDataProperties.h"

static int const kFetchBatchSize = 20;

@protocol LEDataSourceDelegate;

@interface LEDataSource : NSObject <NSFetchedResultsControllerDelegate>

+ (LEDataSource *)sharedDataSource;

@property (nonatomic, strong) id<LEDataSourceDelegate> delegate;

- (void)insertModelWithCaption:(NSString *)caption
                      imageURL:(NSString *)imageURL
                       modelID:(NSString *)modelID;

- (NSUInteger)countOfModels;
- (FOModel *)modelAtIndex:(NSIndexPath *)indexPath;
- (FOModel *)modelWithID:(NSString *)idString;

- (void)deleteModelAtIndex:(NSIndexPath *)index;
- (void) deleteAll;


@end

@protocol LEDataSourceDelegate <NSObject>

@required

- (void)dataWasChanged:(LEDataSource *)dataSource
              withType:(NSFetchedResultsChangeType)changeType
               atIndex:(NSIndexPath *)indexPath
          newIndexPath:(NSIndexPath *)newIndexPath ;

@optional
- (void)dataWillChange;
- (void)dataDidChangeContent;

@end