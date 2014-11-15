//
//  PushNotification.h
//  PersonalDriver
//
//  Created by pmccarthy on 11/13/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ride.h"
#import <Parse/Parse.h>
#import "User.h"

@interface PushNotification : NSObject

+(void)subscribePassengerToRide:(Ride *)ride;
+(void)subscribeDriverToRide:(Ride *)ride;

+(void)sendPassengerEnrouteNotificationForRide:(Ride *)ride;
+(void)sendPassengerRideConfirmed:(Ride *)ride;

+(void)sendDriverReminderForRide:(Ride *)ride;

@end
