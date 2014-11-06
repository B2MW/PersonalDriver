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

@interface SelectLocationForRideViewController () <MKMapViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pickupLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@end

@implementation SelectLocationForRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];

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

            self.pickupGeopoint.latitude = placemark.location.coordinate.latitude;
            self.pickupGeopoint.longitude = placemark.location.coordinate.longitude;


            MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"startpin"];
            newAnnotation.pinColor = MKPinAnnotationColorGreen;


            self.mapView.region = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 10000, 10000);

            [self.mapView addAnnotation:annotation];

            NSLog(@"pickup geo point = %@", self.pickupGeopoint);

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
           

            self.destinationGeopoint.latitude = placemark.location.coordinate.latitude;
            self.destinationGeopoint.longitude = placemark.location.coordinate.longitude;


            MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"endpin"];
            newAnnotation.pinColor = MKPinAnnotationColorPurple;
            newAnnotation.animatesDrop = YES;
            [self.mapView addAnnotation:annotation];

    }];
}

#pragma segue to next stage of request ride
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {

    NewRideViewController *newRideViewController = segue.destinationViewController;
    newRideViewController.pickupAddress = self.pickupAddress;
    newRideViewController.destinationAddress = self.destinationAddress;
    newRideViewController.pickupGeopoint = self.pickupGeopoint;
    newRideViewController.destinationGeopoint = self.destinationGeopoint;

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






@end
