//
//  AvailableRidesViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "AvailableRidesViewController.h"

@interface AvailableRidesViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *availableRides;

@end

@implementation AvailableRidesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self refreshDisplay];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.availableRides.count;
}

- (AvailableRideTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Ride *ride = [self.availableRides objectAtIndex:indexPath.row];
    AvailableRideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];
    cell.pickupDateTimeLabel.text = ride.rideDateTime;
    cell.rideOrigin.text = @"my ride origin";
    cell.rideDestination.text = @"my ride destination";
    cell.fareEstimate.text = @"$100";
    cell.userImage.image = [UIImage imageNamed:@"profilePicPlaceholder"];
    return cell;
}

-(void)refreshDisplay
{
    RideManager *rideManager = [[RideManager alloc] init];
    [rideManager getAvailableRides:^(NSArray *rideResults)
    {
        self.availableRides = rideResults;
        [self.tableView reloadData];
    }];
}

@end
