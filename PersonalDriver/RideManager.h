//
//  RideManager.h
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Ride.h"

@interface RideManager : NSObject
-(void)getAvailableRides:(void(^)(NSArray *))completionHandler;
-(void)getScheduledRides:(void(^)(NSArray *))complete;
-(NSString *)formatRideDate:(Ride *)ride;
-(NSString *)formatRideFareEstimate:(NSNumber *)fareEstimateMin fareEstimateMax:(NSNumber *)fareEstimateMax;
-(void)retrieveRideDistanceAndBearing:(Ride *)ride;
@end
