//
//  FinishedRideViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/18/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "FinishedRideViewController.h"

@interface FinishedRideViewController ()

@end

@implementation FinishedRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
}



@end
