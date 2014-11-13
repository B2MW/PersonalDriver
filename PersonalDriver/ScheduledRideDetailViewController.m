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
    // Send a notification to all devices subscribed to this Ride Channel
    PFPush *push = [[PFPush alloc] init];
    NSString *channelName = [NSString stringWithFormat:@"R%@",self.ride.objectId];
    [push setChannel:channelName];
    [push setMessage:@"Your driver is enroute. Estimated time of arrival is x minutes"];
    [push sendPushInBackground];
}

- (IBAction)onDirectionPressed:(UIButton *)sender {
}

- (IBAction)onCancelledPressed:(UIButton *)sender {
}



@end
