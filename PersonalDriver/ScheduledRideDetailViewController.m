//
//  ScheduledRideDetailViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/8/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ScheduledRideDetailViewController.h"

@interface ScheduledRideDetailViewController ()

@end

@implementation ScheduledRideDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.ride.passenger.name;

}
- (IBAction)onStartPressed:(UIButton *)sender {
    self.ride.driverEnRoute = YES;
    //Create push notification for passenger
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"passenger"] = self.ride.passenger;
    [installation saveInBackground];

    // Create query for ride
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"channels" equalTo:@"global"]; // Set channel
    [pushQuery whereKey:@"ride" equalTo:self.ride];

    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setMessage:@"Your ride is on the way"];
    [push sendPushInBackground];
}

- (IBAction)onDirectionPressed:(UIButton *)sender {
}

- (IBAction)onCancelledPressed:(UIButton *)sender {
}



@end
