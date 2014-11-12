//
//  DriverProfile.h
//  PersonalDriver
//
//  Created by Bradley Walker on 11/12/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface DriverProfile : PFObject <PFSubclassing>
@property PFUser *user;
@property PFGeoPoint *homeLocation;
@property NSNumber *fareMix;
@property NSNumber *fareMax;
@property NSNumber *searchRadius;
@end
