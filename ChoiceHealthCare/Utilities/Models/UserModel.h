//
//  UserModel.h
//  ChoiceHealthCare
//
//  Created by Chris Morse on 8/24/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UserModel : NSObject <NSCoding>

//User profile
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* firstName;
@property (nonatomic, strong) NSString* lastName;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) NSString* phoneNumber;
@property (nonatomic, strong) NSDate*   dob;
@property (nonatomic, strong) NSString* gender;
@property (nonatomic, strong) NSURL* profileImageURL;
@property (nonatomic, strong) NSString* register_survey;

//Points stuff
@property (nonatomic, strong) NSNumber* pointTotal;

//Session stuff
@property (nonatomic, strong) NSString* sessionToken;
@property (nonatomic, strong) NSDate*   sessionExpiration;

//APNS token stuff
@property (nonatomic, strong) NSString* deviceToken;
@property (nonatomic, strong) NSNumber* qbRegistered;

//Badges
@property (nonatomic, strong) NSNumber* badgeTotalCount;
@property (nonatomic, strong) NSNumber* badgeAppointmentCount;
@property (nonatomic, strong) NSNumber* badgeSurveyCount;
@property (nonatomic, strong) NSNumber* badgeWellnessCount;

//Display helpers
@property (nonatomic, readonly) NSString* fullName;


+ (UserModel*)currentUser;

- (void)updateWithDictionary:(NSDictionary*)data;
- (void)discardSession;
- (void)synchronizeUser;

@property (NS_NONATOMIC_IOSONLY, getter=isSessionExpired, readonly) BOOL sessionExpired;
@property (NS_NONATOMIC_IOSONLY, getter=isLoggedIn, readonly) BOOL loggedIn;

@property (NS_NONATOMIC_IOSONLY, readonly, strong) UIImage *profileImage;

@end
