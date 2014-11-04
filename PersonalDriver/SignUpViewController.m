//
//  LoginViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "SignupViewController.h"
#import "UberKit.h"

@interface SignupViewController ()<CLLocationManagerDelegate>
@property NSArray *timeForArrival;
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;

@end

@implementation SignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    self.userLocation = self.locationManager.location;

    UberKit *uberKit = [[UberKit alloc] initWithServerToken:@"5VvEv7zOK6lEmQf0qRjPBA8ie7P8IIHb0X8pAF2r"];

    [uberKit getTimeForProductArrivalWithLocation:self.userLocation withCompletionHandler:^(NSArray *resultsArray, NSURLResponse *response, NSError *error) {
        self.timeForArrival = resultsArray;
    }];
}




@end
