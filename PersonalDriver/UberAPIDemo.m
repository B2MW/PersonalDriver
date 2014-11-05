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

@interface UberAPIDemo ()

@property NSDictionary *keychainDict;
@property NSString *token;
@property NSArray *activities;


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




@end
