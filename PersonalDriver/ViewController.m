//
//  ViewController.m
//  PersonalDriver
//
//  Created by Bradley Walker on 11/3/14.
//  Copyright (c) 2014 TeamPersonalDriver. All rights reserved.
//

#import "ViewController.h"
#import "Token.h"
#import "UberAPI.h"
#import "User.h"
#import <NXOAuth2.h>

@interface ViewController () <UIAlertViewDelegate, UIWebViewDelegate>
@property NSString *token;
@property User *currentUser;
@property UberProfile *profile;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation ViewController

static NSString * const clientID =@"pVt5YyjIQIB5gcZHzz_SgyG2Z6lcJRWT";
static NSString * const clientSecret =@"7pJruVcbjQQPZNHRAscuArs2I3Ip3Y-MvVDj_Sw5";
static NSString * const scope = @"profile history";
static NSString * const accountType = @"Uber";
static NSString * const authURL =@"https://login.uber.com/oauth/authorize";

- (void)viewDidLoad {

    [super viewDidLoad];
      [self.navigationItem setHidesBackButton:YES animated:YES];

    self.webView.delegate = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideWebViewNotification:) name:@"tokenSaved" object:nil];


}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    self.webView.hidden = YES;

    //check to make sure the token is still valid and they can use the UberAPI
    NSString *token = [Token getToken];
    if (!token)
    {
        NSLog(@"You have no token");
        [self loginAlert];

    }else

    {
        [[UberAPI sharedInstance]  getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error) {
            if (!error) {
                [self loginOrSignUpUserWithUberProfile];
            }else {
                [Token eraseToken];
                [self loginAlert];
            }


        }];
    }
}


- (IBAction)onPassengerPressed:(UIButton *)sender {

    if ([User currentUser])
    {
        [self.currentUser saveInBackground];
        [self performSegueWithIdentifier:@"showPassenger" sender:self];
        NSLog(@"You are a Passenger");
    }
}

- (IBAction)onDriverPressed:(UIButton *)sender {

    if ([User currentUser])
    {
        [self.currentUser saveInBackground];
        [self performSegueWithIdentifier:@"showDriver" sender:self];
        NSLog(@"You are a Driver");
    }
}

- (IBAction)login:(id)sender {
    [self performSegueWithIdentifier:@"showLogin" sender:self];
}


#pragma mark - Helper Methods

-(void)loginOrSignUpUserWithUberProfile
{

    [[UberAPI sharedInstance]  getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error)
     {
         self.profile = profile;
         PFQuery *queryUsers = [User query];
         [queryUsers whereKey:@"username" containsString:self.profile.email];
         [queryUsers findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
          {
              if (objects == nil)
              {
                  User *user = [User new];

                  user.username = self.profile.email;
                  user.password = self.profile.promo_code;
                  user.email = self.profile.email;

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
                      }
                  }];
              }else
              {
                  NSError *error;
                  [User logInWithUsername:self.profile.email password:self.profile.promo_code error:&error];
                  if (error)
                  {
                      NSLog(@"%@", [error description]);
                  }else
                  {
                      self.currentUser = [User currentUser];
                      [self associateUserToDeviceForPush];
                      NSLog(@"Logged in successfully");
                  }
              }
          }];
         
     }];
}


-(void)associateUserToDeviceForPush
{
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [User currentUser];
    [installation saveInBackground];
}

- (void)eraseToken {

    [Token eraseToken];
}

- (void)logoutCurrentUser {
    [User logOut];
    if ([User currentUser] == nil)
    {
        NSLog(@"You are logged out");
    }
}

- (void)fareEstimate {

    CLLocation *pickupLocation = [[CLLocation alloc] initWithLatitude:37.7833 longitude:-122.4167];
    CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:37.9 longitude:-122.43];

    [[UberAPI sharedInstance]  getPriceEstimateFromPickup:pickupLocation toDestination:destinationLocation completionHandler:^(UberPrice *price) {
        NSLog(@"Estimate for Average Fare: $%@",price.avgEstimateWithoutSurge);
    }];
    
}

- (void)queryProfile {
    [[UberAPI sharedInstance]  getUserProfileWithCompletionHandler:^(UberProfile *profile, NSError *error) {
        NSLog(@"Name:%@ %@",profile.first_name,profile.last_name);
        NSLog(@"Email:%@",profile.email);
        NSLog(@"Picture: %@", profile.picture);
        NSLog(@"Promo Code:%@",profile.promo_code);
    }];

}

- (void)queryActivity {
    [[UberAPI sharedInstance]  getUberActivitiesWithCompletionHandler:^(NSMutableArray *activities) {
        NSLog(@"Activities:%@",activities);
    }];

}

- (void)loginAlert {
    UIAlertView *loginAlert = [[UIAlertView alloc]initWithTitle:@"Please Login to Uber" message:@"You will be redirected to Uber" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Login", nil];
    loginAlert.delegate = self;
    [loginAlert show];
}

#pragma mark - alertView Delegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Login"]) {

        [self login];
    }
}

-(void)login
{
    self.webView.hidden = NO;
    [self setupOauthAccountStore];
    [self requestOAuth2Access];


}

#pragma mark - Oauth2 Logic

- (void)setupOauthAccountStore
{
    NSURL *authURL = [NSURL URLWithString:@"https://login.uber.com/oauth/authorize"];
    NSURL *tokenUrl = [NSURL URLWithString:@"https://login.uber.com/oauth/token"];

    [[NXOAuth2AccountStore sharedStore] setClientID:clientID secret:clientSecret authorizationURL:authURL tokenURL:tokenUrl redirectURL:nil forAccountType:accountType ];

    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){

                                                      if (aNotification.userInfo) {
                                                          //account added, we have access
                                                          //we can now request protected data
                                                          NSLog(@"Success!! We have an access token.");
                                                      } else {
                                                          //account removed, we lost access
                                                      }
                                                  }];

    [[NSNotificationCenter defaultCenter] addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                                                      object:[NXOAuth2AccountStore sharedStore]
                                                       queue:nil
                                                  usingBlock:^(NSNotification *aNotification){

                                                      NSError *error = [aNotification.userInfo objectForKey:NXOAuth2AccountStoreErrorKey];
                                                      NSLog(@"Error!! %@", error.localizedDescription);
                                                      
                                                  }];
}

-(void)requestOAuth2Access
{
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:accountType withPreparedAuthorizationURLHandler:^(NSURL *preparedURL)
     {
         //navigate to the URL returned by NXOAuth2Client
         [self.webView loadRequest:[NSURLRequest requestWithURL:preparedURL]];
         
     }];
}

-(void)hideWebViewNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"tokenSaved"]) {
        self.webView.hidden = YES;
    }

}





@end
