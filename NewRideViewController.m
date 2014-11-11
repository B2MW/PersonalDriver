//
//  NewRideViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//


#import "NewRideViewController.h"
#import "Ride.h"
#import "User.h"
#import <MZDayPicker.h>


@interface NewRideViewController ()

@property (weak, nonatomic) IBOutlet UISlider *passengerSlider;
@property (weak, nonatomic) IBOutlet UILabel *passengerTotalLabel;
@property (weak, nonatomic) IBOutlet UITextView *specialComments;
@property (weak, nonatomic) IBOutlet UISlider *dateSlider;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UISlider *hourSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property NSDate *currentDate;
@property NSDate *dayTwo;
@property NSDate *dayThree;
@property NSDate *dayFour;
@property NSDate *dayFive;
@property NSDate *daySix;
@property NSDate *daySeven;
@property NSDateFormatter *formatter;
@property NSString *dateString;
@property NSString *dateTwoString;
@property NSString *dateThreeString;
@property NSString *dateFourString;
@property NSString *dateFiveString;
@property NSString *dateSixString;
@property NSString *dateSevenString;


@end

@implementation NewRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger value = self.passengerSlider.value;
    NSString *passengerTotal = [NSNumber numberWithInteger:value].description;
    self.passengerTotalLabel.text = passengerTotal;


    self.formatter = [[NSDateFormatter alloc]init];
    [self.formatter setDateFormat:@"MMMM dd"];

    self.currentDate = [NSDate date];
    self.dayTwo = [self.currentDate dateByAddingTimeInterval:86400];
    self.dayThree = [self.currentDate dateByAddingTimeInterval:86400*2];
    self.dayFour = [self.currentDate dateByAddingTimeInterval:86400*3];
    self.dayFive = [self.currentDate dateByAddingTimeInterval:86400*4];
    self.daySix = [self.currentDate dateByAddingTimeInterval:86400*5];
    self.daySeven = [self.currentDate dateByAddingTimeInterval:86400*6];
    self.dateLabel.text = self.dateString;

    self.dateString = [self.formatter stringFromDate:self.currentDate];
    self.dateTwoString = [self.formatter stringFromDate:self.dayTwo];
    self.dateThreeString = [self.formatter stringFromDate:self.dayThree];
    self.dateFourString = [self.formatter stringFromDate:self.dayFour];
    self.dateFiveString = [self.formatter stringFromDate:self.dayFive];
    self.dateSixString = [self.formatter stringFromDate:self.daySix];
    self.dateSevenString = [self.formatter stringFromDate:self.daySeven];


}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];

}

- (IBAction)onRequestRideButtonPressed:(id)sender {

    User *user = [User currentUser];
    Ride *ride = [Ride object];

    NSNumber *fareEstimateMax = [NSNumber numberWithInt:self.price.highEstimate];
    NSNumber *fareEstimateMin = [NSNumber numberWithInt:self.price.lowEstimate];


    ride.passenger = user;
 //   ride.rideDateTime = self.datePicker.date;
  //  ride.specialInstructions = self.specialComments.text;
   // ride.destination = self.destinationLabel.text;
  //  ride.pickUpLocation = self.pickupLabel.text;
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


- (IBAction)onDateSliderMoved:(id)sender {

    if(self.dateSlider.value == 1){
        self.dateLabel.text = self.dateString;
    }

    else if(self.dateSlider.value == 2){
        self.dateLabel.text = self.dateTwoString;
    }

     else if(self.dateSlider.value == 3){
        self.dateLabel.text = self.dateThreeString;
    }

     else if(self.dateSlider.value == 4){
         self.dateLabel.text = self.dateFourString;
    }

     else if(self.dateSlider.value == 5){
        self.dateLabel.text = self.dateFiveString;

    }

     else if(self.dateSlider.value == 6){
        self.dateLabel.text = self.dateSixString;
    }

     else if(self.dateSlider.value == 7){
        self.dateLabel.text = self.dateSevenString;
    }

}

- (IBAction)onTimeSliderMoved:(id)sender {
    self.timeLabel.text = [NSString stringWithFormat:@"%.0f", self.hourSlider.value];
}





@end

