//
//  PassengerLabel.h
//  PersonalDriver
//
//  Created by Michael Maloof on 11/12/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PassengerDelegate
-(void)passengerLabelWasTapped:(id)sender;

@end

@interface PassengerLabel : UILabel

@property id<PassengerDelegate> delegate;

@end
