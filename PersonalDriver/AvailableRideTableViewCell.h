//
//  AvailableRideTableViewCell.h
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ride.h"

@interface AvailableRideTableViewCell : UITableViewCell
@property Ride *ride;
@property IBOutlet UIImageView *userImage;

@end
