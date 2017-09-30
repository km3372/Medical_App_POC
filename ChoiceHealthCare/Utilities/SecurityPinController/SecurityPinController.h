//
//  SecurityPinController.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 16/01/16.
//  Copyright © 2016 Sumeet Bajaj. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(unsigned int, UserType) {
    UserTypeNew = 0,
    UserTypeOld = 1
    
};


typedef void (^CompletionBlock)(NSString *resultPin, id controller);

@interface SecurityPinController : UIViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil userType:(UserType)type completionBlock:(CompletionBlock)block NS_DESIGNATED_INITIALIZER;

- (void)showWrongPingAnimationAlert;

@end
