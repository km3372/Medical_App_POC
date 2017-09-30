//
//  CustomView.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 04/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "CustomView.h"

@implementation CustomView


- (void)setShouldCircularBorder:(BOOL)ShouldCircularBorder {
    
    if (ShouldCircularBorder == true) {
        self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    } else {
        self.layer.cornerRadius = _cornerRadius;
    }
    _ShouldCircularBorder = ShouldCircularBorder;
}


- (void)setCornerRadius:(CGFloat)cornerRadius {
    
    if (self.ShouldCircularBorder == false) {
        self.layer.cornerRadius = cornerRadius;
    }
    
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
    
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    
    self.layer.borderWidth = borderWidth;
    
    [self setNeedsDisplay];
    
    _borderWidth = borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor {
    
    self.layer.borderColor = borderColor.CGColor;
    [self setNeedsDisplay];
    
    _borderColor = borderColor;
}


@end
