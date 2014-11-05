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
@property PFUser *user;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.user = [PFUser currentUser];
    if (self.user) {
        NSLog(@"%@ is logged in",[self.user objectForKey:@"name"]);
    }else
    {
        NSLog(@"No user logged in");
    }
    //Get Keychain info
    NSString *token = [Token getToken];
    if (!token) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }else if (!self.user)
    {

    }else if ([self.user objectForKey:@"isDriver"])
    {
        //log into Driver Screen
    }else if ([self.user objectForKey:@"isDriver"] == NO)
    {
         //log into Passenger Screen
    }else
    {
        //do nothing.  Have the user select Driver or Passenger from current screen.
    }
}

#pragma marker - Helper Methods

-(void)loginUserToParse
{
    //get User Profile from Uber
    [UberAPI getUserProfileWithToken:<#(NSString *)#> completionHandler:<#^(UberProfile *)complete#>]

}





@end
