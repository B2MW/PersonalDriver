//
//  AppDelegate.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "User.h"
#import "Token.h"
#import "UberAPI.h"
#import "Ride.h"
#import <SBAPNSPusher.h>
#import <SVProgressHUD.h>


@interface AppDelegate ()
@property Ride *nextRide;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //setup Parse
    [Parse setApplicationId:@"TDRpDZRx0OnPYjIE2DPP5F78k7ykFa0njA9yyl6p" clientKey:@"dBZx7BTBidkeR2cUM32DFEJYwCMTUM1Wiy5SYUv5"];
    if (![User currentUser])
    {
        [self loginOrSignUpUserWithUberProfile];
    }

    //setup UberAPI
    [[UberAPI sharedInstance] setServerToken:@"5VvEv7zOK6lEmQf0qRjPBA8ie7P8IIHb0X8pAF2r"];
    [[UberAPI sharedInstance] setClientID:@"pVt5YyjIQIB5gcZHzz_SgyG2Z6lcJRWT"]; //Add your client id
    [[UberAPI sharedInstance] setClientSecret:@"7pJruVcbjQQPZNHRAscuArs2I3Ip3Y-MvVDj_Sw5"]; //Add your client secret
    [[UberAPI sharedInstance] setRedirectURL:@"rideontime://localhost"]; //Add your redirect url
    [[UberAPI sharedInstance] setApplicationName:@"RideOnTime!"]; //Add your application name



    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:(10.0/255.0) green:(9.0/255.0) blue:(26.0/255.0) alpha:1]];


    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:54.0/255.0 green:173.0/255.0 blue:201.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                           [UIFont fontWithName:@"System Bold" size:20.0], NSFontAttributeName, nil]];

    self.window.tintColor = [UIColor colorWithRed:(54.0/255.0) green:(173.0/255.0) blue:(201.0/255.0) alpha:1];


    //Register Actions for Push Notifications

    UIMutableUserNotificationAction *requestUber = [[UIMutableUserNotificationAction alloc]init];
    requestUber.title = @"Request Your Ride On Uber";
    requestUber.identifier = @"Request";
    requestUber.activationMode = UIUserNotificationActivationModeForeground;
    requestUber.destructive = NO;
    requestUber.authenticationRequired = NO;

    //Create categories for Push Notifications

    UIMutableUserNotificationCategory *requestCategory = [[UIMutableUserNotificationCategory alloc]init];
    requestCategory.identifier = @"Request";
    [requestCategory setActions:@[requestUber] forContext:UIUserNotificationActionContextDefault];
    //Register categories
    NSSet *categories = [NSSet setWithObjects:requestCategory, nil];
    // Register for Push Notifications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:categories];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //Store passengers next ride
    User *currentUser = [User currentUser];
    if (currentUser) {
        PFQuery *nextRide = [PFQuery queryWithClassName:@"Ride"];
        [nextRide whereKey:@"passenger" equalTo:currentUser];
        [nextRide whereKey:@"isComplete" notEqualTo:@"YES"];
        [nextRide orderByDescending:@"rideDateTime"];
        [nextRide findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count != 0)
            {
            self.nextRide = [objects objectAtIndex:0];
            }
        }];
    }

    //Used to send test push notifications
    [SBAPNSPusher start];


    return YES;


}

//Allow redirect from Safari back to App after oauth authentication
- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    //Get the authCode before getting the token

    NSLog(@"%@",url.query);
    NSArray *urlArray = [url.query componentsSeparatedByString:@"="];
    NSString *authCode = [urlArray objectAtIndex:1];
    if (authCode)
    {
        //use AuthCode to get token
        NSString *data = [NSString stringWithFormat:@"code=%@&client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code", authCode, [UberAPI sharedInstance].clientID, [UberAPI sharedInstance].clientSecret, [UberAPI sharedInstance].redirectURL];
        NSString *urlString = [NSString stringWithFormat:@"https://login.uber.com/oauth/token"];
        NSURL *urlForAuth = [NSURL URLWithString:urlString];
        NSMutableURLRequest* requestForAuth = [NSMutableURLRequest requestWithURL:urlForAuth];
        [requestForAuth setHTTPMethod:@"POST"];
        [requestForAuth setHTTPBody:[data dataUsingEncoding:NSUTF8StringEncoding]];

        [NSURLConnection sendAsynchronousRequest:requestForAuth queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            NSDictionary *authDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            NSString *authToken = [authDictionary objectForKey:@"access_token"];
            [Token setToken:authToken];
            NSLog(@"Token saved in Keychain");

            [[NSNotificationCenter defaultCenter]postNotificationName:@"tokenSaved" object:self];

            [self loginOrSignUpUserWithUberProfile];

        }];

        return YES;

    }else {
        return NO;
    }

}



- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}
#pragma mark - Delegate Methods for Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];

}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    if ([identifier isEqualToString:@"Request"])
    {
        NSLog(@"Handling Notification");
        [self requestRideWithUber];
    }
    completionHandler();
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

#pragma mark - Method Helpers

-(void)requestRideWithUber
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
//        NSString *pickupLatitude = [NSString stringWithFormat:@"%f",self.nextRide.dropoffGeoPoint.latitude];
//        NSString *pickupLongitude = [NSString stringWithFormat:@"%f",self.nextRide.dropoffGeoPoint.longitude];

//        NSString *dropoffLatitude = [NSString stringWithFormat:@"%f",self.nextRide.pickupGeoPoint.latitude];
//        NSString *dropoffLongitude = [NSString stringWithFormat:@"%f",self.nextRide.pickupGeoPoint.longitude];

        [SVProgressHUD show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"uber://?client_id=%@&action=setPickup&pickup[latitude]=41.8915&pickup[longitude]=-87.604055",[UberAPI sharedInstance].clientID]]
             ];
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        });

    }
    else {
        // No Uber app! Open Mobile Website.
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.personaldriver.PersonalDriver" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PersonalDriver" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PersonalDriver.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Helper Methods

-(void)loginOrSignUpUserWithUberProfile
{

    [[UberAPI sharedInstance] getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error)
     {
         PFQuery *queryUsers = [PFUser query];
         [queryUsers whereKey:@"username" equalTo:profile.email];
         [queryUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
          {
              if (objects.count == 0)
              {
                  User *user = [User new];

                  user.username = profile.email;
                  user.password = profile.promo_code;
                  user.email = profile.email;

                  NSString *name = [NSString stringWithFormat:@"%@ %@",profile.first_name, profile.last_name];
                  user.name = name;
                  //Save photo to Parse
                  NSURL *url = [NSURL URLWithString:profile.picture];
                  NSData *pictureData = [NSData dataWithContentsOfURL:url];
                  PFFile *imageFile = [PFFile fileWithName:@"ProfilePic.jpg" data:pictureData];
                  user.picture =imageFile;

                  [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                      if (succeeded) {
                          NSLog(@"User account created");
                      } else {
                          NSLog(@"%@",[error description]);
                          NSLog(@"Error while signing up");
                      }
                  }];
              }
              else
              {

                  [User logInWithUsernameInBackground:profile.email password:profile.promo_code block:^(PFUser *user, NSError *error) {
                      if (error) {
                          NSLog(@"%@", [error description]);
                          NSLog(@"Error while logging in");
                      }else
                      {
                          [self associateUserToDeviceForPush];
                          NSLog(@"Logged in successfully");
                      }
                  }];
              }
          }];
         
     }];
}

-(void)associateUserToDeviceForPush
{
    // Associate the device with a user for alerts
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [User currentUser];
    [installation saveInBackground];
}



@end
