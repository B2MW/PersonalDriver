//
//  ScheduledRideTableViewCell.h
//  PersonalDriver
//
//  Created by pmccarthy on 11/8/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ride.h"

@interface ScheduledRideTableViewCell : UITableViewCell

@property Ride *ride;
@property IBOutlet UIImageView *userImage;
@property (strong, nonatomic) IBOutlet UILabel *pickupDateTimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *rideOrigin;
@property (strong, nonatomic) IBOutlet UILabel *rideDestination;
@property (strong, nonatomic) IBOutlet UILabel *fareEstimate;

@end
