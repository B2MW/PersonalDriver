//
//  SettingsViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/16/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "SettingsViewController.h"
#import "Token.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)onLogoutButtonTapped:(id)sender {
    [Token eraseToken];
}


@end
