//
//  User.h
//  PersonalDriver
//
//  Created by pmccarthy on 11/9/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>


@interface User : PFUser <PFSubclassing>
@property NSString *name;
@property (nonatomic) NSString *username;
@property (nonatomic) NSString *email;
@property PFGeoPoint *homeBase;
@property PFFile *picture;
@property BOOL isDriver;


@end
