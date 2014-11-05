//
//  SelectLocationForRideViewController.m
//  PersonalDriver
//
//  Created by Michael Maloof on 11/4/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "SelectLocationForRideViewController.h"

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
    [geocoder geocodeAddressString:self.pickupLocationTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks)
        {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
            annotation.coordinate = placemark.location.coordinate;
            MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"startpin"];
            newAnnotation.pinColor = MKPinAnnotationColorGreen;
            [self.mapView addAnnotation:annotation];

        }

    }];
}

- (IBAction)onDestinationAddTapped:(id)sender
{

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder geocodeAddressString:self.destinationTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark *placemark in placemarks)
        {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
            annotation.coordinate = placemark.location.coordinate;
            MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"endpin"];
            newAnnotation.pinColor = MKPinAnnotationColorPurple;
            newAnnotation.animatesDrop = YES;
            [self.mapView addAnnotation:annotation];

        }
        
    }];
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control

{
    CLLocationCoordinate2D center = view.annotation.coordinate;

    MKCoordinateSpan span;
    span.latitudeDelta = 0.01;
    span.longitudeDelta = 0.01;

    MKCoordinateRegion region;
    region.center = center;
    region.span = span;

    [self.mapView setRegion:region animated:YES];
    
    
    
}


@end
