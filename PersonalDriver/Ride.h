//
//  Ride.h
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Ride : PFObject <PFSubclassing>
@property PFUser *driver;
@property PFUser *passenger;
@property NSString *passengerCount;
@property PFGeoPoint *pickupGeoPoint;
@property PFGeoPoint *dropoffGeoPoint;
@property NSDate *rideDateTime;
@property NSString *specialInstructions;
@property BOOL *driverConfirmed;
@property BOOL *driverEnRoute;
@property NSString *pickUpLocation;
@property NSString *destination;

@end
