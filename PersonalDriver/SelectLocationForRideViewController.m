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



@interface SelectLocationForRideViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *pickupLocationTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;
@property CLLocation *pickupLocation;
@property CLLocation *destinationLocation;
//@property NSMutableArray *locations;
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

    self.nextButton.hidden = YES;
    self.dollarImage.hidden = YES;
    self.dollarLabel.hidden = YES;
    self.timeImage.hidden = YES;
    self.timeLabel.hidden = YES;

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@""
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];



    self.destinationGeopoint = [[PFGeoPoint alloc]init];
    self.pickupGeopoint = [[PFGeoPoint alloc]init];
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLLocationAccuracyKilometer;
    //self.currentLocation = [[CLLocation alloc]init];
    self.pickupLocation = [[CLLocation alloc] init];
    self.destinationLocation = [[CLLocation alloc] init];
    //self.pickupLocation = self.currentLocation;
    self.hasUserAddedPickupLocation = NO;
    self.pickupLocation = [self.locationManager location];
    //self.mapView.region = MKCoordinateRegionMakeWithDistance(self.pickupLocation.coordinate, 1000, 1000);

    self.title = @"New Ride";

}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

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
        self.pickupAddress = self.pickupLocationTextField.text;
        self.startPointAnnotation = [[MKPointAnnotation alloc]init];
        self.startPointAnnotation.coordinate = placemark.location.coordinate;
        self.startPointAnnotation.title = @"pickupLocation";
        self.pickupLocation = placemark.location;
        self.pickupGeopoint.latitude = placemark.location.coordinate.latitude;
        self.pickupGeopoint.longitude = placemark.location.coordinate.longitude;
        //^^To pass the lat and long to the PFGeo point on the next page. Could we switched to CLPlacemark if we send it over on the segue instead.
        [self.mapView addAnnotation:self.startPointAnnotation];
         self.mapView.region = MKCoordinateRegionMakeWithDistance(self.pickupLocation.coordinate, 1000, 1000);
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        //still some small map bugs on getting location

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
    renderer.strokeColor = [UIColor colorWithRed:54.0/255.0 green:173.0/255.0 blue:201.0/255.0 alpha:1.0];
    renderer.lineWidth = 4.0;
    return  renderer;
}


#pragma pin color


 - (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MKPointAnnotation<MKAnnotation>*)annotation
 {

    if ([annotation.title isEqualToString:@"pickupLocation"])
      {
          self.startPinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
          self.startPinAnnotation.pinColor = MKPinAnnotationColorGreen;
          self.startPinAnnotation.tag = 1;
          return self.startPinAnnotation;
      }

    else
    {
        self.endPinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MyPinID"];
        self.endPinAnnotation.pinColor = MKPinAnnotationColorRed;
        self.endPinAnnotation.tag = 2;
        return self.endPinAnnotation;
    }
 }

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    if (textField == self.pickupLocationTextField)
    {
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotation:self.endPointAnnotation];

        //creating location
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        self.pickupAddress = self.pickupLocationTextField.text;
        [geocoder geocodeAddressString:self.pickupAddress completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(error)
             {
                 UIAlertView *alertView = [[UIAlertView alloc] init];
                 alertView.delegate = self;
                 alertView.title = @"Please try using this format: Street Address, City, State. If you don't know the address, please try: Location Name, City, State";
                 [alertView addButtonWithTitle: @"Dismiss"];
                 [alertView show];
             }else
             {
                CLPlacemark *placemark= placemarks.firstObject;
                self.startPointAnnotation = [[MKPointAnnotation alloc]init];
                self.startPointAnnotation.coordinate = placemark.location.coordinate;
                self.startPointAnnotation.title = @"pickupLocation";
                self.pickupLocation = placemark.location;

                self.pickupGeopoint.latitude = placemark.location.coordinate.latitude;
                self.pickupGeopoint.longitude = placemark.location.coordinate.longitude;
                //^^To pass the lat and long to the PFGeo point on the next page. Could we switched to CLPlacemark if we send it over on the segue instead.

                //add location/pin to map and locations array
                [self.mapView addAnnotation:self.startPointAnnotation];


                 if(self.endPinAnnotation.tag == 2)
                 {
                     [self.mapView showAnnotations:self.mapView.annotations animated:YES];

                 }else
                 {
                     self.mapView.region = MKCoordinateRegionMakeWithDistance(self.pickupLocation.coordinate, 1000, 1000);
                 }

                 if(self.hasUserAddedPickupLocation == YES)
                 {
                    [self.mapView removeOverlays:self.mapView.overlays];

                     [UberAPI getPriceEstimateFromPickup:self.pickupLocation toDestination:self.destinationLocation completionHandler:^(UberPrice *price)
                      {
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
                        [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
                         {
                            self.currentRoute = [response.routes firstObject];
                            [self plotRouteOnMap:self.currentRoute];
                            self.timeLabel.text = [NSString stringWithFormat:@"%0.f min",self.currentRoute.expectedTravelTime/60];

                             if (!self.price.avgEstimateWithoutSurge)
                             {
                                 NSString *calculatedPrice = [self calculatePriceWithDistance:self.currentRoute.distance time:self.currentRoute.expectedTravelTime];
                                 self.price = [[UberPrice alloc]init];
                                 self.price.avgEstimateWithoutSurge = calculatedPrice;
                                 float hiEstimate = [calculatedPrice floatValue] * 1.1;
                                 self.price.highEstimate = [NSString stringWithFormat:@"%.f", hiEstimate];
                                 float lowEstimate = [calculatedPrice floatValue] * 0.9;
                                 self.price.lowEstimate = [NSString stringWithFormat:@"%.f", lowEstimate];
                                 self.dollarLabel.text = [NSString stringWithFormat:@"$%@",calculatedPrice];

                             } else
                             {
                                 self.dollarLabel.text = [NSString stringWithFormat:@"$%@",self.price.avgEstimateWithoutSurge];
                             }

                            [self.mapView showAnnotations:self.mapView.annotations animated:YES];
                            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                         }];
                 }
             }
            self.hasUserAddedPickupLocation = YES;
            [self.view endEditing:YES];
        }];
    }else if (textField == self.destinationTextField)
    {
        if(self.endPinAnnotation.tag == 2)
        {
            [self.mapView removeAnnotation:self.endPointAnnotation];
        }
        self.hasUserAddedPickupLocation = YES;

        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        self.destinationAddress = self.destinationTextField.text;
        [geocoder geocodeAddressString:self.destinationAddress completionHandler:^(NSArray *placemarks, NSError *error)
        {
            if(error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] init];
                alertView.delegate = self;
                alertView.title = @"Please try using this format: Street Address, City, State. If you don't know the address, please try: Location Name, City, State";
                [alertView addButtonWithTitle: @"Dismiss"];
                [alertView show];
            }else
            {
            CLPlacemark *placemark = placemarks.firstObject;
            self.endPointAnnotation = [[MKPointAnnotation alloc]init];
            self.endPointAnnotation.coordinate = placemark.location.coordinate;
            self.endPointAnnotation.title = @"destination";
            self.destinationLocation = placemark.location;

            self.destinationGeopoint.latitude = placemark.location.coordinate.latitude;
            self.destinationGeopoint.longitude = placemark.location.coordinate.longitude;

            [self.mapView addAnnotation:self.endPointAnnotation];

            [UberAPI getPriceEstimateFromPickup:self.pickupLocation toDestination:self.destinationLocation completionHandler:^(UberPrice *price)
                {
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
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
            {
                self.currentRoute = [response.routes firstObject];
                [self plotRouteOnMap:self.currentRoute];
                NSLog(@"ETA = %f", self.currentRoute.expectedTravelTime);
                self.timeLabel.text = [NSString stringWithFormat:@"%0.f min",self.currentRoute.expectedTravelTime/60];

                if (!self.price.avgEstimateWithoutSurge)
                {

                    NSString *calculatedPrice = [self calculatePriceWithDistance:self.currentRoute.distance time:self.currentRoute.expectedTravelTime];
                    self.price = [[UberPrice alloc]init];
                    self.price.avgEstimateWithoutSurge = calculatedPrice;
                    float hiEstimate = [calculatedPrice floatValue] * 1.1;
                    self.price.highEstimate = [NSString stringWithFormat:@"%.f", hiEstimate];
                    float lowEstimate = [calculatedPrice floatValue] * 0.9;
                    self.price.lowEstimate = [NSString stringWithFormat:@"%.f", lowEstimate];
                    self.dollarLabel.text = [NSString stringWithFormat:@"$%@",calculatedPrice];


                }else
                {
                    self.dollarLabel.text = [NSString stringWithFormat:@"$%@",self.price.avgEstimateWithoutSurge];
                }


                self.dollarImage.hidden = NO;
                self.dollarLabel.hidden = NO;
                self.timeImage.hidden = NO;
                self.timeLabel.hidden = NO;

                [self.mapView showAnnotations:self.mapView.annotations animated:YES];
                self.nextButton.hidden = NO;
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            }];
        }
        }];
        [self.view endEditing:YES];
    }
    return YES;
}

#pragma mark - Helper Methods

-(NSString *)calculatePriceWithDistance:(CLLocationDistance)distance time:(NSTimeInterval)time
{

    float baseFare = 2.00;
    float safeRideFee = 1.00;
    float pricePerMile = 1.25;
    float pricePerMinute = 0.20;
    float distanceInMiles = (float)(distance/1609.34);
    float timeinMinutes = (float)(time/60);
    float total = (pricePerMile * distanceInMiles) + (pricePerMinute * timeinMinutes) + baseFare + safeRideFee;

    NSString *calculatedPrice = [NSString stringWithFormat:@"%.f", total];

    return calculatedPrice;

}

- (IBAction)onSearchAddTapped:(id)sender
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotation:self.endPointAnnotation];

        //creating location
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        self.pickupAddress = self.pickupLocationTextField.text;
        [geocoder geocodeAddressString:self.pickupAddress completionHandler:^(NSArray *placemarks, NSError *error)
         {
             if(error)
             {
                 UIAlertView *alertView = [[UIAlertView alloc] init];
                 alertView.delegate = self;
                 alertView.title = @"Please try using this format: Street Address, City, State. If you don't know the address, please try: Location Name, City, State";
                 [alertView addButtonWithTitle: @"Dismiss"];
                 [alertView show];
             }else
             {
                 CLPlacemark *placemark= placemarks.firstObject;
                 self.startPointAnnotation = [[MKPointAnnotation alloc]init];
                 self.startPointAnnotation.coordinate = placemark.location.coordinate;
                 self.startPointAnnotation.title = @"pickupLocation";
                 self.pickupLocation = placemark.location;

                 self.pickupGeopoint.latitude = placemark.location.coordinate.latitude;
                 self.pickupGeopoint.longitude = placemark.location.coordinate.longitude;
                 //^^To pass the lat and long to the PFGeo point on the next page. Could we switched to CLPlacemark if we send it over on the segue instead.

                 //add location/pin to map and locations array
                 [self.mapView addAnnotation:self.startPointAnnotation];


                 if(self.endPinAnnotation.tag == 2)
                 {
                     [self.mapView showAnnotations:self.mapView.annotations animated:YES];

                 }else
                 {
                     self.mapView.region = MKCoordinateRegionMakeWithDistance(self.pickupLocation.coordinate, 1000, 1000);
                 }

                 if(self.hasUserAddedPickupLocation == YES)
                 {
                     [self.mapView removeOverlays:self.mapView.overlays];

                     [UberAPI getPriceEstimateFromPickup:self.pickupLocation toDestination:self.destinationLocation completionHandler:^(UberPrice *price)
                      {
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
                          [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
                           {
                               self.currentRoute = [response.routes firstObject];
                               [self plotRouteOnMap:self.currentRoute];
                               self.timeLabel.text = [NSString stringWithFormat:@"%0.f min",self.currentRoute.expectedTravelTime/60];

                               if (!self.price.avgEstimateWithoutSurge)
                               {
                                   NSString *calculatedPrice = [self calculatePriceWithDistance:self.currentRoute.distance time:self.currentRoute.expectedTravelTime];
                                   self.price = [[UberPrice alloc]init];
                                   self.price.avgEstimateWithoutSurge = calculatedPrice;
                                   float hiEstimate = [calculatedPrice floatValue] * 1.1;
                                   self.price.highEstimate = [NSString stringWithFormat:@"%.f", hiEstimate];
                                   float lowEstimate = [calculatedPrice floatValue] * 0.9;
                                   self.price.lowEstimate = [NSString stringWithFormat:@"%.f", lowEstimate];
                                   self.dollarLabel.text = [NSString stringWithFormat:@"$%@",calculatedPrice];

                               } else
                               {
                                   self.dollarLabel.text = [NSString stringWithFormat:@"$%@",self.price.avgEstimateWithoutSurge];
                               }

                               [self.mapView showAnnotations:self.mapView.annotations animated:YES];
                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                           }];
                 }
             }
             self.hasUserAddedPickupLocation = YES;
             [self.view endEditing:YES];
         }];

}

- (IBAction)onSearchAddTwoTapped:(id)sender
{
    if(self.endPinAnnotation.tag == 2)
    {
        [self.mapView removeAnnotation:self.endPointAnnotation];
    }
    self.hasUserAddedPickupLocation = YES;

    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    self.destinationAddress = self.destinationTextField.text;
    [geocoder geocodeAddressString:self.destinationAddress completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if(error)
         {
             UIAlertView *alertView = [[UIAlertView alloc] init];
             alertView.delegate = self;
             alertView.title = @"Please try using this format: Street Address, City, State. If you don't know the address, please try: Location Name, City, State";
             [alertView addButtonWithTitle: @"Dismiss"];
             [alertView show];
         }else
         {
             CLPlacemark *placemark = placemarks.firstObject;
             self.endPointAnnotation = [[MKPointAnnotation alloc]init];
             self.endPointAnnotation.coordinate = placemark.location.coordinate;
             self.endPointAnnotation.title = @"destination";
             self.destinationLocation = placemark.location;

             self.destinationGeopoint.latitude = placemark.location.coordinate.latitude;
             self.destinationGeopoint.longitude = placemark.location.coordinate.longitude;

             [self.mapView addAnnotation:self.endPointAnnotation];

             [UberAPI getPriceEstimateFromPickup:self.pickupLocation toDestination:self.destinationLocation completionHandler:^(UberPrice *price)
              {
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
             [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error)
              {
                  self.currentRoute = [response.routes firstObject];
                  [self plotRouteOnMap:self.currentRoute];
                  NSLog(@"ETA = %f", self.currentRoute.expectedTravelTime);
                  self.timeLabel.text = [NSString stringWithFormat:@"%0.f min",self.currentRoute.expectedTravelTime/60];

                  if (!self.price.avgEstimateWithoutSurge)
                  {

                      NSString *calculatedPrice = [self calculatePriceWithDistance:self.currentRoute.distance time:self.currentRoute.expectedTravelTime];
                      self.price = [[UberPrice alloc]init];
                      self.price.avgEstimateWithoutSurge = calculatedPrice;
                      float hiEstimate = [calculatedPrice floatValue] * 1.1;
                      self.price.highEstimate = [NSString stringWithFormat:@"%.f", hiEstimate];
                      float lowEstimate = [calculatedPrice floatValue] * 0.9;
                      self.price.lowEstimate = [NSString stringWithFormat:@"%.f", lowEstimate];
                      self.dollarLabel.text = [NSString stringWithFormat:@"$%@",calculatedPrice];


                  }else
                  {
                      self.dollarLabel.text = [NSString stringWithFormat:@"$%@",self.price.avgEstimateWithoutSurge];
                  }


                  self.dollarImage.hidden = NO;
                  self.dollarLabel.hidden = NO;
                  self.timeImage.hidden = NO;
                  self.timeLabel.hidden = NO;

                  [self.mapView showAnnotations:self.mapView.annotations animated:YES];
                  self.nextButton.hidden = NO;
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
              }];
         }
     }];
    [self.view endEditing:YES];
}



@end



