//
//  AvailableRidesViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "AvailableRidesViewController.h"
#import "AvailableRidesDetailViewController.h"

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
    RideManager *rideManager = [[RideManager alloc] init];
    AvailableRideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];

    cell.pickupDateTimeLabel.text = [rideManager formatRideDate:ride];
    cell.rideOrigin.text = ride.pickUpLocation;
    cell.rideDestination.text = ride.destination;
    cell.fareEstimate.text = [NSString stringWithFormat:@"$%@-%@",ride.fareEstimateMin, ride.fareEstimateMax];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(AvailableRideTableViewCell *)cell
{
    AvailableRidesDetailViewController *viewController = [segue destinationViewController];
    viewController.ride = cell.ride;
}

@end
