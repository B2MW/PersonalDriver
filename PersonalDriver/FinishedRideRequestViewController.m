//
//  FinishedRideRequestViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/16/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "FinishedRideRequestViewController.h"
#import "PassengerProfileViewController.h"

@interface FinishedRideRequestViewController ()

@end

@implementation FinishedRideRequestViewController

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    PassengerProfileViewController *passengerVC = [segue destinationViewController];
    passengerVC.ride = self.ride;
}





@end
