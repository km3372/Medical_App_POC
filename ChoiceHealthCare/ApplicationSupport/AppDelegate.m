//
//  AppDelegate.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/17/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "AppDelegate.h"
#import "CHCConstants.h"
#import "IQKeyboardManager.h"
#import "SecurityPinController.h"
#import "APIClass.h"
#import "APINames.h"
#import "MBProgressHud.h"
#import "UserModel.h"
#import "LocationManager.h"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import <Quickblox/Quickblox.h>
#import "NSString+MD5.h"

#import "SWRevealViewController.h"
#import "MyToDoController.h"
#import "Utils.h"
#import "CHCConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UserModel* user = [UserModel currentUser];
    if(user.userId){
        if ([user.register_survey isEqualToString:@"1"]) {
            [self initalizeRootControllerAs:Home];
        }
        else{
            [self initalizeRootControllerAs:Survey];
        }

    } else {
        [self initalizeRootControllerAs:Signing];
    }

    //Setup APNS service
    [QBSettings setApplicationID:kQuickbloxAppId];
    [QBSettings setAuthKey:kQuickbloxAuthKey];
    [QBSettings setAuthSecret:kQuickbloxAuthSecret];
    [QBSettings setAccountKey:kQuickbloxAccountKey];
    
    //Setup Notifications
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil ]];

    [application registerForRemoteNotifications];
    
    [IQKeyboardManager sharedManager].enable = true;
//    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    
    [[UINavigationBar appearance] setTintColor:NAV_CONTROLLER_TEXT_COLOR];
    [[UINavigationBar appearance] setBarTintColor:CHOICE_LIGHT_BLUE];
    [UINavigationBar appearance].titleTextAttributes = @{NSForegroundColorAttributeName : NAV_CONTROLLER_TEXT_COLOR};
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    UILocalNotification* notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (notification) {
        [self displayLocalNotification:notification];
    }

    return YES;
}

- (void)displayLocalNotification:(UILocalNotification *)notification {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:notification.alertTitle
                                                                   message:notification.alertBody
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:notification.alertAction
                                              style:UIAlertActionStyleDefault
                                            handler:
                      ^(UIAlertAction * _Nonnull action) {
                          NSURL *url = [NSURL URLWithString:kInERPhoneNumber];
                          if ([[UIApplication sharedApplication] canOpenURL:url]) {
                              [[UIApplication sharedApplication] openURL:url];
                          } else {
                              [Utils showAlertForString:@"Your device does not support calling."];
                          }
                      }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss"
                                              style:UIAlertActionStyleCancel
                                            handler:
                      ^(UIAlertAction * _Nonnull action) {
                          // do nothing
                      }]];
    [self.window.rootViewController presentViewController:alert animated:true completion:^{
        //do nothing
    }];
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self displayLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification userInfo=%@", userInfo);
    // Get push alert
    [self postPushNotificationWithUserInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"didReceiveRemoteNotification userInfo=%@ completionHandler", userInfo);
    [self postPushNotificationWithUserInfo:userInfo];
    
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)postPushNotificationWithUserInfo:(NSDictionary *)userInfo {
    UserModel* user = [UserModel currentUser];
    NSString *message = userInfo[QBMPushMessageApsKey][QBMPushMessageAlertKey];

    if (userInfo) {
        NSNumber* badge = userInfo[@"aps"][@"badge"];
        if (badge && ![badge isEqual:[NSNull null]]) {
            user.badgeTotalCount = badge;
            [UIApplication sharedApplication].applicationIconBadgeNumber = badge.integerValue;
        }

        NSDictionary* badges = userInfo[@"badges"];
        user.badgeAppointmentCount = badges[@"appointment"];
        user.badgeSurveyCount = badges[@"survey"];
        user.badgeWellnessCount = badges[@"wellness"];
        [user synchronizeUser];
    }
    
    if (message && message.length) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Remote Notification"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        if ([user isLoggedIn]) {
            [alert addAction:[UIAlertAction actionWithTitle:@"View ToDos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                SWRevealViewController* revealVC = (SWRevealViewController*)self.window.rootViewController;
                UINavigationController* nc = (UINavigationController*)revealVC.frontViewController;
                UIStoryboard* storyboard = revealVC.storyboard;

                if ([nc.topViewController isKindOfClass:[MyToDoController class]]) {
                    MyToDoController* todoVC = (MyToDoController*)nc.topViewController;
                    [todoVC refresh];
                } else {
                    UIViewController* nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyToDoController"];
                    [nc pushViewController:nextVC animated:YES];
                }
            }]];
        }
        [alert addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
        }]];
        
        [self.window.rootViewController presentViewController:alert animated:YES completion:NULL];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveRemoteNotification" object:userInfo];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"didRegisterUserNotificationSettings: %@", notificationSettings);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    
    UserModel* user = [UserModel currentUser];


    if ([user isLoggedIn]) {
        if ((user.qbRegistered).boolValue) {
            [self qbLoginWithUser:user deviceToken:deviceToken];
        } else {
            [self qbSignupUser:user deviceToken:deviceToken];
        }
    }
}

#pragma mark - Quickblox helper methods
-(void)qbSignupUser:(UserModel*)user deviceToken:(NSData *)deviceToken {
    QBUUser *qbuser = [QBUUser user];
    qbuser.login = user.email;
    qbuser.password = user.email.MD5String;
    qbuser.email = user.email;
    qbuser.fullName = user.fullName;
    qbuser.externalUserID = (user.userId).integerValue;

    [QBRequest signUp:qbuser successBlock:^(QBResponse *response, QBUUser *qbuser) {
        // Success, do something
        NSLog(@"Quickblox: User signin successful");
        user.qbRegistered = @YES;
        [user synchronizeUser];

        [self qbLoginWithUser:user deviceToken:deviceToken];
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Quickblox: User signin error: %@", response.error);

        NSDictionary* reasons = (NSDictionary*)response.error.reasons[@"errors"];
        NSString* loginReason = ((NSArray*)reasons[@"login"]).firstObject;

        if ([loginReason isEqualToString:@"has already been taken"]) {
            //Already signed up so try to login
            user.qbRegistered = @YES;
            [user synchronizeUser];
            [self qbLoginWithUser:user deviceToken:deviceToken];
        }
    }];
}


-(void)qbLoginWithUser:(UserModel*)user deviceToken:(NSData *)deviceToken{
    [QBRequest logInWithUserEmail:user.email
                         password:user.email.MD5String
                     successBlock:^(QBResponse *response, QBUUser *qbuser)
     {
         // Login succeeded
         [self qbAddSubscriptionWithDeviceToken:deviceToken];
     } errorBlock:^(QBResponse *response) {
         NSLog(@"Quickblox: User Error: %@", (response.error).description);
     }];
}


- (void)qbAddSubscriptionWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceIdentifier = [UIDevice currentDevice].identifierForVendor.UUIDString;

    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;

    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        NSLog(@"Quickblox: Subscription successful");
    } errorBlock:^(QBResponse *response) {
        NSLog(@"Quickblox: Subscription Error: %@", (response.error).description);
    }];

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
}

- (void)initalizeRootControllerAs:(RootType)type {
    //setting the root view of the app weather user already logged in or not...
    switch (type) {
        case 0:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:kSigning];
            self.window.rootViewController = navController;
        }
            break;
        case 1:
        {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Home" bundle:nil];
//            UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:kHome];
//            self.window.rootViewController = navController;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CHCHome" bundle:nil];
            
            self.window.rootViewController = [storyboard instantiateInitialViewController];
            [LocationManager sharedLocationManager]; //start GPS tracking
        }
            break;
        case 2:
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"RegistrationSurvey" bundle:nil];
            UINavigationController *navController = [storyboard instantiateViewControllerWithIdentifier:@"survey"];
            self.window.rootViewController = navController;
        }
            break;
            
        default: {

            SecurityPinController *controller = [[SecurityPinController alloc] initWithNibName:@"SecurityPinController" bundle:[NSBundle mainBundle] userType:UserTypeOld completionBlock:^(NSString *resultPin, id controller) {

                NSString *oldPin = @"1234";
                
                if (oldPin) {
                    if ([oldPin isEqualToString:resultPin]) {
                       
                        [self initalizeRootControllerAs:Home];
                        [((UIViewController *)controller) dismissViewControllerAnimated:YES completion:nil];
                    }else {
                        [controller showWrongPingAnimationAlert];
                    }
                } else {
                    [self callVerifyApiPin:controller andPin:resultPin];
                }
        
            }];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
            self.window.rootViewController = navController;
        }
            break;
    }
    
    [self.window makeKeyAndVisible];
}


-(void)logout {
    UserModel* user = [UserModel currentUser];
    [user discardSession];
    [self initalizeRootControllerAs:Signing];
}


#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.mindbowser.ChoiceHealthCare" in the application's documents directory.
    return [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HEDISHeaderCell" withExtension:@"nib"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"ChoiceHealthCare.sqlite"];
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
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    _managedObjectContext.persistentStoreCoordinator = coordinator;
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if (managedObjectContext.hasChanges && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, error.userInfo);
            abort();
        }
    }
}

#pragma mark - Pin Verify Api

- (void)callVerifyApiPin:(id )controller andPin:(NSString*)pinStr{
    UserModel* user = [UserModel currentUser];

    [MBProgressHUD showHUDAddedTo:((UIViewController *)controller).view animated:YES];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@", kVerifyPin, user.userId];
   
    [[APIClass sharedManager] apiCallWithRequest:@{kPin:pinStr} forApi:urlStr requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ([resultDict[@"success"] boolValue] == true ) {

            if (resultDict[@"data"]) {
            
                if ([resultDict[@"verified"] boolValue] == true) {
                    
                    [self initalizeRootControllerAs:Home];
                    [((UIViewController *)controller) dismissViewControllerAnimated:YES completion:nil];
                }
            }
        } else {
            [controller showWrongPingAnimationAlert];
        }
        
        [MBProgressHUD hideAllHUDsForView:((UIViewController *)controller).view animated:YES];
        
    } onCancelation:^{
        
        [MBProgressHUD hideAllHUDsForView:((UIViewController *)controller).view animated:YES];
    }];

}

@end
