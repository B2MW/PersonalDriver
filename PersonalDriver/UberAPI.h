//
//  UberAPI.h
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UberActivity.h"
#import "UberProfile.h"
#import "UberPrice.h"
#import <CoreLocation/CoreLocation.h>


@interface UberAPI : NSObject

+ (void)getUberActivitiesWithToken:(NSString *)token completionHandler:(void(^)(NSMutableArray *))complete;

+ (void)getUserProfileWithToken:(NSString *)token completionHandler:(void(^)(UberProfile *))complete;

+ (void)getPriceEstimateWithToken:(NSString *)token fromPickup:(CLLocation *)pickup toDestination:(CLLocation *)destination completionHandler:(void(^)(UberPrice *))complete;

@end
