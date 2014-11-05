//
//  LoginViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "LoginViewController.h"
#import "UberKit.h"
#import <SSKeychain.h>

@interface LoginViewController ()


@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}


- (IBAction)onLoginButtonPressed:(UIButton *)sender {

    
    [[UberKit sharedInstance] startLogin];

}

- (IBAction)saveUserToKeychain:(UIButton *)sender {

    NSString *authToken = [[UberKit sharedInstance] getStoredAuthToken];
    if(authToken)
    {

        [[UberKit sharedInstance] getUserProfileWithCompletionHandler:^(UberProfile *profile, NSURLResponse *response, NSError *error)
         {
             if(!error)
             {
                 [SSKeychain setPassword:authToken forService:@"Personal Driver" account:profile.email];
                 NSLog(@"User's full name %@ %@", profile.first_name, profile.last_name);
                 NSLog(@"User's email: %@", profile.email);
                 NSLog(@"Token: %@", authToken);
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







@end
