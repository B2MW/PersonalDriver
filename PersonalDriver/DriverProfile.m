//
//  DriverProfile.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/12/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "DriverProfile.h"

@implementation DriverProfile
@dynamic user;
@dynamic homeLocation;
@dynamic fareMix;
@dynamic fareMax;
@dynamic searchRadius;

+(void)load
{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"DriverProfile";
}
@end
