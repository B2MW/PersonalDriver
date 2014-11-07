//
//  SelectLocationForRideViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "SelectLocationForRideViewController.h"
#import "NewRideViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "UberAPI.h"
#import "Token.h"
#import "UberPrice.h"


@interface SelectLocationForRideViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pickupLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property CLLocation *pickupLocation;
@property CLLocation *destinationLocation;
@property NSMutableArray *locations;
@property NSString *token;
@property UberPrice *price;


@end

@implementation SelectLocationForRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.token = [Token getToken];

    self.destinationGeopoint = [[PFGeoPoint alloc]init];
    self.pickupGeopoint = [[PFGeoPoint alloc]init];

    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLLocationAccuracyKilometer;
    self.currentLocation = [[CLLocation alloc]init];
    self.currentLocation = [self.locationManager location];
    self.mapView.region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 10000, 10000);
    self.locations = [[NSMutableArray alloc]init];
    self.destinationLocation = [[CLLocation alloc] init];
    self.pickupLocation = [[CLLocation alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.token = [Token getToken];

    self.destinationGeopoint = [[PFGeoPoint alloc]init];
    self.pickupGeopoint = [[PFGeoPoint alloc]init];

    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLLocationAccuracyKilometer;
    self.currentLocation = [[CLLocation alloc]init];
    self.currentLocation = [self.locationManager location];
    self.mapView.region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 10000, 10000);
    self.locations = [[NSMutableArray alloc]init];
    self.destinationLocation = [[CLLocation alloc] init];
    self.pickupLocation = [[CLLocation alloc] init];

}


#pragma keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];

}

#pragma adding locations
- (IBAction)onPickupAddTapped:(id)sender
{

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    self.pickupAddress= self.pickupLocationTextField.text;
    [geocoder geocodeAddressString:self.pickupAddress completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        annotation.coordinate = placemark.location.coordinate;
        annotation.title = @"pickup";
        self.pickupLocation = placemark.location;


        self.pickupGeopoint.latitude = placemark.location.coordinate.latitude;
        self.pickupGeopoint.longitude = placemark.location.coordinate.longitude;


        MKPinAnnotationView *startAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"startpin"];



        self.mapView.region = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 10000, 10000);

        [self.mapView addAnnotation:annotation];
        [self.locations addObject:startAnnotation];

        NSLog(@"pickup geo point = %@", self.pickupGeopoint);
        NSLog(@"array check 1 = %@", self.locations);
        NSLog(@"Destination Pin color = %lu", startAnnotation.pinColor);



    }];
}

- (IBAction)onDestinationAddTapped:(id)sender
{

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    self.destinationAddress = self.destinationTextField.text;
    [geocoder geocodeAddressString:self.destinationAddress completionHandler:^(NSArray *placemarks, NSError *error) {


        CLPlacemark *placemark = placemarks.firstObject;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        annotation.coordinate = placemark.location.coordinate;
        annotation.title = @"destination";
        self.destinationLocation = placemark.location;


        self.destinationGeopoint.latitude = placemark.location.coordinate.latitude;
        self.destinationGeopoint.longitude = placemark.location.coordinate.longitude;

        self.destinationGeopoint.latitude = placemark.location.coordinate.latitude;
        self.destinationGeopoint.longitude = placemark.location.coordinate.longitude;

            MKPinAnnotationView *endAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"endpin"];
            endAnnotation.pinColor = MKPinAnnotationColorPurple;
            endAnnotation.animatesDrop = YES;
            [self.mapView addAnnotation:annotation];
            [self.locations addObject:endAnnotation];


        NSLog(@"Destination Pin color = %lu", endAnnotation.pinColor);


        [self.mapView addAnnotation:annotation];
        [self.locations addObject:endAnnotation];
        NSLog(@"array check 2 = %@", self.locations);
        [self.mapView showAnnotations:self.locations animated:YES];


        [UberAPI getPriceEstimateWithToken:self.token fromPickup:self.pickupLocation toDestination:self.destinationLocation completionHandler:^(UberPrice *price) {
            self.price = price;
            self.navigationController.navigationBar.topItem.title = [NSString stringWithFormat:@"Estimated Fare: $%d",price.avgEstimate];

       }];

    }];


}

#pragma segue to next stage of request ride
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {

    NewRideViewController *newRideViewController = segue.destinationViewController;
    newRideViewController.pickupAddress = self.pickupAddress;
    newRideViewController.destinationAddress = self.destinationAddress;
    newRideViewController.pickupGeopoint = self.pickupGeopoint;
    newRideViewController.destinationGeopoint = self.destinationGeopoint;
    newRideViewController.price = self.price;

}


#pragma device location

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error, no connection");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for(CLLocation *location in locations) {
        if(location.verticalAccuracy < 1000 &&location.horizontalAccuracy <1000){
            [self reverseGeocode:location];

            [self.locationManager stopUpdatingLocation];
            break;
        }
    }
}

-(void)reverseGeocode:(CLLocation *)location{
    CLGeocoder *geocoder = [CLGeocoder new];

    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = placemarks.firstObject;
        NSString *address = [NSString stringWithFormat:@"%@ %@ \n%@",
                             placemark.subThoroughfare,
                             placemark.thoroughfare,
                             placemark.locality];
        NSLog(@"current location = %@", address);
        NSLog(@"current placemark location = %@", placemark.location);
    }];
    
}


/*- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
 {
 MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
 if([annotation.title isEqualToString:@"pickup"])
 {
 pin.pinColor = MKPinAnnotationColorGreen;
 self.pickup.title = nil;

 }

 else if([annotation.title isEqualToString:@"destination"])
 {
 pin.pinColor = MKPinAnnotationColorRed;
 self.destination.title = nil;

 }


 return pin;

 } */


@end



