//
//  UserProfileViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "PassengerProfileViewController.h"
#import <Parse/Parse.h>
#import "Ride.h"
#import "User.h"

@interface PassengerProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property NSArray *rides;
@property NSArray *requestedRides;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation PassengerProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.requestedRides = [[NSArray alloc]init];
    [self getAvailableRides];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.title = @"Current Rides";

    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.requestedRides.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];


    Ride *ride = [self.requestedRides objectAtIndex:indexPath.row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd"];
    [timeFormatter setDateFormat:@"hh:mm a"];
    NSString *dateString = [dateFormatter stringFromDate:ride.rideDateTime];
    NSString *timeString = [timeFormatter stringFromDate:ride.rideDateTime];
    cell.textLabel.text = dateString;
    cell.detailTextLabel.text = timeString;

    if (ride.driverConfirmed == YES) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;;
    }

    return cell;
}

-(void)getAvailableRides
{
    PFQuery *queryAvailableRides = [Ride query];
    [queryAvailableRides whereKeyDoesNotExist:@"driver"];
    [queryAvailableRides whereKey:@"passenger"equalTo:[PFUser currentUser]];
    [queryAvailableRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.requestedRides = [NSArray arrayWithArray:objects];
            NSLog(@"request rides = %@", self.requestedRides);
            [self.tableView reloadData];
        }else{
            NSLog(@"Error: %@",error);
        }
        NSLog(@"Parse for available %@",queryAvailableRides);
    }];

}

-(void)getScheduledRides
{
    PFQuery *queryScheduledRides= [Ride query];
    [queryScheduledRides whereKey:@"passenger" equalTo:[PFUser currentUser]];
    [queryScheduledRides whereKey:@"driver" notEqualTo:nil];
    [queryScheduledRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.rides = [NSArray arrayWithArray:objects];
        }else{
            NSLog(@"Error: %@",error);
        }
        NSLog(@"Parse for available %@",queryScheduledRides);
    }];

}







@end
