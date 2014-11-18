//
//  AvailableRidesDetailViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "AvailableRidesDetailViewController.h"
#import "PushNotification.h"

@interface AvailableRidesDetailViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *estimatedFare;
@property (strong, nonatomic) IBOutlet UILabel *estimatedFareLabel;
@property (strong, nonatomic) IBOutlet UILabel *estimatedFareInitialStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *estimatedFareInitialState;
@property (strong, nonatomic) IBOutlet UILabel *rideDate;
@property (strong, nonatomic) IBOutlet UILabel *rideDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *rideDateInitialState;
@property (strong, nonatomic) IBOutlet UILabel *rideDateInitialStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *distanceFromPickup;
@property (strong, nonatomic) IBOutlet UILabel *distanceFromPickupInitialStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *tripDistance;
@property (strong, nonatomic) IBOutlet UILabel *tripDistanceInitialStateLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPassengers;
@property (strong, nonatomic) IBOutlet UILabel *numberOfPassengersLabel;
@property (strong, nonatomic) IBOutlet UIView *pickupAddressLabel;
@property (strong, nonatomic) IBOutlet UITextView *pickupAddress;
@property (strong, nonatomic) IBOutlet UILabel *dropoffAddressLabel;
@property (strong, nonatomic) IBOutlet UITextView *dropoffAddress;
@property (strong, nonatomic) IBOutlet UILabel *specialInstructionsLabel;
@property (strong, nonatomic) IBOutlet UITextView *specialInstructions;
@property (strong, nonatomic) IBOutlet UIButton *scheduleRideButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property IBOutlet MKMapView *mapView;
@end

@implementation AvailableRidesDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self retrieveAvailableRidesData];
    [self hideRideDetails];
    [self.doneButton setHidden:YES];
    [self.doneButton setUserInteractionEnabled:NO];

    self.mapView.delegate = self;
    [self.mapView setUserInteractionEnabled:NO];
    [self displayPinsOnMap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)retrieveAvailableRidesData
{
    RideManager *rideManager = [[RideManager alloc] init];

    //Query Parse User class
    PFQuery *queryForUserDetails = [PFQuery queryWithClassName:@"User"];
    [queryForUserDetails whereKey:@"objectId" equalTo:self.ride.passenger.objectId];
    [queryForUserDetails findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error || nil)
         {
             NSLog(@"Error: %@", error.userInfo);
         }

         //Display and format special instructions
         if ([self.ride.specialInstructions isEqualToString:@""])
         {
             self.specialInstructions.text = @"No special instructions for this ride";
             self.specialInstructions.textColor = [UIColor grayColor];
         }
         else
         {
             self.specialInstructions.text = self.ride.specialInstructions;
         }

         self.estimatedFare.text = [rideManager formatRideFareEstimate:self.ride.fareEstimateMin fareEstimateMax:self.ride.fareEstimateMax];
         self.estimatedFareInitialState.text = self.estimatedFare.text;
         [rideManager retrivedRideTripDistance:self.ride completionHandler:^(NSNumber *rideDistance)
         {
             if (rideDistance.doubleValue >= 2)
             {
                 self.tripDistance.text = [NSString stringWithFormat:@"%@ miles", rideDistance.stringValue];

             }
             else
             {
                 self.tripDistance.text = [NSString stringWithFormat:@"%@ mile", rideDistance.stringValue];
             }
         }];
         self.rideDate.text = [rideManager formatRideDate:self.ride];
         self.rideDateInitialState.text = self.rideDate.text;
         [rideManager retrieveRideDistanceAndBearing:self.ride locationManager:self.locationManager completionHandler:^(NSArray *locationAndBearing)
         {
             NSNumber *distance = locationAndBearing[0];
             if (distance.doubleValue >= 2)
             {
                 self.distanceFromPickup.text = [NSString stringWithFormat:@"%@ miles %@",locationAndBearing[0], locationAndBearing[1]];
             }
             else
             {
                 self.distanceFromPickup.text = @"Within 2 miles";
             }
         }];
         self.numberOfPassengers.text = self.ride.passengerCount;
         [rideManager retrieveGeoPointAddress:self.ride.pickupGeoPoint completionHandler:^(NSString *address)
         {
             self.pickupAddress.text = address;
         }];
         [rideManager retrieveGeoPointAddress:self.ride.dropoffGeoPoint completionHandler:^(NSString *address)
         {
             self.dropoffAddress.text = address;
         }];
         
     }];
}

- (void)confirmRideAvailability
{
    UIAlertView *rideAvailabilityAlert = [UIAlertView new];
    PFQuery *queryRideAvailability = [PFQuery queryWithClassName:@"Ride"];
    [queryRideAvailability whereKey:@"objectId" equalTo:self.ride.objectId];
    [queryRideAvailability findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        Ride *ride = objects.firstObject;
        if (ride.driver == nil)
        {
            //Update Ride Record
            ride.driver = [User currentUser];
            [ride saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {

             }];

            //Show Ride Details
            [self unhideRideDetails];

            //Display Confirmation Alert View
            [rideAvailabilityAlert addButtonWithTitle:@"Ok"];
            [rideAvailabilityAlert setTitle:@"Ride Scheduled!"];
            [rideAvailabilityAlert setMessage:@"Thank you. You have been designated as the driver for this ride."];
            [rideAvailabilityAlert show];
            [PushNotification subscribeDriverToRide:ride];
            [PushNotification sendDriverReminderForRide:ride];
            [PushNotification sendPassengerRideConfirmed:ride];
            
            
        }
        else
        {
            //Display "Too Slow" Alert View
            [rideAvailabilityAlert addButtonWithTitle:@"Ok"];
            [rideAvailabilityAlert setTitle:@"Too Slow"];
            [rideAvailabilityAlert setMessage:@"We're sorry. Another driver has scheduled this ride."];
            [rideAvailabilityAlert show];
        }

        [self showDoneButton];
    }];
}

-(void)unhideRideDetails
{
    self.estimatedFare.hidden = NO;
    self.estimatedFareLabel.hidden = NO;
    self.numberOfPassengers.hidden = NO;
    self.numberOfPassengersLabel.hidden = NO;
    self.rideDate.hidden = NO;
    self.rideDateLabel.hidden = NO;
    self.pickupAddressLabel.hidden = NO;
    self.pickupAddress.hidden = NO;
    self.dropoffAddressLabel.hidden = NO;
    self.dropoffAddress.hidden = NO;
    self.specialInstructionsLabel.hidden = NO;
    self.specialInstructions.hidden = NO;
    self.estimatedFareInitialState.hidden = YES;
    self.estimatedFareInitialStateLabel.hidden = YES;
    self.distanceFromPickup.hidden = YES;
    self.distanceFromPickupInitialStateLabel.hidden = YES;
    self.rideDateInitialState.hidden = YES;
    self.rideDateInitialStateLabel.hidden = YES;
    self.tripDistance.hidden = YES;
    self.tripDistanceInitialStateLabel.hidden = YES;
    self.mapView.hidden = YES;
}

-(void)hideRideDetails
{
    self.estimatedFare.hidden = YES;
    self.estimatedFareLabel.hidden = YES;
    self.numberOfPassengers.hidden = YES;
    self.numberOfPassengersLabel.hidden = YES;
    self.rideDate.hidden = YES;
    self.rideDateLabel.hidden = YES;
    self.pickupAddressLabel.hidden = YES;
    self.pickupAddress.hidden = YES;
    self.dropoffAddressLabel.hidden = YES;
    self.dropoffAddress.hidden = YES;
    self.specialInstructionsLabel.hidden = YES;
    self.specialInstructions.hidden = YES;
}

- (IBAction)onScheduleRideButtonPressed:(UIButton *)sender
{
    [self confirmRideAvailability];
}

-(void)showDoneButton
{
    [self.doneButton setHidden:NO];
    [self.doneButton setUserInteractionEnabled:YES];
    [self.scheduleRideButton setHidden:YES];
    [self.scheduleRideButton setUserInteractionEnabled:NO];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{

    if (annotation == mapView.userLocation)
    {
        return nil;
    }

    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
    pin.canShowCallout = YES;
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return pin;
}

- (void)displayPinsOnMap
{
    CLLocationCoordinate2D pickupPoint;
    CLLocationCoordinate2D dropoffPoint;
    NSDictionary *addressDictionary;
    pickupPoint.latitude = self.ride.pickupGeoPoint.latitude;
    pickupPoint.longitude = self.ride.pickupGeoPoint.longitude;
    dropoffPoint.latitude = self.ride.dropoffGeoPoint.latitude;
    dropoffPoint.longitude = self.ride.dropoffGeoPoint.longitude;

    MKPointAnnotation *pickupAnnotation = [MKPointAnnotation new];
    MKPointAnnotation *dropoffAnnotation = [MKPointAnnotation new];
    pickupAnnotation.coordinate = pickupPoint;
    dropoffAnnotation.coordinate = dropoffPoint;

    MKPinAnnotationView *pickupPin = [[MKPinAnnotationView alloc] initWithAnnotation:pickupAnnotation reuseIdentifier:@"MyPinID"];
    MKPinAnnotationView *dropoffPin = [[MKPinAnnotationView alloc] initWithAnnotation:dropoffAnnotation reuseIdentifier:@"MyPinID"];

    pickupPin.pinColor = MKPinAnnotationColorGreen;
    dropoffPin.pinColor = MKPinAnnotationColorRed;

    [self.mapView addAnnotations:@[pickupAnnotation, dropoffAnnotation]];
    [self.mapView showAnnotations:self.mapView.annotations animated:YES];

    MKPlacemark *pickupMKPlacemark = [[MKPlacemark alloc] initWithCoordinate:pickupPoint addressDictionary:addressDictionary];
    MKPlacemark *dropoffMKPlacemark = [[MKPlacemark alloc] initWithCoordinate:dropoffPoint addressDictionary:addressDictionary];
    MKMapItem *pickupMapItem = [[MKMapItem alloc] initWithPlacemark:pickupMKPlacemark];
    MKMapItem *dropoffMapItem = [[MKMapItem alloc] initWithPlacemark:dropoffMKPlacemark];
    MKDirectionsRequest *routeRequest = [MKDirectionsRequest new];
    [routeRequest setSource:pickupMapItem];
    [routeRequest setDestination:dropoffMapItem];
    MKDirections *route = [[MKDirections alloc] initWithRequest:routeRequest];

    [route calculateDirectionsWithCompletionHandler:
     ^(MKDirectionsResponse *response, NSError *error) {
         if (error) {
             // Handle Error
         } else {
             [self showRoute:response];
         }
     }];
}

-(void)showRoute:(MKDirectionsResponse *)response
{
    for (MKRoute *route in response.routes)
    {
        [self.mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id < MKOverlay >)overlay
{
    MKPolylineRenderer *renderer =
    [[MKPolylineRenderer alloc] initWithOverlay:overlay];
    renderer.strokeColor = [UIColor colorWithRed:54.0/255.0 green:173.0/255.0 blue:201.0/255.0 alpha:1.0];
    renderer.lineWidth = 4.0;
    return renderer;
}

@end
