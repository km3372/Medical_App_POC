//
//  BaseViewController.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomNavigationBar.h"
#import "BottomBarView.h"

@interface BaseViewController : UIViewController

- (void)addNavigationBarLeftButtonType:(LeftNavButtonType)type andTitle:(NSString *)title;

- (void)addBottomBarViewWithType:(BottomBarType)type;

- (void)leftNavButtonClicked:(id)sender;

- (void)callForHelp;

@end
