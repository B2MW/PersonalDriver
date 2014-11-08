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
//@property CLPlacemark *pickupPlacemark;
//@property CLPlacemark *destinationPlacemark;
@property NSMutableArray *locations;
@property NSString *token;
@property UberPrice *price;

@property MKPolyline *routeOverlay;
@property MKRoute *currentRoute;
@property MKPinAnnotationView *startAnnotation;
@property MKPinAnnotationView *endAnnotation;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;


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
    if(self.startAnnotation.tag == 1){
        [self.locations removeObject:self.startAnnotation];
        NSLog(@"new array check 1 = %@", self.locations);

    }

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    self.pickupAddress= self.pickupLocationTextField.text;
    [geocoder geocodeAddressString:self.pickupAddress completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark= placemarks.firstObject;
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc]init];
        annotation.coordinate = placemark.location.coordinate;
        annotation.title = @"pickup";
        self.pickupLocation = placemark.location;




        self.pickupGeopoint.latitude = placemark.location.coordinate.latitude;
        self.pickupGeopoint.longitude = placemark.location.coordinate.longitude;


        self.startAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"startpin"];
        [self.startAnnotation setTag:1];



        self.mapView.region = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 10000, 10000);

        [self.mapView addAnnotation:annotation];
        [self.locations addObject:self.startAnnotation];

        NSLog(@"pickup geo point = %@", self.pickupGeopoint);
        NSLog(@"array check 1 = %@", self.locations);
        NSLog(@"Destination Pin color = %lu", self.startAnnotation.pinColor);

        [self.mapView showAnnotations:self.locations animated:YES];

    }];

}

- (IBAction)onDestinationAddTapped:(id)sender
{

    if(self.endAnnotation.tag == 2){
        [self.locations removeObject:self.endAnnotation];
        NSLog(@"new array check 1 = %@", self.locations);
    }

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


            self.endAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"endpin"];
            self.endAnnotation.pinColor = MKPinAnnotationColorPurple;
            self.endAnnotation.animatesDrop = YES;
            [self.mapView addAnnotation:annotation];
            [self.endAnnotation setTag:2];
            [self.locations addObject:self.endAnnotation];


        NSLog(@"Destination Pin color = %lu", self.endAnnotation.pinColor);


        [self.mapView addAnnotation:annotation];
        [self.locations addObject:self.endAnnotation];
        NSLog(@"array check 2 = %@", self.locations);


        [UberAPI getPriceEstimateWithToken:self.token fromPickup:self.pickupLocation toDestination:self.destinationLocation completionHandler:^(UberPrice *price) {
            self.price = price;

            }];

        // Make a directions request
        MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc]init];;
        // Start at our current location
        MKPlacemark *startPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.pickupLocation.coordinate addressDictionary:nil];
        MKMapItem *source = [[MKMapItem alloc]initWithPlacemark:startPlacemark];
        [directionsRequest setSource:source];
        // Make the destination
        MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:self.destinationLocation.coordinate addressDictionary:nil];
        MKMapItem *destination = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
        [directionsRequest setDestination:destination];

        MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
            self.currentRoute = [response.routes firstObject];
            [self plotRouteOnMap:self.currentRoute];
            [self.mapView showAnnotations:self.locations animated:YES];
            NSLog(@"ETA = %f", self.currentRoute.expectedTravelTime);
            [self.nextButton setTitle:[NSString stringWithFormat:@"(%0.f minutes)   Next    $%d",self.currentRoute.expectedTravelTime/60, self.price.avgEstimate ]forState:UIControlStateNormal];

            //^^When I get the storyboard ball I'd like to move this to a label that I add

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
        self.pickupLocationTextField.text = address;
    }];
    
}


#pragma adding in route line
- (void)plotRouteOnMap:(MKRoute *)route
{
    if(self.routeOverlay) {
        [self.mapView removeOverlay:self.routeOverlay];
    }

    // Update the ivar
    self.routeOverlay = route.polyline;

    // Add it to the map
    [self.mapView addOverlay:self.routeOverlay];
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [UIColor redColor];
    renderer.lineWidth = 4.0;
    return  renderer;
}



#pragma pin color
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



