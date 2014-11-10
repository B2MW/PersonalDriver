//
//  UberAPI.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "UberAPI.h"



@implementation UberAPI

+ (void)getUberActivitiesWithToken:(NSString *)token completionHandler:(void(^)(NSMutableArray *))complete
{
    //GET /v1.1/history

    NSString *urlString = [NSString stringWithFormat:@"https://api.uber.com/v1.1/history?access_token=%@&scope=history_lite", token];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (!error)
        {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSMutableArray *history = [NSMutableArray new];
            history = [results objectForKey:@"history"];
            NSMutableArray *activities = [NSMutableArray new];
            for (NSDictionary *activityDict in history) {
                UberActivity *activity = [[UberActivity alloc]initWithDictionary:activityDict];
                [activities addObject:activity];
            }
            complete(activities);
        }else
        {
            NSLog(@"Error:%@",[error description]);
        }
    }];
}

+ (void)getUserProfileWithToken:(NSString *)token completionHandler:(void(^)(UberProfile *))complete
{
    //GET /v1/me

    NSString *urlString = [NSString stringWithFormat:@"https://api.uber.com/v1/me?access_token=%@", token];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (!error) {
            NSDictionary *profile = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            UberProfile *uberProfile = [[UberProfile alloc]initWithDictionary:profile];
            complete(uberProfile);
        } else
        {
            NSLog(@"Error:%@",[error description]);
        }

    }];
}

+(void)getPriceEstimateWithToken:(NSString *)token fromPickup:(CLLocation *)pickup toDestination:(CLLocation *)destination completionHandler:(void(^)(UberPrice *))complete
{
    NSString *urlString = [NSString stringWithFormat:@"https://api.uber.com/v1/estimates/price?access_token=%@&start_latitude=%f&start_longitude=%f&end_latitude=%f&end_longitude=%f", token, pickup.coordinate.latitude, pickup.coordinate.longitude, destination.coordinate.latitude, destination.coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (!error)
        {
            NSDictionary *estimatesDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSArray *allEstimates = [estimatesDict objectForKey:@"prices"];
            NSMutableArray *prices = [NSMutableArray new];
            for (NSDictionary *estimate in allEstimates) {

                UberPrice *price = [[UberPrice alloc] initWithDictionary:estimate];
                [prices addObject:price];

                if ([[estimate objectForKey:@"display_name"]  isEqualToString:@"uberX"]) {
                    UberPrice *uberPrice = [[UberPrice alloc] initWithDictionary:estimate];
                    complete(uberPrice);
                }
            }
        }else
        {
            NSLog(@"Error: %@", [error description]);
        }

    }];


}



@end
