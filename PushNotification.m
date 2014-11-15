//
//  PushNotification.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/13/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "PushNotification.h"


@implementation PushNotification


#pragma mark - Subscribe Methods
+(void)subscribePassengerToRide:(Ride *)ride
{

    // subscribe the passenger to the ride channel
    PFQuery *rideQuery = [PFQuery queryWithClassName:@"Ride"];
    //get all the rides from the passenger and subscribe to the most recent
    [rideQuery whereKey:@"passenger" equalTo:[User currentUser]];
    [rideQuery orderByDescending:@"createdAt"];
    [rideQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        Ride *newRide = [objects objectAtIndex:0];
        //"P" added because channel must start with a letter
        NSString *channelName = [NSString stringWithFormat:@"P%@",newRide.objectId];
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:channelName forKey:@"channels"];
        [currentInstallation saveInBackground];

    }];

}

+(void)subscribeDriverToRide:(Ride *)ride
{
    NSString *channelName = [NSString stringWithFormat:@"D%@",ride.objectId];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:channelName forKey:@"channels"];
    [currentInstallation saveInBackground];
}

#pragma mark - Push Methods


+(void)sendPassengerEnrouteNotificationForRide:(Ride *)ride
{

    PFPush *push = [[PFPush alloc] init];
    NSString *channelName = [NSString stringWithFormat:@"P%@",ride.objectId];
    [push setChannel:channelName];
    [push setMessage:@"Your driver is enroute and will arrive shortly."];
    [push expireAtDate:ride.rideDateTime];
    [push sendPushInBackground];

}

+(void)sendPassengerRideConfirmed:(Ride *)ride
{
    PFPush *push = [[PFPush alloc] init];
    NSString *channelName = [NSString stringWithFormat:@"P%@",ride.objectId];
    [push setChannel:channelName];
    [push setMessage:@"Your ride has been scheduled"];
        [push expireAtDate:ride.rideDateTime];
    [push sendPushInBackground];

}

+(void)sendPassengerDriverArrived:(Ride *)ride
{
    PFPush *push = [[PFPush alloc] init];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"Your driver has arrived.  Please launch Uber and request the ride", @"alert",
                          @"Increment", @"badge",
                          //@"cheering.caf", @"sound", TODO: Add Custom Sound
                          nil];

    NSString *channelName = [NSString stringWithFormat:@"P%@",ride.objectId];
    [push setChannel:channelName];
    [push setData:data];
    [push expireAtDate:ride.rideDateTime];
    [push sendPushInBackground];
}

#pragma mark - Local Notifications

+(void)sendDriverReminderForRide:(Ride *)ride
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *alertTime = [ride.rideDateTime dateByAddingTimeInterval:-60*15];
    localNotification.fireDate = alertTime;
    localNotification.alertAction = @"Ride Scheduled";
    localNotification.alertBody = [NSString stringWithFormat:@"Pickup at %@",ride.rideDateTime];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;

    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


@end
