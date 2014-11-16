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
@property NSArray *weekdaysSectionTitles;
@property NSDictionary *weekdays;
@property NSMutableArray *mondayRides;
@property NSMutableArray *tuesdayRides;
@property NSMutableArray *wednesdayRides;
@property NSMutableArray *thursdayRides;
@property NSMutableArray *fridayRides;
@property NSMutableArray *saturdayRides;
@property NSMutableArray *sundayRides;
@end

@implementation AvailableRidesViewController
- (void)viewWillAppear:(BOOL)animated
{
    self.locationManager = [CLLocationManager new];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scheduledTableView.hidden = YES;

    [self refreshDisplay];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (IBAction)segmentedAction:(UISegmentedControl *)segmentedControl
{

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
        // Return the number of rows in the section.
        NSString *sectionTitle = [self.weekdaysSectionTitles objectAtIndex:section];
        NSArray *sectionWeekdays = [self.weekdays objectForKey:sectionTitle];
        return [sectionWeekdays count];
    }
    else //Show Schduled Rides
    {
        return self.scheduledRides.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RideManager *rideManager = [[RideManager alloc] init];

    if (self.scheduledTableView.isHidden == YES)//Show Available Rides
    {
        AvailableRideTableViewCell *cell = [self.availableTableView dequeueReusableCellWithIdentifier:@"RideCell" forIndexPath:indexPath];
        NSString *sectionTitle = [self.weekdaysSectionTitles objectAtIndex:indexPath.section];
        NSArray *sectionWeekdays = [self.weekdays objectForKey:sectionTitle];
        Ride *availableRide = [sectionWeekdays objectAtIndex:indexPath.row];

        cell.pickupDateTimeLabel.text = [rideManager formatRideDate:availableRide];
        cell.fareEstimate.text = [rideManager formatRideFareEstimate:availableRide.fareEstimateMin fareEstimateMax:availableRide.fareEstimateMax];

        [rideManager retrieveRideDistanceAndBearing:availableRide :self.locationManager :^(NSArray *rideBearingAndDistance)
        {
            NSNumber *rideDistance = [rideBearingAndDistance objectAtIndex:0];
            if ( rideDistance.doubleValue >= 1)
            {
                cell.rideOrigin.text = [NSString stringWithFormat:@"Pickup point is %@ miles %@",[rideBearingAndDistance objectAtIndex:0], [rideBearingAndDistance objectAtIndex:1]];
            }
            else
            {
                cell.rideOrigin.text = @"Pickup point is within a mile";
            }
        }];

        [rideManager retrivedRideTripDistance:availableRide :^(NSNumber *tripDistance)
        {
            cell.rideDestination.text = [NSString stringWithFormat:@"%@ mile trip", tripDistance];
        }];

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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.weekdaysSectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.weekdaysSectionTitles objectAtIndex:section];
}

-(void)refreshDisplay
{
    RideManager *rideManager = [[RideManager alloc] init];
    [rideManager getAvailableRides:self.locationManager :^(NSArray *rideResults)
    {
        self.availableRides = rideResults;
        [self categorizeRidesByDay];
        [self.availableTableView reloadData];
    }];
    [rideManager getScheduledRides:^(NSArray *scheduledrides)
    {
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

-(void)categorizeRidesByDay
{
    self.mondayRides = [NSMutableArray array];
    self.tuesdayRides = [NSMutableArray array];
    self.wednesdayRides = [NSMutableArray array];
    self.thursdayRides = [NSMutableArray array];
    self.fridayRides = [NSMutableArray array];
    self.saturdayRides = [NSMutableArray array];
    self.sundayRides = [NSMutableArray array];

    for (Ride *ride in self.availableRides)
    {
        NSLog(@"%td",[[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:[NSDate date]] weekday]);
        NSLog(@"%td",[[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:ride.rideDateTime] weekday]);

        NSInteger weekday = [[[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:ride.rideDateTime] weekday];
        if (weekday == 1)
        {
            [self.sundayRides addObject:ride];
        }
        else if (weekday == 2)
        {
            [self.mondayRides addObject:ride];
        }
        else if (weekday == 3)
        {
            [self.tuesdayRides addObject:ride];
        }
        else if (weekday == 4)
        {
            [self.wednesdayRides addObject:ride];
        }
        else if (weekday == 5)
        {
            [self.thursdayRides addObject:ride];
        }
        else if (weekday == 6)
        {
            [self.fridayRides addObject:ride];
        }
        else if (weekday == 7)
        {
            [self.saturdayRides addObject:ride];
        }
    }
    NSInteger index = 0;
    self.weekdaysSectionTitles = @[@"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    self.weekdays = @{self.weekdaysSectionTitles[0] : self.sundayRides,
                      self.weekdaysSectionTitles[1] : self.mondayRides,
                      self.weekdaysSectionTitles[2] : self.tuesdayRides,
                      self.weekdaysSectionTitles[3] : self.wednesdayRides,
                      self.weekdaysSectionTitles[4] : self.thursdayRides,
                      self.weekdaysSectionTitles[5] : self.fridayRides,
                      self.weekdaysSectionTitles[6] : self.saturdayRides};
}

-(IBAction)unwindFromScheduledRide:(UIStoryboardSegue *)sender
{
    [self refreshDisplay];
}

@end
