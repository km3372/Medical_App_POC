//
//  CustomNavigationBar.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GIBadgeView.h"

typedef NS_ENUM(NSInteger, LeftNavButtonType) {
    
    LeftNavButtonTypeMenu,
    LeftNavButtonTypeBack
};

@interface CustomNavigationBar : UIView

@property (nonatomic, weak) IBOutlet UIButton *leftNavButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) GIBadgeView *badgeView;
@property (nonatomic, weak) IBOutlet UIImageView *profileImageView;

-(CustomNavigationBar *)createNavBarWithLeftButtonType:(LeftNavButtonType)type andTitle:(NSString *)title;
+(CustomNavigationBar*) sharedInstance;
-(void)setBadgeValue: (NSInteger) value;

@end
