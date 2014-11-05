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
#import "Token.h"
#import "UberAPI.h"
#import <Parse/Parse.h>

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

- (IBAction)saveToken:(UIButton *)sender {
    self.token = [Token getToken];
    if(!self.token)//if there is no token in keychain, get the token and save it
    {
        self.token = [[UberKit sharedInstance] getStoredAuthToken];
        if (self.token) // Check to make sure a token was retrieved from Oauth
        {
            //Get the Profile info from UberAPI and save to KeyChain
            [UberAPI getUserProfileWithToken:self.token completionHandler:^(UberProfile *profile) {
                [SSKeychain setPassword:self.token forService:@"personaldriver" account:profile.email];
                if ([PFUser currentUser] == nil) //if there is not a PFUser create one
                {
                    [self createPFUserWithProfile:profile];

                }else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }];
        } else {
            NSLog(@"No token yo!");
        }

    }
    else
    {
        NSLog(@"You've got a token");
    }

}

- (IBAction)eraseToken:(id)sender {

    NSString *service = @"personaldriver";
    NSArray *keychainArray = [SSKeychain accountsForService:service];
    NSDictionary *keychainDict = [keychainArray firstObject];
    NSString *account = [keychainDict objectForKey:@"acct"];
    [SSKeychain deletePasswordForService:service account:account];
    if ([Token getToken] == nil) {
        NSLog(@"Token deleted");
    }
}

- (IBAction)logoutCurrentUser:(id)sender {
    [PFUser logOut];
    if ([PFUser currentUser] == nil)
    {
        NSLog(@"You are logged out");
    }
}

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (IBAction)goToUberAPIDemo:(id)sender {
}



#pragma mark - Helper Methods

-(void)createPFUserWithProfile:(UberProfile *)profile  {
    PFUser *user = [PFUser user];
    NSString *name = [NSString stringWithFormat:@"%@ %@",profile.first_name, profile.last_name];
    user.username = name;
    user.password = profile.promo_code;
    user.email = profile.email;
    //TODO: Need to save image file to Parse
    //                UIImage* myImage = [UIImage imageWithData:
    //                                    [NSData dataWithContentsOfURL:
    //                                     [NSURL URLWithString:profile.picture]]];
    user[@"picture"] = profile.picture;
    //Save to Parse
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Successfully created User");
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            NSString *errorString = [error userInfo][@"error"];
            NSLog(@"Error: %@",errorString);
            //TODO: Create an alertview message
        }
    }];

}





@end
