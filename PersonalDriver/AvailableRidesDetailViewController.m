//
//  AvailableRidesDetailViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "AvailableRidesDetailViewController.h"

@interface AvailableRidesDetailViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *passengerPicture;
@property (strong, nonatomic) IBOutlet UILabel *passengerName;
@property (strong, nonatomic) IBOutlet UILabel *estimatedFare;
@property (strong, nonatomic) IBOutlet UITextView *pickupAddress;
@property (strong, nonatomic) IBOutlet UITextView *dropoffAddress;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPassengers;

@end

@implementation AvailableRidesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshDisplay];
}

-(void)refreshDisplay
{
    RideManager *rideManager = [[RideManager alloc] init];
    self.passengerPicture.image = [UIImage imageNamed:@"passengerPicPlaceholder"];
    self.passengerName.text = @"Passenger's Name";
    self.numberOfPassengers.text = self.ride.passengerCount;
    self.estimatedFare.text = [rideManager formatRideFareEstimate:self.ride.fareEstimateMin :self.ride.fareEstimateMax];
    self.numberOfPassengers.text = self.ride.passengerCount;
    self.pickupAddress.text = @"111 S Wacker Dr\nChicago, IL 60606";
    self.dropoffAddress.text = @"848 W Montrose Ave\nChicago, IL 60616";
}

- (IBAction)onScheduleRideButtonPressed:(id)sender
{
    Ride *ride = self.ride;
//    ride.driver = [PFUser currentUser];
    ride.driverConfirmed = YES;
    [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self refreshDisplay];
    }];
}

@end
