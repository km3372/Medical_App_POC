//
//  CHCConstants.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/17/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kInERPhoneNumber = @"tel://4046881350";
static NSString * const kInERAlertTitle = @"Are you waiting for ER services?";
static NSString * const kInERAlertBody = @"We are here to help you. We noticed that you are in the ER. Can we ask one of our reps to help you?";


static NSString * const kTokenValue     = @"tokenValue";
static NSString * const kTokenString    = @"tokenString";
static NSString * const kUid            = @"uid";
static NSString * const kAppName        = @"ChoiceHealthCare";
static NSString * const kRequestFailed  = @"No Internet Connection";
static NSString * const kSigning        = @"signing";
static NSString * const kRenderType     = @"render_type";
static NSString * const kSingle         = @"single";
static NSString * const kMultiple       = @"multiple";
static NSString * const kCHC            = @"CHC";
static NSString * const kChildList      = @"child_list";
static NSString * const kNumeric        = @"numeric";
static NSString * const kHome           = @"home";
static NSString * const kCustom         = @"custom";
static NSString * const kRemid          = @"remid";
static NSString * const kSpecId         = @"specid";
static NSString * const kStatus         = @"status";
static NSString * const kSid            = @"sid";
static NSString * const kQidA           = @"qid";

static NSString * const kHowSoon        = @"how_soon";
static NSString * const kDayweek        = @"dayweek";
static NSString * const kTimeday        = @"timeday";
static NSString * const kFirstName      = @"first_name";
static NSString * const kLastName       = @"last_name";
static NSString * const kDob            = @"dob";
static NSString * const kGender         = @"gender";
static NSString * const kPhone          = @"phone";
static NSString * const kEmail          = @"email";
static NSString * const kReason         = @"reason";
static NSString * const kInfo           = @"info";
static NSString * const kPayment        = @"payment";
static NSString * const kReqId          = @"reqid";
static NSString * const kTosStamp       = @"tos_timestamp";

static NSString * const kMed            = @"med";
static NSString * const kType           = @"type";
static NSString * const kFrequency      = @"frequency";
static NSString * const kDose           = @"dose";
static NSString * const kInternetConnectionNotAvailable= @"No internet connection.";

// Server Constants
static NSString * const kFullName           = @"full_name";
static NSString * const kDateOfBirth        = @"date_of_birth";
static NSString * const kPassword           = @"password";
static NSString * const kConfirmPassword    = @"confirm_password";
static NSString * const kPin                = @"pin";
static NSString * const kUserId             = @"uid";

//UI Constants
static NSString * const kSearchDetailsPrefixString   = @"< Search by";
static NSString * const kSearchSpecilityString   = @"Speciality:";
static NSString * const kSearchLocationString   = @"Location:";
static NSString * const kSearchNameString   = @"Name:";

//Messages
static NSString * const kNoDoctorsFoundString = @"No doctors found";

//Quickblox Settings
static NSUInteger const kQuickbloxAppId         = 46256;
static NSString * const kQuickbloxAuthKey       = @"zAELUvXxbPyUvFg";
static NSString * const kQuickbloxAuthSecret    = @"UB2FQvRmWSFHFmt";
static NSString * const kQuickbloxAccountKey    = @"ZFXJB7i1v2SMAvHdpC4T";


//Colors
#define STATUS_BAR_BACKGROUND_COLOR [UIColor whiteColor]
#define STATUS_TEXT_COLOR [UIColor whiteColor]
#define NAV_CONTROLLER_TEXT_COLOR [UIColor whiteColor]
#define CHOICE_LIGHT_BLUE [UIColor colorWithRed: 41.0/255.0 green:164.0/255.0 blue:219.0/255.0 alpha:1.0]

//Enums
typedef NS_ENUM(unsigned int, SearchType) {
    SearchTypeSpeciality,
    SearchTypeLocation,
    SearchTypeName,
};

//Enums
typedef NS_ENUM(unsigned int, QuestionType) {
    QuestionTypeNationality,
    QuestionTypeMedical,
    QuestionTypeRace,
};
