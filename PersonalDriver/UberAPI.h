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

@interface UberAPI : NSObject

+ (void)getUberActivitiesWithToken:(NSString *)token completionHandler:(void(^)(NSMutableArray *))complete;

+ (void)getUserProfileWithToken:(NSString *)token completionHandler:(void(^)(UberProfile *))complete;

@end
