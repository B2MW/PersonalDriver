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
                [self loginOrSignUpUserWithUberProfile];

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
                [self loginOrSignUpUserWithUberProfile];

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

-(void)loginOrSignUpUserWithUberProfile
{

    [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile)
    {
        self.profile = profile;
        PFQuery *queryUsers = [User query];
        [queryUsers whereKey:@"username" equalTo:self.profile.email];
        [queryUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
        {
            if (objects.count == 0)
            {
                User *user = [User new];

                user.username = self.profile.email;
                user.password = self.profile.promo_code;
                user.email = self.profile.email;
                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        NSLog(@"User account created");
                    } else {
                        NSLog(@"%@",[error description]);
                    }
                }];
            }else
            {
                NSError *error;
                [User logInWithUsername:self.profile.email password:self.profile.promo_code error:&error];
                if (error)
                {
                    NSLog(@"%@", [error description]);
                }else
                {
                    NSLog(@"Logged in successfully");
                }
            }
        }];

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
