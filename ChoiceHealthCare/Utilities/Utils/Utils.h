//
//  Utils.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 16/01/16.
//  Copyright © 2016 Sumeet Bajaj. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject

/**
 *  This method will validate the email id for provide string. Also the alert will be shown for invalid email Id.
 *
 *  @param email email string to be validated
 *
 *  @return Boolean value if string is vaild True else False
 */
+ (BOOL)validateEmail:(NSString *)email;

/**
 *  This method will show the alert for passed message with OK button
 *
 *  @param message message to be shown on alert
 */
+ (void)showAlertForString:(NSString *)message;

@end
