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
@property (weak, nonatomic) IBOutlet UIButton *passengerOrDriverButton;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *settings = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
    [settings addTarget:self action:@selector(onBackButtonTapped:) forControlEvents:UIControlEventTouchDown];
    UIBarButtonItem *item =[[UIBarButtonItem alloc]initWithCustomView:settings];
    self.navigationItem.leftBarButtonItem = item;

    self.title = @"Settings";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)onLogoutButtonTapped:(id)sender {
    [Token eraseToken];
}

-(void)onBackButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onPassengerOrDriverButtonTapped:(id)sender {
}

@end
