//
//  ViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ViewController.h"
#import "Token.h"
#import <Parse/Parse.h>
#import "UberAPI.h"

@interface ViewController ()
@property NSString *token;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Get Keychain info
    self.token = [Token getToken];
    if (!self.token) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }else if (![PFUser currentUser])//Perform login if no current user
    {
        [self loginPFUserWithUberProfile];

    }else if ([[PFUser currentUser] objectForKey:@"isDriver"])//Check if they are a Driver
    {
        //[self performSegueWithIdentifier:@"showDriver" sender:self];
    }else if ([[PFUser currentUser] objectForKey:@"isDriver"] == NO)//Check if they are a passenger
    {
        //[self performSegueWithIdentifier:@"showPassenger" sender:self];
    }else
    {
        //do nothing.  Have the user select Driver or Passenger from current screen.
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.token = [Token getToken];
    if (!self.token) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }else if (![PFUser currentUser])//Perform login if no current user
    {
        [self loginPFUserWithUberProfile];

    }else if ([[PFUser currentUser] objectForKey:@"isDriver"])//Check if they are a Driver
    {
        //[self performSegueWithIdentifier:@"showDriver" sender:self];
    }else if ([[PFUser currentUser] objectForKey:@"isDriver"] == NO)//Check if they are a passenger
    {
        //[self performSegueWithIdentifier:@"showPassenger" sender:self];
    }else
    {
        //do nothing.  Have the user select Driver or Passenger from current screen.
    }
    

}
- (IBAction)onPassengerPressed:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    user[@"isDriver"] = @NO;
    [user saveInBackground];

}

- (IBAction)onDriverPressed:(UIButton *)sender {
    PFUser *user = [PFUser currentUser];
    user[@"isDriver"] = @YES;
    [user saveInBackground];
}



#pragma mark - Helper Methods

-(void)loginPFUserWithUberProfile {

    [UberAPI getUserProfileWithToken:self.token completionHandler:^(UberProfile *profile) {
        [PFUser logInWithUsername:profile.email password:profile.promo_code];
        NSLog(@"You are logged in");
    }];

}







@end
