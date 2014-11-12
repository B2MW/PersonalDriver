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
    self.title = @"Current Rides";
    self.rides = [[NSMutableArray alloc]init];
    [self getAvailableRides];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell" forIndexPath:indexPath];


    Ride *ride = [self.requestedRides objectAtIndex:indexPath.row];
    cell.textLabel.text = ride.pickUpLocation;
    cell.detailTextLabel.text = ride.destination;



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
