//
//  GetToken.m
//  PersonalDriver
//
//  Created by pmccarthy on 11/5/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "Token.h"
#import <SSKeychain.h>
#import <SSKeychainQuery.h>
#import "UberAPI.h"
#import "UberProfile.h"

@implementation Token



+ (NSString *)getToken {
    NSString *token = [SSKeychain passwordForService:@"rot" account:@"rot"];
    return token;
}

+ (void)setToken:(NSString *)token {
    [SSKeychain setPassword:token forService:@"rot" account:@"rot"];
}

+(void)eraseToken {
    [SSKeychain deletePasswordForService:@"rot" account:@"rot"];
    if ([Token getToken] == nil) {
        NSLog(@"Token deleted");
    }
}



    



@end
