//
//  RideManager.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "RideManager.h"

@implementation RideManager

//-(void)getAvailableRides:
-(void)getAvailableRides:(void(^)(NSArray *))completionHandler
{
    PFQuery *queryAvailableRides = [Ride query];
    [queryAvailableRides whereKeyDoesNotExist:@"driver"];
    [queryAvailableRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects);
    }];
}

@end
