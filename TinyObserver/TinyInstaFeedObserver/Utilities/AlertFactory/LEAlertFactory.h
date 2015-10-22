//
//  LEAlertFactoryViewController.h
//  CarManufacturers
//
//  Created by Jack Lapin on 10.09.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LEAlertFactory : UIAlertController

+ (UIAlertController*)showAlertWithTitle:(NSString *)title message:(NSString *)message;

@end
