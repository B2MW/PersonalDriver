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

@property NSString *token;


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

    self.token = [[UberKit sharedInstance] getStoredAuthToken];
    if(self.token)
    {

        [[UberKit sharedInstance] getUserProfileWithCompletionHandler:^(UberProfile *profile, NSURLResponse *response, NSError *error)
         {
             if(!error)
             {
                 [SSKeychain setPassword:self.token forService:@"personaldriver" account:profile.email];
                 NSLog(@"User's full name %@ %@", profile.first_name, profile.last_name);
                 NSLog(@"User's email: %@", profile.email);
                 NSLog(@"Token: %@", self.token);
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

- (IBAction)test:(id)sender {
    
}






@end
