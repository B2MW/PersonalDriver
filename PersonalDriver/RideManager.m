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
    queryAvailableRides.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [queryAvailableRides whereKeyDoesNotExist:@"driver"];
    [queryAvailableRides includeKey:@"passenger"];
    [queryAvailableRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects);
    }];
}

-(void)getScheduledRides:(void(^)(NSArray *))complete
{
    User *currentUser = [User currentUser];
    PFQuery *queryScheduledRides= [Ride query];
    queryScheduledRides.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [queryScheduledRides whereKey:@"driver" equalTo:currentUser];
    [queryScheduledRides includeKey:@"passenger"];
    [queryScheduledRides includeKey:@"driver"];
    [queryScheduledRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];

}

-(NSString *)formatRideDate:(Ride *)ride
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE' at 'h:mm a"];
    NSString *formattedRideDate = [formatter stringFromDate:ride.rideDateTime];
    return formattedRideDate;
}

-(NSString *)formatRideFareEstimate:(NSNumber *)fareEstimateMin fareEstimateMax:(NSNumber *)fareEstimateMax
{
    NSString *formattedRideEstimate = [NSString stringWithFormat:@"$%@-%@",fareEstimateMin.stringValue, fareEstimateMax.stringValue];
    return formattedRideEstimate;
}

-(void)retrieveGeoPointAddress:(PFGeoPoint *)rideGeoPoint completionHandler:(void(^)(NSString *))completionHandler
{
    CLGeocoder *geocode = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:rideGeoPoint.latitude longitude:rideGeoPoint.longitude];

    [geocode reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error)
     {
         CLPlacemark *placemark = placemarks.firstObject;
         NSString *address = [NSString stringWithFormat:@"%@ %@ \n%@",
                              placemark.subThoroughfare,
                              placemark.thoroughfare,
                              placemark.locality];

         completionHandler(address);
     }];
}

-(void)retrieveRideDistanceAndBearing:(Ride *)ride
{

}

@end
