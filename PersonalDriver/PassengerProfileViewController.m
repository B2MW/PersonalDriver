//
//  UserProfileViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "PassengerProfileViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "PushNotification.h"

@interface PassengerProfileViewController () <UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>

@property NSMutableArray *rides;
//@property NSMutableArray *ridesUnconfirmed;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PassengerProfileViewController

- (void)viewDidLoad {
    NSLog(@"NEW");

    [super viewDidLoad];
    self.rides = [[NSMutableArray alloc]init];
    [self getRides];
//[self getUnconfirmedRides];

    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.title = @"Current Rides";



    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    [self.tableView setTintColor:[UIColor colorWithRed:(54/255.0) green:(173/255.0) blue:(201/255.0) alpha:1]];


    UIButton *settings = [UIButton buttonWithType: UIButtonTypeInfoLight];
    [settings addTarget:self action:@selector(onSettingsButtonTapped:) forControlEvents:UIControlEventTouchDown];
    [settings setImage:[UIImage imageNamed:@"tools3"] forState:UIControlStateNormal];
    UIBarButtonItem *item =[[UIBarButtonItem alloc]initWithCustomView:settings];
    self.navigationItem.leftBarButtonItem = item;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.ride)
    {
        [self.rides addObject:self.ride];
        self.ride = nil;
    }
    [self.tableView reloadData];

}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.rides.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath

{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RideCell"];


    Ride *ride = [self.rides objectAtIndex:indexPath.row];
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

//-(void)getAvailableRides
//{
//    PFQuery *queryAvailableRides = [Ride query];
//    [queryAvailableRides whereKeyDoesNotExist:@"driver"];
//    [queryAvailableRides whereKey:@"passenger"equalTo:[User currentUser]];
//    [queryAvailableRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error){
//            self.rides = [NSMutableArray arrayWithArray:objects];
//            NSLog(@"request rides = %@", self.rides);
//            [self.tableView reloadData];
//        }else{
//            NSLog(@"Error: %@",error);
//        }
//        NSLog(@"Parse for available %@",queryAvailableRides);
//    }];
//
//}


-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {

    Ride *ride = [self.rides objectAtIndex:indexPath.row];

    UITableViewRowAction *deleteButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"X" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {

                                         UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancel Ride" message:@"Are you sure you want to cancel this ride?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
                                         self.ride = ride;
                                         [alert show];

                                     }];

    deleteButton.backgroundColor = [UIColor colorWithRed:(54/255.0) green:(173/255.0) blue:(201/255.0) alpha:1]; //delete color

    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:ride.destination handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                     {

                                     }];
    button.backgroundColor = [UIColor colorWithRed:(10.0/255.0) green:(9.0/255.0) blue:(26.0/255.0) alpha:1];

    return @[deleteButton, button]; //array with all the buttons you want. 1,2,3, etc...
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES; //tableview must be editable or nothing will work...
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
}

#pragma mark - alertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == [alertView cancelButtonIndex]){
        //NO is clicked do nothing
    }else{  //Yes is clicked. Delete
        self.ride.isCancelled = YES;
        [self.rides removeObject:self.ride];
        [PushNotification sendDriverCancellationNoticeForRide:self.ride];
        [self.ride saveInBackground];
        self.ride = nil;
        [self.tableView reloadData];
    }
}

#pragma mark - Helper Methods

-(void)getRides
{
    PFQuery *queryRides = [Ride query];
    [queryRides whereKey:@"passenger"equalTo:[PFUser currentUser]];
    [queryRides whereKey:@"isCancelled" equalTo:[NSNumber numberWithBool:NO]];
    [queryRides whereKey:@"rideComplete" equalTo:[NSNumber numberWithBool:NO]];
//    [queryRides whereKey:@"driverConfirmed" equalTo:[NSNumber numberWithBool:YES]];
    [queryRides orderByAscending:@"rideDateTime"];
    [queryRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.rides = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];

        }else{
            NSLog(@"Error: %@",error);
        }
        NSLog(@"Parse for available %@",queryRides);
    }];
    
}

/*-(void)getUnconfirmedRides
{
    PFQuery *queryRides = [Ride query];
    [queryRides whereKey:@"passenger"equalTo:[PFUser currentUser]];
    [queryRides whereKey:@"isCancelled" equalTo:[NSNumber numberWithBool:NO]];
    [queryRides whereKey:@"driverConfirmed" equalTo:[NSNumber numberWithBool:NO]];
    [queryRides orderByAscending:@"rideDateTime"];
    [queryRides findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error){
            self.ridesUnconfirmed = [NSMutableArray arrayWithArray:objects];
            [self.rides addObjectsFromArray:self.ridesUnconfirmed];
            [self.tableView reloadData];

        }else{
            NSLog(@"Error: %@",error);
        }
        NSLog(@"Parse for available %@",queryRides);
    }];
    
} */

-(IBAction)unwindFromFinished:(UIStoryboardSegue *)sender {

}

-(void)onSettingsButtonTapped:(UIBarButtonItem *)sender
{
    [self performSegueWithIdentifier:@"Settings" sender:self];
}




@end
