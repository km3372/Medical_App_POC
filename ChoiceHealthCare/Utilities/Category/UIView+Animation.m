//
//  UIView+Animation.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 24/04/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)


- (void)shakeAnimation {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = 0.15;
    animation.repeatCount = 2;
    [animation setAutoreverses:YES];
    animation.fromValue = [NSValue valueWithCGPoint:
                             CGPointMake(self.center.x - 5.0f, self.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:
                           CGPointMake(self.center.x + 5.0f, self.center.y)];
    
    [self.layer addAnimation:animation forKey:@"position"];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
