//
//  PassengerRidesTableViewCell.h
//  PersonalDriver
//
//  Created by Bradley Walker on 11/19/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PassengerRidesTableViewCell : UITableViewCell
@property IBOutlet UILabel *pickupLocation;
@property IBOutlet UILabel *dropoffLocation;
@property IBOutlet UILabel *rideDate;
@property IBOutlet UIImageView *driverImage;
@property IBOutlet UILabel *driverConfirmationLabel;
@property IBOutlet UILabel *fareEstimate;
@end
