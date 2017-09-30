//
//  CustomView.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 04/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface CustomView : UIView

@property (nonatomic, assign) IBInspectable BOOL ShouldCircularBorder;

@property (nonatomic, assign) IBInspectable CGFloat cornerRadius;

@property (nonatomic, assign) IBInspectable CGFloat borderWidth;

@property (nonatomic, strong) IBInspectable UIColor *borderColor;

@end
