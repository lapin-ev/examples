//
//  LEAlertFactoryViewController.m
//  CarManufacturers
//
//  Created by Jack Lapin on 10.09.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//

#import "LEAlertFactory.h"

@interface LEAlertFactory ()

@end

@implementation LEAlertFactory

+ (UIAlertController *)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController * alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"OK", nil)]
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    return alert;
}

@end
