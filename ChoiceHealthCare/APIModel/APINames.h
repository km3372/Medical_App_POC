//
//  APINames.h
//  Dreamverse
//
//  Created by Mindbowser on 06/02/14.
//  Copyright (c) 2014 Mindbowser. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kImageIP = @"https://reapon.com/";


// User Web Services

static NSString * const kPointTotal             = @"pointTotal";
static NSString * const kLogin                  = @"user/login";
static NSString * const kSignUp                 = @"user/register";
static NSString * const kUpdateProfileImage     = @"user/update_profile_image";
static NSString * const kFetchJSON              = @"articles/fetch/json";
static NSString * const kArticlesArchiveJSON    = @"articles/archive/json";
static NSString * const kArticleRead            = @"/articles/read/";

static NSString * const kVerifyPin              = @"user/verify_pin";
static NSString * const kForgetPin              = @"user/forgot_pin";
static NSString * const kUpdateProfile          = @"user/update_profile";


static NSString * const kSurvey                 = @"survey/getNextQuestion";
static NSString * const kGetQuestion            = @"survey/getQuestion";
static NSString * const kAnswerQuestion         = @"survey/answerQuestion";
static NSString * const kFetchSurvey            = @"survey/fetch";
static NSString * const kGetPoints              = @"user/points";
static NSString * const kGetCHC                 = @"survey/get_chc";
static NSString * const kGetLoggerCategories    = @"logger/categories";
static NSString * const kDoctorFindBySpecialty  = @"doctor/find_by_specialty";
static NSString * const kDoctorFindByLocation   = @"/doctor/find_by_location";
static NSString * const kDoctorFindByName       = @"doctor/find_by_name";
static NSString * const kRewardsFetch           = @"rewards/fetch/json";
static NSString * const kRewardsClaim           = @"rewards/claim";
static NSString * const kTodoFetchList          = @"todo/fetch";
static NSString * const kWellnessFetchList      = @"wellness/fetch";
static NSString * const kMedicationsFetchList   = @"medications/fetch";
static NSString * const kMedicationsEnable      = @"medications/enable";
static NSString * const kMedicationsDisable     = @"medications/disable";

static NSString * const kRemindersFetchList     = @"reminders/fetch/list";
static NSString * const kRemindersFetchOne      = @"reminders/fetch/one";
static NSString * const kRemindersCreate        = @"reminders/create";
static NSString * const kUserScorecard          = @"user/scorecard";

static NSString * const kAppointmentSetLatAndLong   = @"appointment/set_lat_and_long";
static NSString * const kGetLoggerInsertJson    = @"logger/insert/json";
static NSString * const kGetLoggerView          = @"logger/view/";
static NSString * const kGetLoggerViewAll       = @"logger/view/all";
static NSString * const KUsername               = @"username";
//static NSString * const kPassword               = @"password";
static NSString * const kQid                    = @"qid";
static NSString * const kAnswerid               = @"answerid";
static NSString * const kAnswers                = @"answers";
static NSString * const kGeo_Lat                = @"geo_lat";
static NSString * const kGeo_Long               = @"geo_long";
static NSString * const kGetAppointmentListSpecialties  = @"appointment/list_specialties";
static NSString * const kAppointmentChooseDoctor= @"appointment/choose_doctor";
static NSString * const kAppointmentSubmit  = @"appointment/submit";
static NSString * const kAppointmentFetch  = @"appointment/fetch";
static NSString * const kAppointmentEdit  = @"appointment/edit";

static NSString * const kSpecid             = @"specid";
static NSString * const kDoctorName         = @"doctor_name";
static NSString * const kDocid             = @"docid";

static NSString * const kModePost           = @"POST";
static NSString * const kModeGet            = @"GET";
static NSString * const kModeDelete         = @"DELETE";
static NSString * const kModePut            = @"PUT";


