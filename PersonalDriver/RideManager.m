//
//  RideManager.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "RideManager.h"

@implementation RideManager

-(void)getAvailableRides:(void(^)(NSArray *))completionHandler
{
    PFQuery *queryAvailableRides = [Ride query];
    [queryAvailableRides whereKeyDoesNotExist:@"driver"];
    [queryAvailableRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects);
    }];
}

-(NSString *)formatRideDate:(Ride *)ride
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE' at 'h:mm a"];
    NSString *formattedRideDate = [formatter stringFromDate:ride.rideDateTime];
    return formattedRideDate;
}

-(NSString *)formatRideFareEstimate:(NSNumber *)fareEstimateMin:(NSNumber *)fareEstimateMax
{
    NSString *formattedRideEstimate = [NSString stringWithFormat:@"$%@-%@",fareEstimateMin.stringValue, fareEstimateMax.stringValue];
    return formattedRideEstimate;
}

@end
