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

-(void)retrieveRideDistanceAndBearing:(Ride *)ride:(CLLocationManager *)locationManager:(void(^)(NSArray *))completionHandler
{
    NSMutableArray *distanceAndBearing = [NSMutableArray array];
    NSNumber *distance;
    NSNumber *bearing;
    NSString *direction;

    //find distance between pickup & dropoff GeoPoints
    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:ride.pickupGeoPoint.latitude longitude:ride.pickupGeoPoint.longitude];
    CLLocation *driverLocation = locationManager.location;
    distance = [NSNumber numberWithDouble:([pickupLocation distanceFromLocation:driverLocation] / 1609.34)];

    NSNumber *driverLat = [self convertDegreesToRadians:driverLocation.coordinate.latitude];
    NSNumber *driverLong = [self convertDegreesToRadians:driverLocation.coordinate.longitude];
    NSNumber *pickupLat = [self convertDegreesToRadians:pickupLocation.coordinate.latitude];
    NSNumber *pickupLong = [self convertDegreesToRadians:pickupLocation.coordinate.longitude];

    NSNumber *degree = [self convertRadiansToDegrees:(atan2(sin(pickupLong.doubleValue-driverLong.doubleValue)*cos(pickupLat.doubleValue), cos(driverLat.doubleValue)*sin(pickupLat.doubleValue)-sin(driverLat.doubleValue)*cos(pickupLat.doubleValue)*cos(pickupLong.doubleValue-driverLong.doubleValue)))];

    if (degree.doubleValue >= 0.0)
    {
        bearing = degree;
    }
    else
    {
        bearing = @(360.0 + degree.doubleValue);
    }

    direction = [self convertBearingToDirection:bearing];

    [distanceAndBearing arrayByAddingObject:distance];
    [distanceAndBearing arrayByAddingObject:bearing];
    [distanceAndBearing arrayByAddingObject:direction];
    NSLog(@"direction is %@", direction);
    NSLog(@"distance is %@ miles", distance);
    NSLog(@"bearing is %@ degrees", bearing);
}

-(NSNumber *)convertDegreesToRadians:(double)valueInDegrees
{
    NSNumber *radianValue = [NSNumber numberWithDouble:(M_PI * valueInDegrees / 180.0)];
    return radianValue;
}

-(NSNumber *)convertRadiansToDegrees:(double )valueInRadians
{
    NSNumber *degreeValue = [NSNumber numberWithDouble:(valueInRadians * 180.0 / M_PI)];
    return degreeValue;
}

-(NSString *)convertBearingToDirection:(NSNumber *)bearing
{
//    bearing = @(fabs(bearing.doubleValue));
    NSString *direction = [NSString new];
    if (bearing.doubleValue > 337.5 && bearing.doubleValue <= 360)
    {
        direction = @"N";
    }
    else if (bearing.doubleValue >= 0 && bearing.doubleValue <= 22.5)
    {
        direction = @"N";
    }
    else if (bearing.doubleValue > 22.5 && bearing.doubleValue <= 67.5)
    {
        direction = @"NE";
    }
    else if (bearing.doubleValue > 67.5 && bearing.doubleValue <= 112.5)
    {
        direction = @"E";
    }
    else if (bearing.doubleValue > 112.5 && bearing.doubleValue <= 157.5)
    {
        direction = @"SE";
    }
    else if (bearing.doubleValue > 157.5 && bearing.doubleValue <= 202.5)
    {
        direction = @"S";
    }
    else if (bearing.doubleValue > 202.5 && bearing.doubleValue <= 247.5)
    {
        direction = @"SW";
    }
    else if (bearing.doubleValue > 247.5 && bearing.doubleValue <= 292.5)
    {
        direction = @"W";
    }
    else if (bearing.doubleValue > 292.5 && bearing.doubleValue <= 337.5)
    {
        direction = @"NW";
    }
    return direction;
}


@end
