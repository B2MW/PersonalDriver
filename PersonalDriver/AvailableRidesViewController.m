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

    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (AvailableRideTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Ride *ride =
    AvailableRideTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];
    cell.passengerName = ;
    cell.fareEstimate = ;
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
