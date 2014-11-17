//
//  UberPrice.m
//  UberKit
//
// Created by Sachin Kesiraju on 8/20/14.
// Copyright (c) 2014 Sachin Kesiraju
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "UberPrice.h"

@implementation UberPrice

- (instancetype) initWithDictionary:(NSDictionary *)dictionary distance:(float)distance time:(float)time
{
    self = [super init];
    
    if(self)
    {
        _productID = [dictionary objectForKey:@"product_id"];
        _currencyCode = [dictionary objectForKey:@"currency_code"];
        _displayName = [dictionary objectForKey:@"display_name"];
        _estimate = [dictionary objectForKey:@"estimate"];
        _surgeMultiplier = [[dictionary objectForKey:@"surge_multiplier"] floatValue];

        NSString *lowE = [dictionary objectForKey:@"low_estimate"];
        NSString *highE = [dictionary objectForKey:@"high_estimate"];
        if (![lowE isKindOfClass:[NSNull class]] || ![highE isKindOfClass:[NSNull class]])
        {
            _lowEstimate = ([lowE floatValue])/_surgeMultiplier;
            _highEstimate = ([highE floatValue])/_surgeMultiplier;
            //factor out the surge pricing
            self.avgEstimateWithoutSurge = [NSString stringWithFormat:@"%.f",((_highEstimate + _lowEstimate)/2)/_surgeMultiplier];
        } else
        {
            //calculate fare with distance and time
            float baseFare = 2.00;
            float safeRideFee = 1.00;
            float pricePerMile = 1.25;
            float pricePerMinute = 0.20;
            float total = (pricePerMile * distance) + (pricePerMinute * time) + baseFare + safeRideFee;
            self.avgEstimateWithoutSurge = [NSString stringWithFormat:@"%.2f", total];
        }







    }
    
    return self;
}

@end
