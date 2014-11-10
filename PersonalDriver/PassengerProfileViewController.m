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

@interface PassengerProfileViewController () <UITableViewDataSource, UITableViewDelegate>
@property NSMutableArray *rides;




@end

@implementation PassengerProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Current Rides";
    self.rides = [[NSMutableArray alloc]init];


    

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rides.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell" forIndexPath:indexPath];

    return cell;
}

-(void)getAvailableRides:(void(^)(NSArray *))completionHandler
{
    PFQuery *queryAvailableRides = [Ride query];
    [queryAvailableRides whereKeyDoesNotExist:@"driver"];
    [queryAvailableRides whereKey:@"passenger"equalTo:[PFUser currentUser]];
    [queryAvailableRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completionHandler(objects);

    }];
}

-(void)getScheduledRides:(void(^)(NSArray *))complete
{
    PFQuery *queryScheduledRides= [Ride query];
    [queryScheduledRides whereKey:@"passenger" equalTo:[PFUser currentUser]];
    [queryScheduledRides whereKey:@"driver" notEqualTo:nil];
    [queryScheduledRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        complete(objects);
    }];

}





@end
