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



@interface SelectLocationForRideViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>
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

@property MKPolyline *routeOverlay;
@property MKRoute *currentRoute;
@property MKPointAnnotation *startPointAnnotation;
@property MKPointAnnotation *endPointAnnotation;
@property MKPinAnnotationView *startPinAnnotation;
@property MKPinAnnotationView *endPinAnnotation;

@property bool hasUserAddedPickupLocation;

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *dollarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dollarImage;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timeImage;


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
    self.hasUserAddedPickupLocation = NO;

   self.dollarImage.hidden = YES;
   self.dollarLabel.hidden = YES;
   self.timeImage.hidden = YES;
   self.timeLabel.hidden = YES;
    self.title = @"New Ride";

    self.nextButton.hidden = YES;





}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [UberAPI getUserProfileWithToken:self.token completionHandler:^(UberProfile *profile) {
        if (profile.email) {
            self.token = [Token getToken];

            self.destinationGeopoint = [[PFGeoPoint alloc]init];
            self.pickupGeopoint = [[PFGeoPoint alloc]init];

            self.locationManager = [[CLLocationManager alloc]init];
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
        } else
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }

    }];


}


#pragma keyboard
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];

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

/*
 - (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
 {
 MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
 if([annotation.title isEqualToString:@"pickup"])
 {
 pin.pinColor = MKPinAnnotationColorGreen;

 }

 else if([annotation.title isEqualToString:@"destination"])
 {
 pin.pinColor = MKPinAnnotationColorRed;
 }


 return pin;

 }
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.pickupLocationTextField)
    {
        //if the user already added a location, remove it from map and array
        if(self.startPinAnnotation.tag == 1){

            [self.locations removeObject:self.startPinAnnotation];
            [self.mapView removeAnnotation:self.startPointAnnotation];
            //***why isn't the pin actually removing on the map?***

        }


        //creating location
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        self.pickupAddress = self.pickupLocationTextField.text;
        [geocoder geocodeAddressString:self.pickupAddress completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark *placemark= placemarks.firstObject;
            self.startPointAnnotation = [[MKPointAnnotation alloc]init];
            self.startPointAnnotation.coordinate = placemark.location.coordinate;
            self.startPointAnnotation.title = @"pickup";
            self.pickupLocation = placemark.location;

            //creating pin
            self.startPinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:self.startPointAnnotation reuseIdentifier:@"startpin"];
            //set tag to identify later (if the user adds a new pin ill want to be able to remove this one)
            [self.startPinAnnotation setTag:1];

            self.pickupGeopoint.latitude = placemark.location.coordinate.latitude;
            self.pickupGeopoint.longitude = placemark.location.coordinate.longitude;
            //^^To pass the lat and long to the PFGeo point on the next page. Could we switched to CLPlacemark if we send it over on the segue instead.

            //add location/pin to map and locations array
            [self.mapView addAnnotation:self.startPointAnnotation];
            [self.locations addObject:self.startPinAnnotation];

            //zoom map to show all pins
            [self.mapView showAnnotations:self.locations animated:YES];

            //code to possibly use later
            //self.mapView.region = MKCoordinateRegionMakeWithDistance(placemark.location.coordinate, 10000, 10000);

            if(self.hasUserAddedPickupLocation == YES){

                [self.mapView removeOverlays:self.mapView.overlays];

                [UberAPI getPriceEstimateWithToken:self.token fromPickup:self.pickupLocation toDestination:self.destinationLocation completionHandler:^(UberPrice *price) {
                    self.price = price;

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

                        self.timeLabel.text = [NSString stringWithFormat:@"%0.f min",self.currentRoute.expectedTravelTime/60];
                        self.dollarLabel.text = [NSString stringWithFormat:@"$%d",self.price.avgEstimateWithoutSurge];
                        
                        
                        
                        //refactor this badly. PLEASE!
                        
                    }];
                }];
                
            }
            
            self.hasUserAddedPickupLocation = YES;
            [self.view endEditing:YES];
            
        }];

    }

    else if (textField == self.destinationTextField)
    {
        if(self.endPinAnnotation.tag == 2){

            [self.locations removeObject:self.endPinAnnotation];
            [self.mapView removeAnnotation:self.endPointAnnotation];
        }

        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        self.destinationAddress = self.destinationTextField.text;
        [geocoder geocodeAddressString:self.destinationAddress completionHandler:^(NSArray *placemarks, NSError *error) {

            CLPlacemark *placemark = placemarks.firstObject;
            self.endPointAnnotation = [[MKPointAnnotation alloc]init];
            self.endPointAnnotation.coordinate = placemark.location.coordinate;
            self.endPointAnnotation.title = @"destination";
            self.destinationLocation = placemark.location;


            self.destinationGeopoint.latitude = placemark.location.coordinate.latitude;
            self.destinationGeopoint.longitude = placemark.location.coordinate.longitude;


            self.endPinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:self.endPointAnnotation reuseIdentifier:@"endpin"];
            self.endPinAnnotation.pinColor = MKPinAnnotationColorPurple;
            self.endPinAnnotation.animatesDrop = YES;
            [self.mapView addAnnotation:self.endPointAnnotation];
            [self.endPinAnnotation setTag:2];
            [self.locations addObject:self.endPinAnnotation];



            [self.mapView addAnnotation:self.endPointAnnotation];
            [self.locations addObject:self.endPinAnnotation];

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
                self.timeLabel.text = [NSString stringWithFormat:@"%0.f min",self.currentRoute.expectedTravelTime/60];
                self.dollarLabel.text = [NSString stringWithFormat:@"$%d",self.price.avgEstimateWithoutSurge];
                
                
                self.dollarImage.hidden = NO;
                self.dollarLabel.hidden = NO;
                self.timeImage.hidden = NO;
                self.timeLabel.hidden = NO;
                
                //^^When I get the storyboard ball I'd like to move this to a label that I add
                
            }];
        }];
        [self.view endEditing:YES];
        
        self.nextButton.hidden = NO;
    }

    return YES;
}



@end



