//
//  LocationManager.h
//
//  Created by Chris Morse on 6/2/14.
//  Copyright (c) 2014. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>

@class Location;



@interface LocationManager : NSObject <CLLocationManagerDelegate>

+ (LocationManager*) sharedLocationManager;
+ (CLLocation*)currentLocation;

@end
