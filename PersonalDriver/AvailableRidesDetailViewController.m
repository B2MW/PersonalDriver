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
@property (strong, nonatomic) IBOutlet UILabel *numberOfPassengers;
@property (strong, nonatomic) IBOutlet UITextView *pickupAddress;
@property (strong, nonatomic) IBOutlet UITextView *dropoffAddress;

@end

@implementation AvailableRidesDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self refreshDisplay];
    [self getUserImage];
}

-(void)getUserImage
{
//    NSData *pictureData = [NSData new];

    PFQuery *queryForUserImage = [PFQuery queryWithClassName:@"_User"];
    [queryForUserImage whereKey:@"objectId" equalTo:self.ride.passenger.objectId];
    [queryForUserImage findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error || nil)
        {
            NSLog(@"Error: %@", error.userInfo);
            self.passengerPicture.image = [UIImage imageNamed:@"passengerPicPlaceholder"];
        }
        else
        {
            [objects.firstObject[@"picture"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    self.passengerPicture.image = [UIImage imageWithData:data];
                    [self refreshDisplay];
                }
            }];

//            PFFile *image = [PFFile fileWithData:objects.firstObject[@"picture"]];
//            NSData *data = [NSData dataWithData:image];
        }
    }];
}

-(void)refreshDisplay
{
    RideManager *rideManager = [[RideManager alloc] init];
//    self.passengerPicture.image = [UIImage imageNamed:@"passengerPicPlaceholder"];
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
//        [self refreshDisplay];
    }];
}

@end
