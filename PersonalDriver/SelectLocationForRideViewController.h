//
//  SelectLocationForRideViewController.h
//  PersonalDriver
//
//  Created by Michael Maloof on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>


@interface SelectLocationForRideViewController : ViewController
@property PFGeoPoint *pickupGeopoint;
@property PFGeoPoint *destinationGeopoint;
@property NSString *pickupAddress;
@property NSString *destinationAddress;


@end
