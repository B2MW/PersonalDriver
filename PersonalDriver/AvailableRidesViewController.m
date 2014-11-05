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

    //Format Date for presentation in Available Rides TableView
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE' at 'h:mm a"];
    NSString *formattedRideDate = [formatter stringFromDate:ride.rideDateTime];


    cell.pickupDateTimeLabel.text = formattedRideDate;
    cell.rideOrigin.text = @"my ride origin";
    cell.rideDestination.text = @"my ride destination";
    cell.fareEstimate.text = [[ride.fareEstimateMin.stringValue stringByAppendingString:@" - "] stringByAppendingString:ride.fareEstimateMax.stringValue];
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
