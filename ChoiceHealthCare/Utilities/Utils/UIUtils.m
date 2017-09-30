//
//  UIUtils.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 24/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "UIUtils.h"

@implementation UIUtils

+ (void)setStatusBarColor:(UIColor *)color {
    
    UIView *view = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    
    if (view) {
        view.backgroundColor = color;
    }
}

@end
