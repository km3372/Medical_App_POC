//
//  Utils.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 16/01/16.
//  Copyright © 2016 Sumeet Bajaj. All rights reserved.
//

#import "Utils.h"
#import <UIKit/UIKit.h>
#import "CHCConstants.h"


@implementation Utils


+ (BOOL)validateEmail:(NSString *)email {
    
    if(email.length == 0) {
        
        [self showAlertForString:@"Email field should not be empty"];
        
        return NO;
    }
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:email options:0 range:NSMakeRange(0, email.length)];
    if (regExMatches == 0) {
        
        [self showAlertForString:@"Enter valid email Id"];
        
        return NO;
    }
    else {
        return YES;
    }
}

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


/**
 *  This method will show the alert for passed message with OK button
 *
 *  @param message message to be shown on alert
 */
+ (void)showAlertForString:(NSString *)message {
    
    message = (message == nil || message.length <= 0) ? @"Something went wrong please try again" : message;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [alert show];
}


@end
