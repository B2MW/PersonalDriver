//
//  AvailableRidesViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "AvailableRidesViewController.h"
#import "AvailableRidesDetailViewController.h"
#import "AvailableRidesTableView.h"
#import "ScheduledRideDetailViewController.h"
#import "ScheduledRideTableViewCell.h"
#import "ScheduledTableView.h"
#import "User.h"
#import <Parse/Parse.h>


@interface AvailableRidesViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet AvailableRidesTableView *availableTableView;
@property (weak, nonatomic) IBOutlet ScheduledTableView *scheduledTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property CLLocationManager *locationManager;
@property NSArray *availableRides;
@property NSArray *scheduledRides;
@end

@implementation AvailableRidesViewController
- (void)viewWillAppear:(BOOL)animated
{
    [self refreshDisplay];
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scheduledTableView.hidden = YES;
}

- (IBAction)segmentedAction:(UISegmentedControl *)segmentedControl {

    if (segmentedControl.selectedSegmentIndex == 0)
    {
        self.scheduledTableView.hidden = YES;
        self.availableTableView.hidden = NO;
    }else
    {
        self.availableTableView.hidden = YES;
        self.scheduledTableView.hidden = NO;
    }
    [self refreshDisplay];

}

#pragma mark -  Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.scheduledTableView.isHidden == YES)//Show Available Rides
    {
        return self.availableRides.count;
    } else //Show Schduled Rides
    {
        return self.scheduledRides.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RideManager *rideManager = [[RideManager alloc] init];

    if (self.scheduledTableView.isHidden == YES)//Show Available Rides
    {
        AvailableRideTableViewCell *cell = [self.availableTableView dequeueReusableCellWithIdentifier:@"RideCell"];
        Ride *availableRide = [self.availableRides objectAtIndex:indexPath.row];
        cell.pickupDateTimeLabel.text = [rideManager formatRideDate:availableRide];
        cell.fareEstimate.text = [rideManager formatRideFareEstimate:availableRide.fareEstimateMin fareEstimateMax:availableRide.fareEstimateMax];

        [rideManager retrieveRideDistanceAndBearing:availableRide :self.locationManager :^(NSArray *rideBearingAndDistance)
        {
            cell.rideOrigin.text = [NSString stringWithFormat:@"Pickup is %@ miles %@",[rideBearingAndDistance objectAtIndex:0], [rideBearingAndDistance objectAtIndex:1]];
        }];

        [rideManager retrivedRideTripDistance:availableRide :^(NSNumber *tripDistance)
        {
            cell.rideDestination.text = [NSString stringWithFormat:@"%@ mile trip", tripDistance];
        }];

        //load image file with placeholder first
        User *passenger = availableRide.passenger;
        cell.userImage.image = [UIImage imageNamed:@"profilePicPlaceholder"];
        PFFile *pictureFile = [passenger objectForKey:@"picture"];
        cell.userImage.file = pictureFile;
        [cell.userImage loadInBackground];

        return cell;

    }else
    {
        ScheduledRideTableViewCell *cell = [self.scheduledTableView dequeueReusableCellWithIdentifier:@"ScheduledCell"];
        Ride *scheduledRide = [self.scheduledRides objectAtIndex:indexPath.row];
        cell.pickupDateTimeLabel.text = [rideManager formatRideDate:scheduledRide];
        cell.rideOrigin.text = scheduledRide.pickUpLocation;
        cell.rideDestination.text = scheduledRide.destination;
        cell.fareEstimate.text = [rideManager formatRideFareEstimate:scheduledRide.fareEstimateMin fareEstimateMax:scheduledRide.fareEstimateMax];
        //load image file with placeholder first
        User *passenger = scheduledRide.passenger;
        cell.userImage.image = [UIImage imageNamed:@"profilePicPlaceholder"];
        PFFile *pictureFile = [passenger objectForKey:@"picture"];
        cell.userImage.file = pictureFile;
        [cell.userImage loadInBackground];
        return cell;
    }


}


-(void)refreshDisplay
{
    RideManager *rideManager = [[RideManager alloc] init];
    [rideManager getAvailableRides:^(NSArray *rideResults)
    {
        self.availableRides = rideResults;
        [self.availableTableView reloadData];
    }];
    [rideManager getScheduledRides:^(NSArray *scheduledrides) {
        self.scheduledRides = scheduledrides;
        [self.scheduledTableView reloadData];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)cell

{
    if ([[segue identifier] isEqualToString:@"showAvailable"])
    {
        AvailableRidesDetailViewController *viewController = [segue destinationViewController];
        viewController.ride = [self.availableRides objectAtIndex:[self.availableTableView indexPathForSelectedRow].row];
    }
    else if ([[segue identifier] isEqualToString:@"showScheduled"])
    {
        ScheduledRideDetailViewController *scheduledVC = [segue destinationViewController];
        NSIndexPath *indexPath = [self.scheduledTableView indexPathForCell:cell];
        scheduledVC.ride = [self.scheduledRides objectAtIndex:indexPath.row];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations) {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}


@end
