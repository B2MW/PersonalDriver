//
//  Ride.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "Ride.h"

@implementation Ride
@dynamic driver;
@dynamic passenger;
@dynamic passengerCount;
@dynamic pickupGeoPoint;
@dynamic dropoffGeoPoint;
@dynamic rideDateTime;
@dynamic specialInstructions;
@dynamic driverConfirmed;
@dynamic driverEnRoute;

+(void)load
{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"Ride";
}

@end
