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

//- (void)unhideRideDetails
//{
//    self.pickupAddressLabel.hidden = NO;
//    self.pickupAddress.hidden = NO;
//    self.dropoffAddressLabel = NO;
//    self.dropoffAddress = NO;
//    self.specialInstructionsLabel = NO;
//    self.specialInstructions = NO;
//}

- (IBAction)onScheduleRideButtonPressed:(id)sender
{
    Ride *ride = self.ride;
//    ride.driver = [PFUser currentUser];
    ride.driverConfirmed = YES;
    [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        [self refreshDisplay];
    }];
}

@end
