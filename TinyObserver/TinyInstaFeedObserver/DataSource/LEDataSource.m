//
//  LEDataSource.m
//  CarManufacturers
//
//  Created by Jack Lapin on 05.09.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//
#import "LEDataSource.h"

@interface LEDataSource () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


@end


@implementation LEDataSource

#pragma mark - Lifecycle

+ (LEDataSource *)sharedDataSource {
    static LEDataSource * sharedManagerObject ;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        if (!sharedManagerObject) {
            sharedManagerObject = [[LEDataSource alloc] init];
            
        }
    });
    return sharedManagerObject;
}


#pragma mark - DataSource methods

- (void)deleteAll {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"FOModel"];
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    NSError *deleteError = nil;
    [self.persistentStoreCoordinator executeRequest:delete withContext:self.managedObjectContext error:&deleteError];
    [self saveContext];
    if ([self.delegate respondsToSelector:@selector(dataDidChangeContent)]) {
        [self.delegate dataDidChangeContent];
    }
}

- (NSUInteger)countOfModels {
    if ([[self.fetchedResultsController sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
        return [sectionInfo numberOfObjects];
    } else
        return 0;
}

- (FOModel *)modelAtIndex:(NSIndexPath*)indexPath {
    FOModel *model = [self.fetchedResultsController objectAtIndexPath:indexPath];
    return model;
}

- (void)deleteModelAtIndex:(NSIndexPath *)index {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    [context deleteObject:[self.fetchedResultsController objectAtIndexPath:index]];
    [self saveContext];
}

-(FOModel *)modelWithID:(NSString *)idString {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSString *entityClassName = NSStringFromClass([FOModel class]);
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityClassName inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSError *error = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modelID == %@", idString];
    [request setEntity:entity];
    [request setPredicate:predicate];
    NSArray *results = [context executeFetchRequest:request error:&error];
    return [results firstObject];
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - DataManage methods

- (void)insertModelWithCaption:(NSString *)caption imageURL:(NSString *)imageURL modelID:(NSString *)modelID {
    NSManagedObjectContext *context = self.managedObjectContext;
    NSString *entityClassName = NSStringFromClass([FOModel class]);
    FOModel *objectForInsert = [NSEntityDescription insertNewObjectForEntityForName:entityClassName inManagedObjectContext:context];
    
    [objectForInsert setValue:caption forKey:kModelDecription];
    [objectForInsert setValue:imageURL forKey:kModelImg];
    [objectForInsert setValue:modelID forKey:kModelId];
    [objectForInsert setValue:[NSDate date] forKey:kModelDateAdded];
    
    [self saveContext];
}


#pragma mark - Core Data stack
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"FOModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FOModel.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - FetchedResultsController

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    [self.delegate dataWasChanged:anObject withType:type atIndex:indexPath newIndexPath:newIndexPath];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    if ([self.delegate respondsToSelector:@selector(dataWillChange)]) {
        [self.delegate dataWillChange];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if ([self.delegate respondsToSelector:@selector(dataDidChangeContent)]) {
        [self.delegate dataDidChangeContent];
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* description =
    [NSEntityDescription entityForName:@"FOModel"
                inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:description];
    [fetchRequest setFetchBatchSize:kFetchBatchSize];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kModelDateAdded ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest
                                 managedObjectContext:context
                                 sectionNameKeyPath:nil
                                 cacheName:nil];
    _fetchedResultsController.delegate = self;
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"%@, %@", error, [error userInfo]);
    }
    return _fetchedResultsController;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
@end
