//
//  CustomButton.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 24/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface CustomButton : UIButton

@property (nonatomic, assign) IBInspectable BOOL ShouldCircularBorder;

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

@property (nonatomic, strong) IBInspectable UIColor *borderColor;

@property (nonatomic, strong) IBInspectable UIColor *normalBGColor;

@property (nonatomic, strong) IBInspectable UIColor *highlightedBGColor;

@property (nonatomic, strong) IBInspectable UIColor *selectedBGColor;

@end
