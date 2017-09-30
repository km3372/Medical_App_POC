//
//  CustomButton.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 24/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "CustomButton.h"
#import "UIImage+Extension.h"

@implementation CustomButton

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

- (void)setNormalBGColor:(UIColor *)normalBGColor {
    
    UIImage *bgImage = [UIImage getImageFromColor:normalBGColor andSize:self.bounds.size];
    
    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    
    _normalBGColor = normalBGColor;
}

- (void)setHighlightedBGColor:(UIColor *)highlightedBGColor {
 
    UIImage *bgImage = [UIImage getImageFromColor:highlightedBGColor andSize:self.bounds.size];
    
    [self setBackgroundImage:bgImage forState:UIControlStateHighlighted];
    
    _highlightedBGColor = highlightedBGColor;
}

- (void)setSelectedBGColor:(UIColor *)selectedBGColor {
    
    UIImage *bgImage = [UIImage getImageFromColor:selectedBGColor andSize:self.bounds.size];
    
    [self setBackgroundImage:bgImage forState:UIControlStateSelected];
    
    _selectedBGColor = selectedBGColor;    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    self.exclusiveTouch = true;
}


@end
