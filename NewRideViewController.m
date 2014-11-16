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
#import "PassengerLabel.h"
#import "PushNotification.h"


@interface NewRideViewController () <DateDelegate, PassengerDelegate>

//@property (weak, nonatomic) IBOutlet UISlider *passengerSlider;
//@property (weak, nonatomic) IBOutlet UILabel *passengerTotalLabel;
@property (weak, nonatomic) IBOutlet UITextView *specialComments;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelOne;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelTwo;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelThree;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelFour;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelFive;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelSix;
@property (weak, nonatomic) IBOutlet UILabel *dateLabelSeven;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (weak, nonatomic) IBOutlet PassengerLabel *passengerLabelOne;
@property (weak, nonatomic) IBOutlet PassengerLabel *passengerLabelTwo;
@property (weak, nonatomic) IBOutlet PassengerLabel *passengerLabelThree;
@property (weak, nonatomic) IBOutlet PassengerLabel *passengerLabelFour;


@property NSDateFormatter *formatter;
@property NSDateFormatter *timeFormatter;
@property NSDateFormatter *dayFormatter;
@property NSDateFormatter *parseFormatter;
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
@property NSMutableArray *passengerAmounts;
@property NSDate *selectedDay;
@property NSDate *selectedTime;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;

@property (weak, nonatomic) IBOutlet UILabel *pickupTimeLabel;




@end

@implementation NewRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Ride Info";

    self.dates = [NSMutableArray arrayWithObjects: self.dateButtonOne, self.dateButtonTwo, self.dateButtonThree, self.dateButtonFour, self.dateButtonFive, self.dateButtonSix, self.dateButtonSeven, nil];

    for (Date *date in self.dates) {
        date.delegate = self;
    }

    self.passengerAmounts = [NSMutableArray arrayWithObjects:self.passengerLabelOne, self.passengerLabelTwo, self.passengerLabelThree, self.passengerLabelFour, nil];

    for (PassengerLabel *passenger in self.passengerAmounts) {
        passenger.delegate = self;
    }

    self.formatter = [[NSDateFormatter alloc]init];
    [self.formatter setDateFormat:@"MMM dd"];

    self.dayFormatter = [[NSDateFormatter alloc]init];
    [self.dayFormatter setDateFormat:@"MMM dd, yyyy"];


    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setDateFormat:@"HH:mm"];

    self.parseFormatter = [[NSDateFormatter alloc] init];
    [self.parseFormatter setDateFormat:@"MMM dd, yyyy, HH:mm"];

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


    self.dateButtonOne.tag = 1;
    [self.dateButtonOne setImage:[UIImage imageNamed:@"Oval 9"] forState:UIControlStateNormal];

    self.passengerLabelOne.tag = 1;
    self.passengerLabelOne.backgroundColor = [UIColor colorWithRed:45.0/255.0 green:44.0/255.0 blue:58.0/255.0 alpha:1.0];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

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
    ride.pickupGeoPoint = self.pickupGeopoint;
    ride.dropoffGeoPoint = self.destinationGeopoint;
    ride.fareEstimateMax = fareEstimateMax;
    ride.fareEstimateMin = fareEstimateMin;
    ride.destination = self.destinationAddress;
    ride.destination = self.pickupAddress;



    if (self.dateButtonOne.tag ==1)
    {
        self.selectedDay = self.currentDate;
    }

    else if (self.dateButtonTwo.tag ==1)
    {
        self.selectedDay= self.dayTwo;
    }

    else if (self.dateButtonThree.tag ==1)
    {
        self.selectedDay = self.dayThree;
    }

    else if (self.dateButtonFour.tag ==1)
    {
        self.selectedDay = self.dayFour;
    }

    else if (self.dateButtonFive.tag ==1)
    {
        self.selectedDay = self.dayFive;
    }

    else if (self.dateButtonSix.tag ==1)
    {
        self.selectedDay = self.daySix;
    }

    else if (self.dateButtonSeven.tag ==1)
    {
        self.selectedDay = self.daySeven;
    }


    if(self.passengerLabelOne.tag ==1)
    {
        ride.passengerCount = self.passengerLabelOne.text;
    }

    else if (self.passengerLabelTwo.tag ==1)
    {
        ride.passengerCount = self.passengerLabelTwo.text;
    }

    else if (self.passengerLabelThree.tag ==1)
    {
        ride.passengerCount = self.passengerLabelThree.text;
    }

    else if (self.passengerLabelFour.tag ==1)
    {
        ride.passengerCount = self.passengerLabelFour.text;
    }

    self.selectedTime = self.datePicker.date;

    NSString *dateSelectedString = [self.dayFormatter stringFromDate:self.selectedDay];
    NSString *timeSelectedString = [self.timeFormatter stringFromDate:self.selectedTime];


    NSString *newDate = [NSString stringWithFormat:@"%@ %@", dateSelectedString, timeSelectedString];


    NSDate *dateFromString = [self.parseFormatter dateFromString:newDate];

    ride.rideDateTime = dateFromString;


    [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
    {
         if (succeeded)

             [PushNotification subscribePassengerToRide:ride];

    }];

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

-(void)passengerLabelWasTapped:(PassengerLabel *)sender {
    id labels = @[self.passengerLabelOne, self.passengerLabelTwo, self.passengerLabelThree, self.passengerLabelFour];

    for (UILabel *label in labels) {
        label.tag = 0;
        label.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:173.0/255.0 blue:201.0/255.0 alpha:1.0];
    }

    sender.tag = 1;
    sender.backgroundColor = [UIColor colorWithRed:(45.0/255.0) green:(44.0/255.0) blue:(58.0/255.0) alpha:1];
    ;

}



-(void)keyboardWillShow:(NSNotification*)notification {


    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];

    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    keyboardFrameBeginRect = [self.view convertRect:keyboardFrameBeginRect fromView:nil];

    NSLog(@"%@", NSStringFromCGRect(keyboardFrameBeginRect));
    [UIView animateWithDuration:0.3f animations:^ {
        self.view.frame = CGRectMake(0, -(keyboardFrameBeginRect.size.height - 20), self.view.frame.size.width, self.view.frame.size.height);

        self.topConstraint.constant = (keyboardFrameBeginRect.size.height - 10);
        self.pickupTimeLabel.hidden = YES;

    }];
}
-(void)keyboardWillHide {
    // Animate the current view back to its original position
    [UIView animateWithDuration:0.3f animations:^ {

        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);

        self.topConstraint.constant = 17;
        self.pickupTimeLabel.hidden = NO;
    }];
}
@end








