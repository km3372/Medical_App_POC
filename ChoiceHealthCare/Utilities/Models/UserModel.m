//
//  UserModel.m
//  ChoiceHealthCare
//
//  Created by Chris Morse on 8/24/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "UserModel.h"
#import <Security/Security.h>
#import <UIKit/UIKit.h>

static UserModel *sharedInstance = nil;
static NSString* const kUserDefaultsKey = @"com.localmarketinginc.choice";

@implementation UserModel {
    NSDateFormatter* formatter;
}

@dynamic fullName;

- (instancetype)init {
    self = [super init];
    self.pointTotal = @0;
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";

    return self;
}

#pragma mark - NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.userId            forKey:@"userId"];
    [aCoder encodeObject:self.pointTotal        forKey:@"pointTotal"];
    [aCoder encodeObject:self.sessionToken      forKey:@"sessionToken"];
    [aCoder encodeObject:self.sessionExpiration forKey:@"sessionExpiration"];

    [aCoder encodeObject:self.phoneNumber       forKey:@"phoneNumber"];
    [aCoder encodeObject:self.register_survey   forKey:@"register_survey"];
    [aCoder encodeObject:self.email             forKey:@"email"];
    [aCoder encodeObject:self.password          forKey:@"password"];

    [aCoder encodeObject:self.qbRegistered      forKey:@"qbRegistered"];
    [aCoder encodeObject:self.deviceToken       forKey:@"deviceToken"];

    [aCoder encodeObject:self.firstName         forKey:@"firstName"];
    [aCoder encodeObject:self.lastName          forKey:@"lastName"];
    [aCoder encodeObject:self.dob               forKey:@"dob"];
    [aCoder encodeObject:self.gender            forKey:@"gender"];
    [aCoder encodeObject:self.profileImageURL   forKey:@"profileImageURL"];

    [aCoder encodeObject:self.badgeTotalCount           forKey:@"badgeTotalCount"];
    [aCoder encodeObject:self.badgeAppointmentCount     forKey:@"badgeAppointmentCount"];
    [aCoder encodeObject:self.badgeSurveyCount          forKey:@"badgeSurveyCount"];
    [aCoder encodeObject:self.badgeWellnessCount        forKey:@"badgeWellnessCount"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";


    self.userId             = [aDecoder decodeObjectForKey:@"userId"];
    self.pointTotal         = [aDecoder decodeObjectForKey:@"pointTotal"];
    self.sessionToken       = [aDecoder decodeObjectForKey:@"sessionToken"];
    self.sessionExpiration  = [aDecoder decodeObjectForKey:@"sessionExpiration"];
    
    self.phoneNumber        = [aDecoder decodeObjectForKey:@"phoneNumber"];
    self.register_survey    = [aDecoder decodeObjectForKey:@"register_survey"];
    
    self.email              = [aDecoder decodeObjectForKey:@"email"];
    self.password           = [aDecoder decodeObjectForKey:@"password"];

    self.qbRegistered       = [aDecoder decodeObjectForKey:@"qbRegistered"];
    self.deviceToken        = [aDecoder decodeObjectForKey:@"deviceToken"];

    self.firstName          = [aDecoder decodeObjectForKey:@"firstName"];
    self.lastName           = [aDecoder decodeObjectForKey:@"lastName"];
    self.dob                = [aDecoder decodeObjectForKey:@"dob"];
    self.gender             = [aDecoder decodeObjectForKey:@"gender"];

    self.badgeTotalCount        = [aDecoder decodeObjectForKey:@"badgeTotalCount"];
    self.badgeAppointmentCount  = [aDecoder decodeObjectForKey:@"badgeAppointmentCount"];
    self.badgeSurveyCount       = [aDecoder decodeObjectForKey:@"badgeSurveyCount"];
    self.badgeWellnessCount     = [aDecoder decodeObjectForKey:@"badgeWellnessCount"];


    NSObject* profileUrl = [aDecoder decodeObjectForKey:@"profileImageURL"];
    if ([profileUrl isKindOfClass:[NSURL class]]) {
        self.profileImageURL = (NSURL*)profileUrl;
    } else if ([profileUrl isKindOfClass:[NSString class]]) {
        NSURL* url = [NSURL URLWithString:(NSString*)profileUrl];
        self.profileImageURL = url;
    } else {
        self.profileImageURL = nil;
    }

    return self;
}

- (void)updateWithDictionary:(NSDictionary*)data {
    //User profile stuff
    NSDictionary* user = data[@"user"];
    self.userId             = [self objectFromDictionary:user forKey:@"uid"];
    self.firstName          = [self objectFromDictionary:user forKey:@"first_name"];
    self.lastName           = [self objectFromDictionary:user forKey:@"last_name"];
    self.email              = [self objectFromDictionary:user forKey:@"email"];
    self.phoneNumber        = [self objectFromDictionary:user forKey:@"phone"];
    self.gender             = [self objectFromDictionary:user forKey:@"gender"];
    self.profileImageURL    = [self objectFromDictionary:user forKey:@"profile"];
    self.register_survey    = [self objectFromDictionary:user forKey:@"register_survey"];
    

    NSString* dob           = [self objectFromDictionary:user forKey:@"date_of_birth"];
    if (dob) self.dob       = [formatter dateFromString:dob];

    //Points stuff
    NSDictionary* points = data[@"points"];
    self.pointTotal         = [self objectFromDictionary:points forKey:@"pointTotal"];

    //Session token stuff
    NSDictionary* token = data[@"token"];
    self.sessionToken       = [self objectFromDictionary:token forKey:@"value"];
    self.sessionExpiration  = [NSDate dateWithTimeIntervalSince1970:[token[@"expires"] doubleValue]];
}

- (id)objectFromDictionary:(NSDictionary*)dictionary forKey:(NSString*)key {
    NSObject* object = dictionary[key];
    if ([object isEqual:[NSNull null]])
        return nil;
    else
        return object;
}

#pragma mark - Helper methods
+ (UserModel*)currentUser {
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsKey];
            UserModel* model = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if (!model) {
                model = [[UserModel alloc] init];
            }
//            model.userId = @"8";    // TODO:DELETE ME
//            model.sessionExpiration = [NSDate distantPast];
            sharedInstance = model;
        });
    }
    return sharedInstance;
}

- (void)discardSession {
    self.userId = nil;
    self.pointTotal = nil;
    self.sessionToken = nil;
    self.sessionExpiration = nil;
    self.phoneNumber = nil;
    self.email = nil;
    self.password = nil;
    self.qbRegistered = nil;
    self.deviceToken = nil;
    self.firstName = nil;
    self.lastName = nil;
    self.dob = nil;
    self.gender = nil;
    self.profileImageURL = nil;
    self.register_survey = nil;

    self.badgeTotalCount = nil;
    self.badgeAppointmentCount = nil;
    self.badgeSurveyCount = nil;
    self.badgeWellnessCount = nil;

    [self synchronizeUser];
}

- (void)synchronizeUser {
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)fullName {
    NSString* name = [NSString stringWithFormat:@"%@ %@",
                      self.firstName ? self.firstName : @"",
                      self.lastName ? self.lastName : @""];
    return name;
}

- (BOOL)isLoggedIn {
    //TODO: This test should really be much more comprehensive
    return (self.sessionToken != nil);
}

- (BOOL)isSessionExpired {
    return ([self.sessionExpiration earlierDate:[NSDate new]] == self.sessionExpiration);
}

- (UIImage*)profileImage {
    if (self.profileImageURL && ![self.profileImageURL isKindOfClass:[NSNull class]]) {
        NSURL* url = self.profileImageURL;
        if (url) {
            NSData* data = [NSData dataWithContentsOfURL:url];
            if (data) {
                return [UIImage imageWithData:data];
            }
        }
    }
    return [UIImage imageNamed:@"profilephoto.png"];
}

@end
