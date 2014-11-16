//
//  RideManager.h
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "Ride.h"
#import "User.h"

@interface RideManager : NSObject
-(void)getAvailableRides:(CLLocationManager *)locationManager:(void(^)(NSArray *))completionHandler;
-(void)getScheduledRides:(void(^)(NSArray *))complete;
-(NSString *)formatRideDate:(Ride *)ride;
-(NSString *)formatRideFareEstimate:(NSNumber *)fareEstimateMin fareEstimateMax:(NSNumber *)fareEstimateMax;
-(void)retrieveGeoPointAddress:(PFGeoPoint *)rideGeoPoint completionHandler:(void(^)(NSString *))completionHandler;
-(void)retrieveRideDistanceAndBearing:(Ride *)ride:(CLLocationManager *)locationManager:(void(^)(NSArray *))completionHandler;
-(void)retrivedRideTripDistance:(Ride *)ride:(void(^)(NSNumber *))completionHandler;
@end
