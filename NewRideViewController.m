//
//  NewRideViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//




#import "NewRideViewController.h"
#import <Parse/Parse.h>
#import "Ride.h"

@interface NewRideViewController ()
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *specialComments;
@property (weak, nonatomic) IBOutlet UITextField *pickupLocationText;
@property (weak, nonatomic) IBOutlet UITextField *destinationText;
@property (weak, nonatomic) IBOutlet UISlider *passengerSlider;
@property (weak, nonatomic) IBOutlet UILabel *passengerTotalLabel;

@end

@implementation NewRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger value = self.passengerSlider.value;
    NSString *passengerTotal = [NSNumber numberWithInteger:value].description;
    self.passengerTotalLabel.text = passengerTotal;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];

}

- (IBAction)onRequestRideButtonPressed:(id)sender {

    PFUser *user = [PFUser currentUser];
    Ride *ride = [Ride object];


    ride.passenger = user;
    ride.rideDateTime = self.datePicker.date;
    ride.specialInstructions = self.specialComments.text;
    ride.destination = self.destinationText.text;
    ride.pickUpLocation = self.pickupLocationText.text;
    ride.passengerCount = [NSString stringWithFormat:@"%.0f", self.passengerSlider.value];
    //ride.driverConfirmed = NO;
    //ride.driverEnRoute = NO;
    //ride.pickupGeoPoint;
    //ride.dropoffGeoPoint;




    [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    }];

}

- (IBAction)onPassengerUpdateSliderMoved:(id)sender {
    self.passengerTotalLabel.text = [NSString stringWithFormat:@"%.0f", self.passengerSlider.value];
}



@end

