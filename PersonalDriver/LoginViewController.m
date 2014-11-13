//
//  LoginViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "LoginViewController.h"
#import "UberKit.h"
#import "Token.h"
#import "UberAPI.h"
#import "User.h"

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

//- (IBAction)saveToken:(UIButton *)sender {
//    NSString *token = [Token getToken];
//    if(!token)//if there is no token in keychain, get the token and save it
//    {
//        NSLog(@"No token yo!");
//
//    } else
//    {
//        [Token setToken:token];
//        //Get the Profile info from UberAPI and save to KeyChain
//        if ([User currentUser] == nil) //if there is not a User create one
//        {
//            [self signUpUserWithUberProfile];
//            [self dismissViewControllerAnimated:YES completion:nil];
//
//        }else
//        {
//            [self dismissViewControllerAnimated:YES completion:nil];
//        }
//
//        NSLog(@"You've got a token");
//    }
//}

- (IBAction)eraseToken:(id)sender {

    [Token eraseToken];
}

- (IBAction)logoutCurrentUser:(id)sender {
    [User logOut];
    if ([User currentUser] == nil)
    {
        NSLog(@"You are logged out");
    }
}

- (IBAction)dismissModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)goToUberAPIDemo:(id)sender {
}

-(void)signUpUserWithUberProfile
{
    [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile) {

        User *user = [User new];

        user.username = profile.email;
        user.password = profile.promo_code;
        user.email = profile.email;

        NSString *name = [NSString stringWithFormat:@"%@ %@",profile.first_name, profile.last_name];
        user.name = name;
        //Save photo to Parse
        NSURL *url = [NSURL URLWithString:profile.picture];
        NSData *pictureData = [NSData dataWithContentsOfURL:url];
        PFFile *imageFile = [PFFile fileWithName:@"ProfilePic.jpg" data:pictureData];
        user.picture =imageFile;
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
