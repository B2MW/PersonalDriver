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
    self.destinationGeopoint = [[PFGeoPoint alloc]init];
    self.pickupGeopoint = [[PFGeoPoint alloc]init];


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
            NSLog(@"placemark stuff geo point = %f", placemark.location.coordinate.latitude);

            self.destinationGeopoint.latitude = placemark.location.coordinate.latitude;
            self.destinationGeopoint.longitude = placemark.location.coordinate.longitude;


            MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"endpin"];
            newAnnotation.pinColor = MKPinAnnotationColorPurple;
            newAnnotation.animatesDrop = YES;
            [self.mapView addAnnotation:annotation];

            NSLog(@"destination geo point = %@", self.destinationGeopoint);
            NSLog(@"destination lat = %f", self.destinationGeopoint.latitude);
            NSLog(@"placemark %@", placemark);
            NSLog(@"geocoder %@", geocoder);

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
