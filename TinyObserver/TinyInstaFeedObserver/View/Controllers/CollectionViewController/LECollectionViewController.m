//
//  LECMCollectionViewController.m
//  CarManufacturers
//
//  Created by Jack Lapin on 05.09.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import "LEContainerViewController.h"
#import "LECollectionViewController.h"
#import "LEDataSource.h"
#import "LECollectionCell.h"

int const kLessQuantityOfCellsInRow = 3;
int const kBigQuantityOfCellsInRow = 4;
int const kPrefereCellSize = 120;
float const kCellSpacing = 10.f;
int const kValueToUploadCollection = 3;



@interface LECollectionViewController () < UICollectionViewDataSource, UICollectionViewDelegate, LEDataSourceDelegate>

@property (nonatomic, strong) LEDataSource *dataSource;
@property (nonatomic, strong) NSMutableArray *itemChanges;

@end

@implementation LECollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [LEDataSource sharedDataSource];
}

-(void)viewWillAppear:(BOOL)animated {
    self.dataSource.delegate = self;
    [self.collectionView reloadData];
}

#pragma mark UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat mainScreen = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat cellSize = (mainScreen / kPrefereCellSize > kLessQuantityOfCellsInRow) ?
    (mainScreen - kCellSpacing) / (kLessQuantityOfCellsInRow) :
    (mainScreen - kCellSpacing) / (kBigQuantityOfCellsInRow);
    
    return CGSizeMake(cellSize, cellSize);
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dataSource countOfModels];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LECollectionCell *cell = (LECollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LECollectionCell class]) forIndexPath:indexPath];
    [cell configWithModel:[self.dataSource modelAtIndex:indexPath]];
    return cell;
}


#pragma mark - LECollectionCellDelegate


#pragma mark - IBactions

- (IBAction)handleLongPressAction:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.3f animations:^{
            UICollectionViewCell *cell = [weakSelf.collectionView cellForItemAtIndexPath:indexPath];
            cell.layer.transform = CATransform3DMakeRotation(M_PI,1.0,0.0,0.0);;
        } completion:^(BOOL finished) {
            [weakSelf.collectionView performBatchUpdates:^{
                     [weakSelf.dataSource deleteModelAtIndex:indexPath];
            } completion:nil];
        }];
    }
}

- (void)dataWillChange{
    self.itemChanges = [[NSMutableArray alloc] init];
}

- (void)dataWasChanged:(LEDataSource *)dataSource withType:(NSFetchedResultsChangeType)changeType atIndex:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath {
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    switch(changeType) {
        case NSFetchedResultsChangeInsert:
            change[@(changeType)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(changeType)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            break;
        case NSFetchedResultsChangeMove:
            break;
    }
    [self.itemChanges addObject:change];
}

- (void)dataDidChangeContent{
    [self.collectionView performBatchUpdates:^{
        for (NSDictionary *change in self.itemChanges) {
            [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                switch(type) {
                    case NSFetchedResultsChangeInsert:
                        [self.collectionView insertItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeDelete:
                        [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                        break;
                    case NSFetchedResultsChangeUpdate:
                        break;
                    case NSFetchedResultsChangeMove:
                        break;
                }
            }];
        }
    } completion:^(BOOL finished) {
        self.itemChanges = nil;
    }];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (([self.dataSource countOfModels] - indexPath.row) == kValueToUploadCollection) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationNewDataNeedToDownload object:nil];
    }
}

@end
