//
//  User.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/9/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "User.h"

@implementation User

@dynamic name;
@dynamic username;
@dynamic email;
@dynamic homeBase;
@dynamic picture;
@dynamic isDriver;

+(void)load
{
    [self registerSubclass];
}

+(NSString *)parseClassName
{
    return @"User";
}
@end