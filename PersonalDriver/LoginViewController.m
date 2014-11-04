//
//  LoginViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "LoginViewController.h"
#import "UberKit.h"

@interface LoginViewController ()<CLLocationManagerDelegate>
@property CLLocationManager *locationManager;
@property CLLocation *userLocation;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{

    [self.locationManager startUpdatingLocation];
    self.userLocation = [[CLLocation alloc]init];
    self.userLocation = self.locationManager.location;

    UberKit *uberKit = [[UberKit alloc] initWithServerToken:@"5VvEv7zOK6lEmQf0qRjPBA8ie7P8IIHb0X8pAF2r"];


    [uberKit getTimeForProductArrivalWithLocation:self.userLocation withCompletionHandler:^(NSArray *resultsArray, NSURLResponse *response, NSError *error)
     {
         if (!error) {
             UberTime *timeEstimate = [[UberTime alloc]init];
             timeEstimate = [resultsArray firstObject];
             NSLog(@"%f",timeEstimate.estimate);
         } else
         {
             NSLog(@"Error:%@",[error description]);
         }

     }];

}


- (IBAction)onLoginButtonPressed:(UIButton *)sender {

    [[UberKit sharedInstance] setClientID:@"pVt5YyjIQIB5gcZHzz_SgyG2Z6lcJRWT"]; //Add your client id
    [[UberKit sharedInstance] setClientSecret:@"7pJruVcbjQQPZNHRAscuArs2I3Ip3Y-MvVDj_Sw5"]; //Add your client secret
    [[UberKit sharedInstance] setRedirectURL:@"personaldriver://localhost"]; //Add your redirect url
    [[UberKit sharedInstance] setApplicationName:@"Personal Driver"]; //Add your application name
    [[UberKit sharedInstance] startLogin];
}




@end
