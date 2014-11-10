//
//  Ride.h
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "User.h"

@interface Ride : PFObject <PFSubclassing>
@property User *driver;
@property User *passenger;
@property NSString *passengerCount;
@property PFGeoPoint *pickupGeoPoint;
@property PFGeoPoint *dropoffGeoPoint;
@property NSDate *rideDateTime;
@property NSString *specialInstructions;
@property BOOL driverConfirmed;
@property BOOL driverEnRoute;
@property NSString *pickUpLocation;
@property NSString *destination;
@property NSNumber *fareEstimateMin;
@property NSNumber *fareEstimateMax;

@end
