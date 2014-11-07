//
//  NewRideViewController.h
//  PersonalDriver
//
//  Created by Michael Maloof on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "UberPrice.h"

@interface NewRideViewController : UIViewController
@property PFGeoPoint *pickupGeopoint;
@property PFGeoPoint *destinationGeopoint;
@property NSString *pickupAddress;
@property NSString *destinationAddress;
@property UberPrice *price;

@end
