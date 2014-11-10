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
@property (strong, nonatomic) IBOutlet UILabel *rideDate;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPassengers;
@property (strong, nonatomic) IBOutlet UIView *pickupAddressLabel;
@property (strong, nonatomic) IBOutlet UITextView *pickupAddress;
@property (strong, nonatomic) IBOutlet UILabel *dropoffAddressLabel;
@property (strong, nonatomic) IBOutlet UITextView *dropoffAddress;
@property (strong, nonatomic) IBOutlet UILabel *specialInstructionsLabel;
@property (strong, nonatomic) IBOutlet UITextView *specialInstructions;
@end

@implementation AvailableRidesDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self retrieveAvailableRidesData];
    [self hideRideDetails];

    self.specialInstructions.text = self.ride.specialInstructions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)retrieveAvailableRidesData
{
    RideManager *rideManager = [[RideManager alloc] init];
    PFQuery *queryForUserDetails = [PFQuery queryWithClassName:@"_User"];
    [queryForUserDetails whereKey:@"objectId" equalTo:self.ride.passenger.objectId];
    [queryForUserDetails findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (error || nil)
        {
            NSLog(@"Error: %@", error.userInfo);
        }
        else
        {
            [objects.firstObject[@"picture"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
            {
                if (!error)
                {
                    if (data != nil)
                    {
                        self.passengerPicture.image = [UIImage imageWithData:data];
                    }
                    else
                    {
                        self.passengerPicture.image = [UIImage imageNamed:@"passengerPicPlaceholder"];
                    }
                }
            }];
        }
        self.passengerName.text = objects.firstObject[@"name"];
        self.estimatedFare.text = [rideManager formatRideFareEstimate:self.ride.fareEstimateMin fareEstimateMax:self.ride.fareEstimateMax];
        self.rideDate.text = [rideManager formatRideDate:self.ride];
        self.numberOfPassengers.text = self.ride.passengerCount;
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

-(void)populateRideLocationDetails
{
    if (self.specialInstructions.text == nil)
    {
        self.specialInstructions.text = @"No special instructions for this ride";
    }
    else
    {
        self.specialInstructions.text = self.ride.specialInstructions;
    }
}

- (IBAction)onScheduleRideButtonPressed:(id)sender
{
    [self confirmRideAvailability];
}

@end
