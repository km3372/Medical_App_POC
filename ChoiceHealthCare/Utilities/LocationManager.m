//
//  LocationManager.m
//
//  Created by Chris Morse on 6/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import "LocationManager.h"

#include "SynthesizeSingleton.h"

#import "ConnectionManager.h"
#import <MapKit/MapKit.h>
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>
#import "CHCConstants.h"

@interface LocationManager() <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;


@end


@implementation LocationManager {
    NSOperationQueue* researchQueue;
    NSMutableArray* regions;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(LocationManager)

- (LocationManager*)init {
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;

        if ([CLLocationManager locationServicesEnabled]) {
            [self loadRegions];
            
            [self setTrackingStrategyLowestPower];
//            [self setTrackingStrategyMediumPower];
//            [self setTrackingStrategyHighestResolution];
            [self addGeofences];
        }
        
    }
    return self;
}

+ (CLLocation*)currentLocation {
    return [self sharedLocationManager].locationManager.location;
}

- (void)setTrackingStrategyLowestPower {
    [self.locationManager stopUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)setTrackingStrategyMediumPower {
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.locationManager.distanceFilter = 100.0;
    [self.locationManager startUpdatingLocation];
}

- (void)setTrackingStrategyHighestResolution {
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges];
}


- (void)loadRegions {
    NSArray* locations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"]];
    regions = [NSMutableArray new];
    
    for (NSDictionary* location in locations) {
      
        //build a region for each location
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake([location[@"latitude"] doubleValue], [location[@"longitude"] doubleValue]);
        CLCircularRegion* region = [[CLCircularRegion alloc] initWithCenter:center radius:[location[@"radius"] doubleValue] identifier:location[@"name"]];
        region.notifyOnEntry = YES;
        region.notifyOnExit = NO;

        [regions addObject:region];
    }
}

- (void)addGeofences {
    //Remove any old ones
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    //Add all the new ones
    for (CLRegion* region in regions) {
        //build a local notification for this region
        UILocalNotification* notification = [[UILocalNotification alloc] init];
        notification.region = region;
        notification.regionTriggersOnce = NO;
        notification.alertTitle = kInERAlertTitle;
        notification.alertBody = kInERAlertBody;
        notification.alertAction = @"Call Rep";
        
        //Now schedule it for showing
        //NB! This registers a region for each ER in the area.
        //Core Location limits to 20 the number of regions that may be simultaneously monitored by a single app
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
    
//    NSLog(@"Notifications: %@", [[UIApplication sharedApplication] scheduledLocalNotifications]);

}

- (void)researchLocations {
    researchQueue = [[NSOperationQueue alloc] init];
    researchQueue.maxConcurrentOperationCount = 1;
    NSMutableArray* doneArray = [NSMutableArray new];
    
    NSString* filePath = (@"~/tmp/LocationsGeo.plist").stringByExpandingTildeInPath;
    NSLog(@"filePath: %@", filePath);
    
    NSArray* locations = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"]];
    
    //Queue up the research requests
    for (NSDictionary* location in locations) {
        [researchQueue addOperationWithBlock:^{
            CLGeocoder* geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressDictionary:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                    //save dictionary
                NSLog(@"%lu Placemarks found, error: %@", placemarks.count, error);
                
                for (CLPlacemark* place in placemarks) {
                    NSLog(@"\tPlacemark region: %@", place.region);
                    NSMutableDictionary* geoLoc = [location mutableCopy];
                    
                    CLCircularRegion* region = (CLCircularRegion*)place.region;
                    geoLoc[@"latitude"] = @(region.center.latitude);
                    geoLoc[@"longitude"] = @(region.center.longitude);
                    geoLoc[@"radius"] = @(region.radius);
                    [doneArray addObject:geoLoc];
                    
                    bool success = [doneArray writeToFile:filePath atomically:NO];
                    NSLog(@"Writing to file: %@ returned: %@", filePath, (success?@"YES":@"NO"));
                    
                }
            }];
//            NSLog(@"Operations count %lu", (unsigned long)researchQueue.operationCount);
        }];
    }
    
//    NSLog(@"Operations remaining %lu", (unsigned long)researchQueue.operationCount);
    
    //Print the results when done
    [researchQueue waitUntilAllOperationsAreFinished];
//    NSLog(@"Done: %@", doneArray);
}


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorized) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCLAuthorizationStatusAuthorized" object:self];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    NSLog(@"Got new locations: %@", locations);

    bool found = NO;
    static bool notified = NO;
    static UILocalNotification* notification = nil;
    CLLocation* location = locations.firstObject;
    
    for (CLCircularRegion* region in regions) {
        if ([region containsCoordinate:location.coordinate]) {
            if (!notified && !notification) {
                notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:600];  //10 minutes
                notification.alertTitle = kInERAlertTitle;
                notification.alertBody = kInERAlertBody;
                notification.alertAction = @"Call Rep";
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                
                notified = YES;
            }
            
            found = YES;
            break;
        } else {
            if (notification) {
                //We've left the geofence, cancel the alert
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
                notification = nil;
            }
        }
    }
    
    if (!found) notified = NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    //Need to react to errors here in case our geo-fences don't work or user has disabled some forms of tracking.
    //CLError
    NSLog(@"Got location error: %@", error);
}

@end
