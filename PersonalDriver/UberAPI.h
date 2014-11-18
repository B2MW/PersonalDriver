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

@property (strong, nonatomic) NSString *serverToken;
@property (strong, nonatomic) NSString *clientID;
@property (strong, nonatomic) NSString *clientSecret;
@property (strong, nonatomic) NSString *redirectURL;
@property (strong, nonatomic) NSString *applicationName;

+ (void)getUberActivitiesWithCompletionHandler:(void(^)(NSMutableArray *))complete;

+ (void)getUserProfileWithCompletionHandler:(void(^)(UberProfile *, NSError *))complete;

+(void)getPriceEstimateFromPickup:(CLLocation *)pickup toDestination:(CLLocation *)destination completionHandler:(void(^)(UberPrice *))complete;

@end
