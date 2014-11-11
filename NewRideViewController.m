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



@end

@implementation NewRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger value = self.passengerSlider.value;
    NSString *passengerTotal = [NSNumber numberWithInteger:value].description;
    self.passengerTotalLabel.text = passengerTotal;

    self.currentDate = [NSDate date];
    self.formatter = [[NSDateFormatter alloc]init];
    [self.formatter setDateFormat:@"yyyy-MM-dd"];

    NSString *dateString = [self.formatter stringFromDate:self.currentDate];
    self.dateLabel.text = dateString;
    self.dayTwo = [self.currentDate dateByAddingTimeInterval:86400];
    self.dayThree = [self.currentDate dateByAddingTimeInterval:86400*2];
    self.dayFour = [self.currentDate dateByAddingTimeInterval:86400*3];
    self.dayFive = [self.currentDate dateByAddingTimeInterval:86400*4];
    self.daySix = [self.currentDate dateByAddingTimeInterval:86400*5];
    self.daySeven = [self.currentDate dateByAddingTimeInterval:86400*6];
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
        NSString *dateString = [self.formatter stringFromDate:self.currentDate];
        self.dateLabel.text = dateString;
    }

    if(self.dateSlider.value == 2){
        NSString *dayTwoString = [self.formatter stringFromDate:self.dayTwo];
        self.dateLabel.text = dayTwoString;
    }

    if(self.dateSlider.value == 3){
        NSString *dayThreeString = [self.formatter stringFromDate:self.dayThree];
        self.dateLabel.text = dayThreeString;
    }

    if(self.dateSlider.value == 4){
        NSString *dayFourString = [self.formatter stringFromDate:self.dayFour];
        self.dateLabel.text = dayFourString;
    }

    if(self.dateSlider.value == 5){
        NSString *dayFiveString = [self.formatter stringFromDate:self.dayFive];
        self.dateLabel.text = dayFiveString;

    }

    if(self.dateSlider.value == 6){
        NSString *daySixString = [self.formatter stringFromDate:self.daySix];
        self.dateLabel.text = daySixString;
    }

    if(self.dateSlider.value == 7){
        NSString *daySevenString = [self.formatter stringFromDate:self.daySeven];
        self.dateLabel.text = daySevenString;
    }

}

- (IBAction)onTimeSliderMoved:(id)sender {
    self.timeLabel.text = [NSString stringWithFormat:@"%.0f", self.hourSlider.value];
}





@end

