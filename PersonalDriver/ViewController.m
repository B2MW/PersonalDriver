//
//  ViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ViewController.h"
#import "Token.h"
#import "UberAPI.h"
#import "User.h"

@interface ViewController ()
@property NSString *token;
@property User *currentUser;
@property UberProfile *profile;

@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    NSString *token = [Token getToken];
    if (!token) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }else
    {
        //check to make sure the token is still valid and they can use the UberAPI

        [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile) {
            self.profile = profile;

            if (!self.profile.first_name)
            {
                [self performSegueWithIdentifier:@"showLogin" sender:self];
            }else if (![User currentUser])//Perform login if no current user
            {
                [self loginUserWithUberProfile];

            }else if (self.currentUser.isDriver == YES)//Check if they are a Driver
            {
                [self associateUserToDeviceForPush];
                [self performSegueWithIdentifier:@"showDriver" sender:self];
            }else if (self.currentUser.isDriver == NO)//Check if they are a passenger
            {
                [self associateUserToDeviceForPush];
                [self performSegueWithIdentifier:@"showPassenger" sender:self];
            }else
            {
                //do nothing.  Have the user select Driver or Passenger from current screen.
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    NSString *token = [Token getToken];
    if (!token) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }else
    {
        //check to make sure the token is still valid and they can use the UberAPI

        [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile) {
            self.profile = profile;

            if (!self.profile.first_name)
            {
                [self performSegueWithIdentifier:@"showLogin" sender:self];
            }else if (![User currentUser])//Perform login if no current user
            {
                [self loginUserWithUberProfile];

            }else if (self.currentUser.isDriver == YES)//Check if they are a Driver
            {
                [self associateUserToDeviceForPush];
            //    [self performSegueWithIdentifier:@"showDriver" sender:self];
            }else if (self.currentUser.isDriver == NO)//Check if they are a passenger
            {
                [self associateUserToDeviceForPush];
             //   [self performSegueWithIdentifier:@"showPassenger" sender:self];
            }else
            {
                //do nothing.  Have the user select Driver or Passenger from current screen.
            }
        }];
    }
}



- (IBAction)onPassengerPressed:(UIButton *)sender {

    self.currentUser.isDriver = NO;
    [self.currentUser saveInBackground];
    [self performSegueWithIdentifier:@"showPassenger" sender:self];
    NSLog(@"You are a Passenger");

}

- (IBAction)onDriverPressed:(UIButton *)sender {
    self.currentUser.isDriver = YES;
    [self.currentUser saveInBackground];
    [self performSegueWithIdentifier:@"showDriver" sender:self];
    NSLog(@"You are a Driver");
}

- (IBAction)login:(id)sender {
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}


#pragma mark - Helper Methods

-(void)loginUserWithUberProfile {

    [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile) {
        [User logInWithUsername:profile.email password:profile.promo_code];
        NSLog(@"You are logged in");
    }];

}



-(void)associateUserToDeviceForPush
{
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [User currentUser];
    [installation saveInBackground];
}




@end
