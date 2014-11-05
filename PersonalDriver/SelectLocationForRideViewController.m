//
//  SelectLocationForRideViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "SelectLocationForRideViewController.h"
#import "NewRideViewController.h"

@interface SelectLocationForRideViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pickupLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;




@end

@implementation SelectLocationForRideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestAlwaysAuthorization];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

-(void)addPickupPin{
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];

}

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



            [self.mapView addAnnotation:annotation];

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {

    NewRideViewController *newRideViewController = segue.destinationViewController;
    newRideViewController.pickupAddress = self.pickupAddress;
    newRideViewController.destinationAddress = self.destinationAddress;
    newRideViewController.pickupGeopoint = self.pickupGeopoint;
    newRideViewController.destinationGeopoint = self.destinationGeopoint;
    
}





@end
