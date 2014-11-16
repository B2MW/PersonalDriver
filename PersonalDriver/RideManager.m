//
//  RideManager.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "RideManager.h"

@implementation RideManager

-(void)getAvailableRides:(CLLocationManager *)locationManager:(void(^)(NSArray *))completionHandler
{

    PFQuery *queryAvailableRides = [Ride query];
    queryAvailableRides.cachePolicy = kPFCachePolicyCacheThenNetwork;
    [queryAvailableRides whereKeyDoesNotExist:@"driver"];
    [queryAvailableRides includeKey:@"passenger"];
    [queryAvailableRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        for (Ride *ride in objects)
        {
            NSNumber *distance = 0;
            CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:ride.pickupGeoPoint.latitude longitude:ride.pickupGeoPoint.longitude];
            CLLocation *driverLocation = locationManager.location;
            distance = [NSNumber numberWithDouble:(round([pickupLocation distanceFromLocation:driverLocation] / 1609.34))];
//            ride.rideDateTime = [self convertDateToLocalTimeZone:ride.rideDateTime];
            NSLog(@"%@",ride.rideDateTime);
        }
        completionHandler(objects);
    }];
}

-(NSDate *)convertDateToLocalTimeZone:(NSDate *)serverRideDateTime
{
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:serverRideDateTime];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:serverRideDateTime];
    NSTimeInterval gmtInterval = currentGMTOffset - gmtOffset;
    NSDate *localRideDateTime = [[NSDate alloc] initWithTimeInterval:gmtInterval sinceDate:serverRideDateTime];

    NSLog(@"%@", serverRideDateTime);
    NSLog(@"%@", localRideDateTime);
    return localRideDateTime;
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
    [formatter setDateFormat:@"hh:mm a'"];
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
    distance = [NSNumber numberWithDouble:(round([pickupLocation distanceFromLocation:driverLocation] / 1609.34))];

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
    [distanceAndBearing addObject:distance];
    [distanceAndBearing addObject:direction];
    completionHandler(distanceAndBearing);
}

-(void)retrivedRideTripDistance:(Ride *)ride:(void(^)(NSNumber *))completionHandler
{
    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:ride.pickupGeoPoint.latitude longitude:ride.pickupGeoPoint.longitude];
    CLLocation *driverLocation = [[CLLocation alloc] initWithLatitude:ride.dropoffGeoPoint.latitude longitude:ride.dropoffGeoPoint.longitude];
    NSNumber *distance = [NSNumber numberWithDouble:(round([pickupLocation distanceFromLocation:driverLocation] / 1609.34))];
    completionHandler(distance);
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
        direction = @"North";
    }
    else if (bearing.doubleValue >= 0 && bearing.doubleValue <= 22.5)
    {
        direction = @"North";
    }
    else if (bearing.doubleValue > 22.5 && bearing.doubleValue <= 67.5)
    {
        direction = @"Northeast";
    }
    else if (bearing.doubleValue > 67.5 && bearing.doubleValue <= 112.5)
    {
        direction = @"East";
    }
    else if (bearing.doubleValue > 112.5 && bearing.doubleValue <= 157.5)
    {
        direction = @"Southeast";
    }
    else if (bearing.doubleValue > 157.5 && bearing.doubleValue <= 202.5)
    {
        direction = @"South";
    }
    else if (bearing.doubleValue > 202.5 && bearing.doubleValue <= 247.5)
    {
        direction = @"Southwest";
    }
    else if (bearing.doubleValue > 247.5 && bearing.doubleValue <= 292.5)
    {
        direction = @"West";
    }
    else if (bearing.doubleValue > 292.5 && bearing.doubleValue <= 337.5)
    {
        direction = @"Northwest";
    }
    return direction;
}


@end
