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
@property NSMutableArray *availableRides;
@property NSMutableArray *scheduledRides;
@property NSArray *arrayToCategorize;
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
    [super viewWillAppear:animated];
    self.availableRides = [NSMutableArray new];
    self.arrayToCategorize = [NSArray array];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.availableRides = [NSMutableArray new];
    self.scheduledRides = [NSMutableArray new];
    self.arrayToCategorize = [NSArray array];
    self.scheduledTableView.hidden = YES;

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
    {
        [self.locationManager startUpdatingLocation];
    }
    else
    {
        [self.locationManager requestWhenInUseAuthorization];
    }

    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];

    UIButton *settings = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [settings addTarget:self action:@selector(onSettingsButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [settings setImage:[UIImage imageNamed:@"tools3"] forState:UIControlStateNormal];
    UIBarButtonItem *item =[[UIBarButtonItem alloc]initWithCustomView:settings];
    self.navigationItem.leftBarButtonItem = item;
}

- (IBAction)segmentedAction:(UISegmentedControl *)segmentedControl
{
    if (segmentedControl.selectedSegmentIndex == 0)
    {
        self.scheduledTableView.hidden = YES;
        self.availableTableView.hidden = NO;
        [self refreshDisplay];
    }
    else
    {
        self.availableTableView.hidden = YES;
        self.scheduledTableView.hidden = NO;
        [self refreshDisplay];
    }
}

#pragma mark -  Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.scheduledTableView.isHidden == YES)//Show Available Rides
    {
        NSString *sectionTitle = [self.weekdaysSectionTitles objectAtIndex:section];
        NSArray *sectionWeekdays = [self.weekdays objectForKey:sectionTitle];
        return [sectionWeekdays count];
    }
    else //Show Schduled Rides
    {
        NSString *sectionTitle = [self.weekdaysSectionTitles objectAtIndex:section];
        NSArray *sectionWeekdays = [self.weekdays objectForKey:sectionTitle];
        return [sectionWeekdays count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RideManager *rideManager = [[RideManager alloc] init];
    NSString *sectionTitle = [self.weekdaysSectionTitles objectAtIndex:indexPath.section];
    NSArray *sectionWeekdays = [self.weekdays objectForKey:sectionTitle];
    Ride *ride = [sectionWeekdays objectAtIndex:indexPath.row];

    if (self.segmentedControl.selectedSegmentIndex == 0)//Show Available Rides
    {
        AvailableRideTableViewCell *cell = [self.availableTableView dequeueReusableCellWithIdentifier:@"RideCell" forIndexPath:indexPath];
        cell.pickupDateTimeLabel.text = [rideManager formatRideDate:ride];
        cell.fareEstimate.text = [rideManager formatRideFareEstimate:ride.fareEstimateMin fareEstimateMax:ride.fareEstimateMax];

        [rideManager retrieveRideDistanceAndBearing:ride locationManager:self.locationManager completionHandler:^(NSArray *rideBearingAndDistance)
         {
             NSNumber *rideDistance = [rideBearingAndDistance objectAtIndex:0];
             if (rideDistance.doubleValue >= 2)
             {
                 cell.rideOrigin.text = [NSString stringWithFormat:@"Pickup point is %@ miles %@",[rideBearingAndDistance objectAtIndex:0], [rideBearingAndDistance objectAtIndex:1]];
             }
             else
             {
                 cell.rideOrigin.text = @"Pickup is within a few miles";
             }
         }];

        [rideManager retrivedRideTripDistance:ride completionHandler:^(NSNumber *tripDistance)
         {
             cell.rideDestination.text = [NSString stringWithFormat:@"%@ mile trip", tripDistance];
         }];

        return cell;
    }
    else
    {
        ScheduledRideTableViewCell *cell = [self.scheduledTableView dequeueReusableCellWithIdentifier:@"ScheduledCell"];
        cell.pickupDateTimeLabel.text = [rideManager formatRideDate:ride];
        [rideManager retrieveSingleLineGeoPointAddress:ride.pickupGeoPoint completionHandler:^(NSString *address)
         {
             cell.rideOrigin.text = [NSString stringWithFormat:@"From: %@", address];
         }];
        [rideManager retrieveSingleLineGeoPointAddress:ride.dropoffGeoPoint completionHandler:^(NSString *address)
         {
             cell.rideDestination.text = [NSString stringWithFormat:@"To: %@", address];
         }];
//        cell.rideOrigin.text = ride.pickUpLocation;
//        cell.rideDestination.text = ride.destination;
        cell.fareEstimate.text = [NSString stringWithFormat:@"%@ Fare", [rideManager formatRideFareEstimate:ride.fareEstimateMin fareEstimateMax:ride.fareEstimateMax]];
        return cell;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.weekdaysSectionTitles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.weekdaysSectionTitles objectAtIndex:section];
}

-(void)refreshDisplay
{
    RideManager *rideManager = [[RideManager alloc] init];
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        [rideManager getAvailableRideWithlocationManager:self.locationManager completionHandler:^(NSArray *rideResults)
         {
             self.availableRides = [NSMutableArray arrayWithArray:rideResults];
             [self categorizeRidesByDay];
             [self.availableTableView reloadData];
         }];
    }
    else
    {
        [rideManager getScheduledRides:[User currentUser] completionHandler:^(NSArray *scheduledrides)
        {
             self.scheduledRides = [NSMutableArray arrayWithArray:scheduledrides];
             [self categorizeRidesByDay];
             [self.scheduledTableView reloadData];
         }];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell *)cell

{
    if ([[segue identifier] isEqualToString:@"showAvailable"])
    {
        AvailableRidesDetailViewController *viewController = [segue destinationViewController];
        NSInteger selectedSection = [self.availableTableView indexPathForSelectedRow].section;
        NSArray *weekdayArray = [self.weekdays objectForKey:[self.weekdaysSectionTitles objectAtIndex:selectedSection]];
        viewController.ride = [weekdayArray objectAtIndex:[self.availableTableView indexPathForSelectedRow].row];
        viewController.locationManager = self.locationManager;
    }
    else if ([[segue identifier] isEqualToString:@"showScheduled"])
    {
        ScheduledRideDetailViewController *scheduledVC = [segue destinationViewController];
        NSInteger selectedSection = [self.scheduledTableView indexPathForSelectedRow].section;
        NSArray *weekdayArray = [self.weekdays objectForKey:[self.weekdaysSectionTitles objectAtIndex:selectedSection]];
        scheduledVC.ride = [weekdayArray objectAtIndex:[self.availableTableView indexPathForSelectedRow].row];
        //scheduledVC.ride = [self.scheduledRides objectAtIndex:indexPath.row];
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if (location.verticalAccuracy < 1000 && location.horizontalAccuracy < 1000)
        {
            [self.locationManager stopUpdatingLocation];
            [self refreshDisplay];
            break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
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

    if (self.scheduledTableView.isHidden == NO)
    {
        self.arrayToCategorize = self.scheduledRides;
    }
    else
    {
        self.arrayToCategorize = self.availableRides;
    }

    for (Ride *ride in self.arrayToCategorize)
    {
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

-(IBAction)unwindFromFinished:(UIStoryboardSegue *)sender {

}

-(void)onSettingsButtonTapped:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Settings2" sender:self];
}


@end
