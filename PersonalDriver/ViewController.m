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

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //Get Keychain info
//    NSString *token = [Token getToken];
//
//    if (!token) {
//        //perform login for Oauth
//    }else if (![PFUser currentUser])
//    {
//        //Use the token to get profile info and login
//    }else if ([PFUser currentUser].isDriver)
//    {
//        //log into Driver Screen
//    }else if ([PFUser currentUser].isDriver == NO)
//    {
//         //log into Passenger Screen
//    }else
//    {
//        //do nothing.  Have the user select Driver or Passenger from current screen.
//    }
}



@end
