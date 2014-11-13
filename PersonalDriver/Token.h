//
//  GetToken.h
//  PersonalDriver
//
//  Created by pmccarthy on 11/5/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Token : NSObject

+ (NSString *)getToken;
+ (void)setToken:(NSString *)token;
+ (void) eraseToken;

@end
