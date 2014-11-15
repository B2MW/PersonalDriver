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
#import "UberKit.h"

@interface ViewController () <UIAlertViewDelegate>
@property NSString *token;
@property User *currentUser;
@property UberProfile *profile;


@end

@implementation ViewController

- (void)viewDidLoad {

    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    //check to make sure the token is still valid and they can use the UberAPI
    NSString *token = [Token getToken];
    if (!token)
    {
        NSLog(@"You have no token");
        UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Unable to Login" message:@"Please login to Uber" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Login", nil];
        loginAlert.delegate = self;
        [loginAlert show];

    }else

    {
        [self fareEstimate];
        [self queryUser];

        [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error) {
            self.profile = profile;

            if (error)
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

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Login"]) {

        [[UberKit sharedInstance] startLogin];
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

    [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error)
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

                NSString *name = [NSString stringWithFormat:@"%@ %@",profile.first_name, profile.last_name];
                user.name = name;
                //Save photo to Parse
                NSURL *url = [NSURL URLWithString:profile.picture];
                NSData *pictureData = [NSData dataWithContentsOfURL:url];
                PFFile *imageFile = [PFFile fileWithName:@"ProfilePic.jpg" data:pictureData];
                user.picture =imageFile;

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

- (void)eraseToken {

    [Token eraseToken];
}

- (void)logoutCurrentUser {
    [User logOut];
    if ([User currentUser] == nil)
    {
        NSLog(@"You are logged out");
    }
}

- (void)fareEstimate {

    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:37.7833 longitude:-122.4167];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:37.9 longitude:-122.43];

    [UberAPI getPriceEstimateFromPickup:pickupLocation toDestination:destinationLocation completionHandler:^(UberPrice *price) {
        NSLog(@"Estimate for Average Fare: $%d",price.avgEstimateWithoutSurge);
    }];
    
}

- (void)queryUser {
    [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error) {
        NSLog(@"Name:%@ %@",profile.first_name,profile.last_name);
        NSLog(@"Email:%@",profile.email);
        NSLog(@"Picture: %@", profile.picture);
        NSLog(@"Promo Code:%@",profile.promo_code);
    }];

}

- (void)queryActivity {
    [UberAPI getUberActivitiesWithCompletionHandler:^(NSMutableArray *activities) {
        NSLog(@"Activities:%@",activities);
    }];

}






@end
