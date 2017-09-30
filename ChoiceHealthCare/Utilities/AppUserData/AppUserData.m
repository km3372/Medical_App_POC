//
//  AppUserData.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 17/01/16.
//  Copyright © 2016 Sumeet Bajaj. All rights reserved.
//

#import "AppUserData.h"

@implementation AppUserData

+ (instancetype)sharedInstance
{
    static AppUserData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppUserData alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

@end
