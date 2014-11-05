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

- (IBAction)saveUserToKeychain:(UIButton *)sender {

    self.token = [[UberKit sharedInstance] getStoredAuthToken];
    if(self.token)
    {
        [UberAPI getUserProfileWithToken:self.token completionHandler:^(UberProfile *profile) {
            [SSKeychain setPassword:self.token forService:@"personaldriver" account:profile.email];
            if ([PFUser currentUser] == nil) {
                PFUser *user = [PFUser user];
                NSString *name = [NSString stringWithFormat:@"%@ %@",profile.first_name, profile.last_name];
                user.username = name;
                user.password = profile.promo_code;
                user.email = profile.email;
//                UIImage* myImage = [UIImage imageWithData:
//                                    [NSData dataWithContentsOfURL:
//                                     [NSURL URLWithString:profile.picture]]];
                user[@"picture"] = profile.picture;

                // other fields can be set just like with PFObject

                [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        //return to RootViewController
                    } else {
                        NSString *errorString = [error userInfo][@"error"];
                        NSLog(@"Error: %@",errorString);
                        //TODO: Create an alertview message
                    }
                }];
            }else {
                //return to RootViewController
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
