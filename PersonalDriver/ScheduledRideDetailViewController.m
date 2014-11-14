//
//  ScheduledRideDetailViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/8/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ScheduledRideDetailViewController.h"
#import "PushNotification.h"

@interface ScheduledRideDetailViewController ()

@end

@implementation ScheduledRideDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.ride.passenger.name;

}
- (IBAction)onStartPressed:(UIButton *)sender {
    self.ride.driverEnRoute = YES;
    [PushNotification sendPassengerEnrouteNotificationForRide:self.ride];

}

- (IBAction)onDirectionPressed:(UIButton *)sender {
}

- (IBAction)onCancelledPressed:(UIButton *)sender {
}



@end
