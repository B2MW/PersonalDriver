//
//  PassengerLabel.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/12/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "PassengerLabel.h"

@implementation PassengerLabel

-(IBAction)onTapped:(UITapGestureRecognizer *)sender{
    [self.delegate passengerLabelWasTapped:self];
    NSLog(@"who am i? I am : %@",self.text);
}



@end
