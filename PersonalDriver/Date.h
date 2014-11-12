//
//  Date.h
//  PersonalDriver
//
//  Created by Michael Maloof on 11/11/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateDelegate
-(void)dateButtonWasTapped:(id)sender;

@end


@interface Date : UIButton

@property id<DateDelegate> delegate;

@end
