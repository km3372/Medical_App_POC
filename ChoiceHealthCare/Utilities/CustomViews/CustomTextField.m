//
//  CustomTextField.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 24/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField


- (void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    NSDictionary *attributes = @{NSForegroundColorAttributeName: placeHolderColor};
    self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributes];
    
    _placeHolderColor = placeHolderColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
