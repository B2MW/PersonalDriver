//
//  NewRideViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//


#import "NewRideViewController.h"
#import "Ride.h"


@interface NewRideViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *specialComments;
@property (weak, nonatomic) IBOutlet UISlider *passengerSlider;
@property (weak, nonatomic) IBOutlet UILabel *passengerTotalLabel;
@property (weak, nonatomic) IBOutlet UILabel *pickupLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationLabel;


@end

@implementation NewRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger value = self.passengerSlider.value;
    NSString *passengerTotal = [NSNumber numberWithInteger:value].description;
    self.passengerTotalLabel.text = passengerTotal;
    self.pickupLabel.text = self.pickupAddress;
    self.destinationLabel.text = self.destinationAddress;
    NSLog(@"geo points = %@", self.pickupGeopoint);
    self.title = @"Ride Info";

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];

}

- (IBAction)onRequestRideButtonPressed:(id)sender {

    PFUser *user = [PFUser currentUser];
    Ride *ride = [Ride object];

    NSNumber *fareEstimateMax = [NSNumber numberWithInt:self.price.highEstimate];
    NSNumber *fareEstimateMin = [NSNumber numberWithInt:self.price.lowEstimate];


    ride.passenger = user;
    ride.rideDateTime = self.datePicker.date;
    ride.specialInstructions = self.specialComments.text;
    ride.destination = self.destinationLabel.text;
    ride.pickUpLocation = self.pickupLabel.text;
    ride.passengerCount = [NSString stringWithFormat:@"%.0f", self.passengerSlider.value];
    ride.pickupGeoPoint = self.pickupGeopoint;
    ride.dropoffGeoPoint = self.destinationGeopoint;
    ride.fareEstimateMax = fareEstimateMax;
    ride.fareEstimateMin = fareEstimateMin;

    //ride.driverConfirmed = NO;
    //ride.driverEnRoute = NO;


    [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    }];

    

}

- (IBAction)onPassengerUpdateSliderMoved:(id)sender {
    self.passengerTotalLabel.text = [NSString stringWithFormat:@"%.0f", self.passengerSlider.value];
}






@end

