//
//  LoginViewController.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "LoginViewController.h"
#import "UberKit.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}



- (IBAction)onLoginButtonPressed:(UIButton *)sender {

    [[UberKit sharedInstance] setClientID:@"pVt5YyjIQIB5gcZHzz_SgyG2Z6lcJRWT"]; //Add your client id
    [[UberKit sharedInstance] setClientSecret:@"7pJruVcbjQQPZNHRAscuArs2I3Ip3Y-MvVDj_Sw5"]; //Add your client secret
    [[UberKit sharedInstance] setRedirectURL:@"personaldriver://localhost"]; //Add your redirect url
    [[UberKit sharedInstance] setApplicationName:@"Personal Driver"]; //Add your application name
    [[UberKit sharedInstance] startLogin];
}




@end
