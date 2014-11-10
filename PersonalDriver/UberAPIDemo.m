//
//  TestViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "UberAPIDemo.h"
#import "Token.h"
#import "UberAPI.h"
#import "UberProfile.h"
#import "UberActivity.h"
#import "UberPrice.h"
#import "UberKit.h"

@interface UberAPIDemo ()

@property NSDictionary *keychainDict;
@property NSArray *activities;
@property NSString *token;


@end

@implementation UberAPIDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.token = [Token getToken];
    NSLog(@"Token:%@",self.token);

}
- (IBAction)queryUser:(id)sender {
    [UberAPI getUserProfileWithToken:self.token completionHandler:^(UberProfile *profile) {
        NSLog(@"Name:%@ %@",profile.first_name,profile.last_name);
        NSLog(@"Email:%@",profile.email);
        NSLog(@"Picture: %@", profile.picture);
        NSLog(@"Promo Code:%@",profile.promo_code);
    }];
    

}

- (IBAction)queryActivity:(id)sender {
    [UberAPI getUberActivitiesWithToken:self.token completionHandler:^(NSMutableArray *activities) {
        self.activities = [NSArray arrayWithArray:activities];
        NSLog(@"Activities:%@",self.activities);
    }];

}
- (IBAction)backToLogin:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)fareEstimate:(id)sender {

    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:37.7833 longitude:-122.4167];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:37.9 longitude:-122.43];

    [UberAPI getPriceEstimateWithToken:self.token fromPickup:pickupLocation toDestination:destinationLocation completionHandler:^(UberPrice *price) {
        NSLog(@"Estimate for Average Fare: $%d",price.avgEstimateWithoutSurge);
    }];

}





@end
