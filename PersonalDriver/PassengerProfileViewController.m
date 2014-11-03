//
//  UserProfileViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "PassengerProfileViewController.h"

@interface PassengerProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *profileEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *profilePhoneLabel;


@end

@implementation PassengerProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onSettingsButtonTapped:(id)sender {
}

- (IBAction)onLogoutButtonTapped:(id)sender {
}



@end
