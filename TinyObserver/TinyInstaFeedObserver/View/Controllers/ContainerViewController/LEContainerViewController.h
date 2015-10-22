//
//  LECMContainerViewController.h
//  CarManufacturers
//
//  Created by Jack Lapin on 05.09.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LECollectionViewController.h"
#import "LETableViewController.h"

@interface LEContainerViewController : UIViewController

@property (nonatomic, strong) LETableViewController *tableController;
@property (nonatomic, strong) LECollectionViewController *collectionController;

- (void)swapViewControllers:(UINavigationItem *)navigationItem;

@end
