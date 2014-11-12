//
//  Date.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/11/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "Date.h"

@implementation Date

-(IBAction)onTapped:(UITapGestureRecognizer *)sender{
    [self.delegate dateButtonWasTapped:self];
    NSLog(@"This date was touched");

}

@end
