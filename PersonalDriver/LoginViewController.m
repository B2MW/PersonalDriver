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
    NSLog(@"viewDidAppear");
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");

}

- (IBAction)onLoginButtonPressed:(UIButton *)sender {

    [[UberKit sharedInstance] startLogin];
}



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
    [UberAPI getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error) {

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
