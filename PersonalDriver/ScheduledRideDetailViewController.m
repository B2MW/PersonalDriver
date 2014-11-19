//
//  ScheduledRideDetailViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/8/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ScheduledRideDetailViewController.h"
#import "PushNotification.h"
#import "RideManager.h"


@interface ScheduledRideDetailViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *estimatedFare;
@property (weak, nonatomic) IBOutlet UILabel *rideTime;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRiders;
@property (weak, nonatomic) IBOutlet UITextView *pickupAddress;
@property (weak, nonatomic) IBOutlet UITextView *dropoffAddress;
@property (weak, nonatomic) IBOutlet UITextView *specialInstructions;


@property (weak, nonatomic) IBOutlet UIButton *arrivedButton;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation ScheduledRideDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.title = self.ride.passenger.name;
    self.arrivedButton.hidden = YES;

}

- (void)viewWillAppear:(BOOL)animated
{
    RideManager *rideManager = [[RideManager alloc] init];
    self.estimatedFare.text = [NSString stringWithFormat:@"$%@-%@",self.ride.fareEstimateMin, self.ride.fareEstimateMax];

    self.numberOfRiders.text = self.ride.passengerCount;
    [rideManager retrieveGeoPointAddress:self.ride.pickupGeoPoint completionHandler:^(NSString *address)
     {
         self.pickupAddress.text = address;
     }];
    [rideManager retrieveGeoPointAddress:self.ride.dropoffGeoPoint completionHandler:^(NSString *address)
     {
         self.dropoffAddress.text = address;
     }];

    //Display and format special instructions
    if ([self.ride.specialInstructions isEqualToString:@""])
    {
        self.specialInstructions.text = @"No special instructions for this ride";
        self.specialInstructions.textColor = [UIColor grayColor];
    }
    else
    {
        self.specialInstructions.text = self.ride.specialInstructions;
    }

}
- (IBAction)onStartPressed:(UIButton *)sender {
    self.ride.driverEnRoute = YES;
    self.startButton.hidden = YES;
    self.cancelButton.hidden = YES;
    self.arrivedButton.hidden = NO;
    [PushNotification sendPassengerEnrouteNotificationForRide:self.ride];
    [self.ride saveInBackground];

}
- (IBAction)onArrivedPressed:(id)sender {
    self.ride.rideComplete = YES;
    self.ride.rideCompleteTime = [NSDate date];
    [self.ride saveInBackground];
    [PushNotification sendPassengerDriverArrived:self.ride];
}


- (IBAction)onCancelledPressed:(UIButton *)sender {

    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancel Ride" message:@"Are you sure you want to cancel this ride?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]){
        //NO is clicked do nothing
    }else{  //Yes is clicked. Delete
        self.ride.driver = nil;
        [PushNotification sendPassengerDriverCancelled:self.ride];
        [self.ride saveInBackground];
    }
}



@end
