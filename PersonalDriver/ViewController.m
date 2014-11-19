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
      [self.navigationItem setHidesBackButton:YES animated:YES];

}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];

    //check to make sure the token is still valid and they can use the UberAPI
    NSString *token = [Token getToken];
    if (!token)
    {
        NSLog(@"You have no token");
        [self loginAlert];

    }else

    {
        [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error) {
            if (!error) {
                [self loginOrSignUpUserWithUberProfile];
            }else {
                [Token eraseToken];
                [self loginAlert];
            }


        }];
    }
}

-(void)viewDidDisappear:(BOOL)animated {

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Login"]) {

        [[UberKit sharedInstance] startLogin];
    }
    if ([title isEqualToString:@"Efrase Token"]) {
        [self eraseToken];
    }

    if ([title isEqualToString:@"Logout User"]) {
        [self logoutCurrentUser];
    }
}


- (IBAction)onPassengerPressed:(UIButton *)sender {
//    [self loginOrSignUpUserWithUberProfile];
//    self.currentUser.isDriver = NO;
    [self.currentUser saveInBackground];
    [self performSegueWithIdentifier:@"showPassenger" sender:self];
    NSLog(@"You are a Passenger");

}

- (IBAction)onDriverPressed:(UIButton *)sender {
//    [self loginOrSignUpUserWithUberProfile];
//    self.currentUser.isDriver = YES;
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
         [queryUsers whereKey:@"username" containsString:self.profile.email];
         //        [queryUsers whereKey:@"username" equalTo:self.profile.email];
         [queryUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
          {
              if (objects == nil)
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
                      self.currentUser = [User currentUser];
//                      if (self.currentUser.isDriver == YES)//Check if they are a Driver
//                      {
//                          [self associateUserToDeviceForPush];
                          //                        [self performSegueWithIdentifier:@"showDriver" sender:self];
//                      }else if (self.currentUser.isDriver == NO)//Check if they are a passenger
//                      {
                          [self associateUserToDeviceForPush];
                          //                        [self performSegueWithIdentifier:@"showPassenger" sender:self];
//                      }
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
        NSLog(@"Estimate for Average Fare: $%@",price.avgEstimateWithoutSurge);
    }];
    
}

- (void)queryProfile {
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

- (void)loginAlert {
    UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Please Login to Uber" message:@"You will be redirected to Uber" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Login", nil];
    loginAlert.delegate = self;
    [loginAlert show];
}






@end
