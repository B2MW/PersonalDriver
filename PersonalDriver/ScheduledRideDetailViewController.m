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
@property (weak, nonatomic) IBOutlet UIButton *arrivedButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@end

@implementation ScheduledRideDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.ride.passenger.name;
    self.arrivedButton.hidden = YES;

    

}
- (IBAction)onStartPressed:(UIButton *)sender {
    self.ride.driverEnRoute = YES;
    self.startButton.hidden = YES;
    self.arrivedButton.hidden = NO;
    [PushNotification sendPassengerEnrouteNotificationForRide:self.ride];

}
- (IBAction)onArrivedPressed:(id)sender {
}

- (IBAction)onDirectionPressed:(UIButton *)sender {
}

- (IBAction)onCancelledPressed:(UIButton *)sender {
}



@end
