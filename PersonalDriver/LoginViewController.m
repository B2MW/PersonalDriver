//
//  LoginViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "LoginViewController.h"
#import "UberKit.h"
#import <Parse/Parse.h>

@interface LoginViewController ()
@property UberProfile *uberProfile;
@property UberActivity *uberActivity;

 

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performActionsWithToken) name:UBER_ACCESS_TOKEN_AVAILABLE object:nil];

}


- (IBAction)onLoginButtonPressed:(UIButton *)sender {

    [[UberKit sharedInstance] setClientID:@"pVt5YyjIQIB5gcZHzz_SgyG2Z6lcJRWT"]; //Add your client id
    [[UberKit sharedInstance] setClientSecret:@"7pJruVcbjQQPZNHRAscuArs2I3Ip3Y-MvVDj_Sw5"]; //Add your client secret
    [[UberKit sharedInstance] setRedirectURL:@"personaldriver://localhost"]; //Add your redirect url
    [[UberKit sharedInstance] setApplicationName:@"Personal Driver"]; //Add your application name
    [[UberKit sharedInstance] startLogin];

}

- (IBAction)getUserActivityPressed:(UIButton *)sender {

    NSString *authToken = [[UberKit sharedInstance] getStoredAuthToken];
    if(authToken)
    {

        [[UberKit sharedInstance] getUserProfileWithCompletionHandler:^(UberProfile *profile, NSURLResponse *response, NSError *error)
         {
             if(!error)
             {
                 [self createAccountwithUser:profile.email password:[[UberKit sharedInstance] getStoredAuthToken] email:profile.email];
                 NSLog(@"User's full name %@ %@", profile.first_name, profile.last_name);
                 NSLog(@"User's email: %@", profile.email);
                 NSLog(@"Profile picture: %@", profile.picture);
             }
             else
             {
                 NSLog(@"Error %@", error);
             }
         }];
    }
    else
    {
        NSLog(@"No auth token yo, try again");
    }

}

- (void)createAccountwithUser:(NSString *)newUser password:(NSString *)password email:(NSString *)email {
    PFUser *user = [PFUser user];
    user.username = newUser;
    user.password = password;
    user.email = email;

    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Created New User");
        } else {
            NSLog(@"Error Saving User");
        }
    }];
}



@end
