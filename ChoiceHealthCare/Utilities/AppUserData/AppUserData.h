//
//  AppUserData.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 17/01/16.
//  Copyright © 2016 Sumeet Bajaj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUserData : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *emailId;
@property (nonatomic, strong) NSString *usetId;
@property (nonatomic, strong) NSString *pinString;
@property (nonatomic, strong) NSString *password;
@end

