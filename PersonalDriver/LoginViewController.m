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
                    [self signUpPFUserWithUberProfile];

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

-(void)signUpPFUserWithUberProfile
{
    [UberAPI getUserProfileWithToken:self.token completionHandler:^(UberProfile *profile) {

        PFUser *user = [PFUser user];

        user.username = profile.email;
        user.password = profile.promo_code;
        user.email = profile.email;
        //Save name
        NSString *name = [NSString stringWithFormat:@"%@ %@",profile.first_name, profile.last_name];
        user[@"name"] = name;
        //Save photo to Parse
//        NSURL *url = [NSURL URLWithString:profile.picture];
//        NSData *pictureData = [NSData dataWithContentsOfURL:url];
//        PFFile *imageFile = [PFFile fileWithName:@"ProfilePic.jpg" data:pictureData];
//        user[@"picture"] = imageFile;

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

    }];
    
}









@end
