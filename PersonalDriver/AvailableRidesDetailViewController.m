//
//  AvailableRidesDetailViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "AvailableRidesDetailViewController.h"

@interface AvailableRidesDetailViewController ()
@property (strong, nonatomic) IBOutlet UILabel *estimatedFare;
@property (strong, nonatomic) IBOutlet UILabel *rideDate;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPassengers;
@property (strong, nonatomic) IBOutlet UIView *pickupAddressLabel;
@property (strong, nonatomic) IBOutlet UITextView *pickupAddress;
@property (strong, nonatomic) IBOutlet UILabel *dropoffAddressLabel;
@property (strong, nonatomic) IBOutlet UITextView *dropoffAddress;
@property (strong, nonatomic) IBOutlet UILabel *specialInstructionsLabel;
@property (strong, nonatomic) IBOutlet UITextView *specialInstructions;
@property (strong, nonatomic) IBOutlet UIButton *scheduleRideButton;
@end

@implementation AvailableRidesDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveAvailableRidesData];
    [self hideRideDetails];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)retrieveAvailableRidesData
{
    RideManager *rideManager = [[RideManager alloc] init];

    //Query Parse User class
    PFQuery *queryForUserDetails = [PFQuery queryWithClassName:@"_User"];
    [queryForUserDetails whereKey:@"objectId" equalTo:self.ride.passenger.objectId];
    [queryForUserDetails findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error || nil)
         {
             NSLog(@"Error: %@", error.userInfo);
         }

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

         self.estimatedFare.text = [rideManager formatRideFareEstimate:self.ride.fareEstimateMin fareEstimateMax:self.ride.fareEstimateMax];
         self.rideDate.text = [rideManager formatRideDate:self.ride];
         self.numberOfPassengers.text = self.ride.passengerCount;
         [rideManager retrieveGeoPointAddress:self.ride.pickupGeoPoint completionHandler:^(NSString *address) {
             self.pickupAddress.text = address;
         }];
         [rideManager retrieveGeoPointAddress:self.ride.dropoffGeoPoint completionHandler:^(NSString *address) {
             self.dropoffAddress.text = address;
         }];
         
     }];
}

- (void)confirmRideAvailability
{
    UIAlertView *rideAvailabilityAlert = [UIAlertView new];
    PFQuery *queryRideAvailability = [PFQuery queryWithClassName:@"Ride"];
    [queryRideAvailability whereKey:@"objectId" equalTo:self.ride.objectId];
    [queryRideAvailability findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (self.ride.driver == nil)
        {
            //Update Ride Record
            Ride *ride = self.ride;
            ride.driver = [User currentUser];
            [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {

             }];

            //Show Ride Details
            [self unhideRideDetails];

            //Display Confirmation Alert View
            [rideAvailabilityAlert addButtonWithTitle:@"Ok"];
            [rideAvailabilityAlert setTitle:@"Ride Scheduled!"];
            [rideAvailabilityAlert setMessage:@"Thank you. You have been designated as the driver for this ride."];
            [rideAvailabilityAlert show];

            //Update button appearance and behavior
            [self.scheduleRideButton setTitle:@"Ride Confirmed" forState:UIControlStateNormal];
            self.scheduleRideButton.backgroundColor = [UIColor colorWithRed:(99.0/255.0) green:(193.0/255.0) blue:(43.0/255.0) alpha:0.65];
            self.scheduleRideButton.enabled = NO;
        }
        else
        {
            //Display "Too Slow" Alert View
            [rideAvailabilityAlert addButtonWithTitle:@"Ok"];
            [rideAvailabilityAlert setTitle:@"Too Slow"];
            [rideAvailabilityAlert setMessage:@"We're sorry. Another driver has scheduled this ride."];
            [rideAvailabilityAlert show];
        }
    }];
}

-(void)unhideRideDetails
{
    self.pickupAddressLabel.hidden = NO;
    self.pickupAddress.hidden = NO;
    self.dropoffAddressLabel.hidden = NO;
    self.dropoffAddress.hidden = NO;
    self.specialInstructionsLabel.hidden = NO;
    self.specialInstructions.hidden = NO;
}

-(void)hideRideDetails
{
    self.pickupAddressLabel.hidden = YES;
    self.pickupAddress.hidden = YES;
    self.dropoffAddressLabel.hidden = YES;
    self.dropoffAddress.hidden = YES;
    self.specialInstructionsLabel.hidden = YES;
    self.specialInstructions.hidden = YES;
}

- (IBAction)onScheduleRideButtonPressed:(id)sender
{
    [self confirmRideAvailability];
}

@end
