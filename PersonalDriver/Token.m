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

@implementation Token

+ (NSString *)getToken {
    NSString *service = @"personaldriver";
    NSArray *keychainArray = [SSKeychain accountsForService:service];
    NSDictionary *keychainDict = [keychainArray firstObject];
    NSString *account = [keychainDict objectForKey:@"acct"];
    NSString *token = [SSKeychain passwordForService:service account:account];
    return token;
}

@end
