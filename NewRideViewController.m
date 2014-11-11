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
#import "Date.h"


@interface NewRideViewController () <DateDelegate>

@property (weak, nonatomic) IBOutlet UISlider *passengerSlider;
@property (weak, nonatomic) IBOutlet UILabel *passengerTotalLabel;
@property (weak, nonatomic) IBOutlet UITextView *specialComments;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelFour;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelFive;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelSix;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelSeven;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property NSDateFormatter *formatter;
@property NSDate *currentDate;
@property NSDate *dayTwo;
@property NSDate *dayThree;
@property NSDate *dayFour;
@property NSDate *dayFive;
@property NSDate *daySix;
@property NSDate *daySeven;

@property NSString *dateString;
@property NSString *dateTwoString;
@property NSString *dateThreeString;
@property NSString *dateFourString;
@property NSString *dateFiveString;
@property NSString *dateSixString;
@property NSString *dateSevenString;

@property (weak, nonatomic) IBOutlet UIButton *dateButtonOne;
@property (weak, nonatomic) IBOutlet UIButton *dateButtonTwo;
@property (weak, nonatomic) IBOutlet UIButton *dateButtonThree;
@property (weak, nonatomic) IBOutlet UIButton *dateButtonFour;
@property (weak, nonatomic) IBOutlet UIButton *dateButtonFive;
@property (weak, nonatomic) IBOutlet UIButton *dateButtonSix;
@property (weak, nonatomic) IBOutlet UIButton *dateButtonSeven;

@property NSMutableArray *dates;





@end

@implementation NewRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    NSInteger value = self.passengerSlider.value;
    NSString *passengerTotal = [NSNumber numberWithInteger:value].description;
    self.passengerTotalLabel.text = passengerTotal;
    self.dates = [NSMutableArray arrayWithObjects: self.dateButtonOne, self.dateButtonTwo, self.dateButtonThree, self.dateButtonFour, self.dateButtonFive, self.dateButtonSix, self.dateButtonSeven, nil];

    for (Date *date in self.dates) {
        date.delegate = self;
    }

    self.formatter = [[NSDateFormatter alloc]init];
    [self.formatter setDateFormat:@"MMM dd"];

    self.currentDate = [NSDate date];
    self.dayTwo = [self.currentDate dateByAddingTimeInterval:86400];
    self.dayThree = [self.currentDate dateByAddingTimeInterval:86400*2];
    self.dayFour = [self.currentDate dateByAddingTimeInterval:86400*3];
    self.dayFive = [self.currentDate dateByAddingTimeInterval:86400*4];
    self.daySix = [self.currentDate dateByAddingTimeInterval:86400*5];
    self.daySeven = [self.currentDate dateByAddingTimeInterval:86400*6];

    self.dateString = [self.formatter stringFromDate:self.currentDate];
    self.dateTwoString = [self.formatter stringFromDate:self.dayTwo];
    self.dateThreeString = [self.formatter stringFromDate:self.dayThree];
    self.dateFourString = [self.formatter stringFromDate:self.dayFour];
    self.dateFiveString = [self.formatter stringFromDate:self.dayFive];
    self.dateSixString = [self.formatter stringFromDate:self.daySix];
    self.dateSevenString = [self.formatter stringFromDate:self.daySeven];

    self.dateLabelOne.text = self.dateString;
    self.dateLabelTwo.text = self.dateTwoString;
    self.dateLabelThree.text = self.dateThreeString;
    self.dateLabelFour.text = self.dateFourString;
    self.dateLabelFive.text = self.dateFiveString;
    self.dateLabelSix.text = self.dateSixString;
    self.dateLabelSeven.text = self.dateSevenString;




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
    ride.rideDateTime = self.datePicker.date;
    ride.specialInstructions = self.specialComments.text;
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




-(void)dateButtonWasTapped:(Date *)sender {

    id buttons = @[self.dateButtonOne, self.dateButtonTwo, self.dateButtonThree, self.dateButtonFour, self.dateButtonFive, self.dateButtonSix, self.dateButtonSeven];

    for (UIButton *button in buttons) {
        button.tag = 0;
        [button setImage:[UIImage imageNamed:@"Oval 8"] forState:UIControlStateNormal];
    }

    sender.tag = 1;
    [sender setImage:[UIImage imageNamed:@"Oval 9"] forState:UIControlStateNormal];

}


@end













