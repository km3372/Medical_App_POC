//
//  ActivityScaleView.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 14/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ActivityScaleView.h"


@implementation ActivityScaleView


- (void)setPercentage:(CGFloat)percentage {
    
    _percentage = percentage;
    
    [self setNeedsDisplay];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    
    _lineWidth = lineWidth;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];

    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CAGradientLayer *layer = [CAGradientLayer new];
    
    NSArray *colors = @[(id)[UIColor redColor].CGColor,(id)[UIColor orangeColor].CGColor,(id)[UIColor yellowColor].CGColor,(id)[UIColor greenColor].CGColor];
    
    layer.colors = colors;
    layer.locations = @[@(0.0), @(0.25), @(0.75), @(1.0)];
    layer.startPoint = CGPointMake(0.0, 0.0);
    layer.endPoint = CGPointMake(1.0,0.0);
    
    layer.frame = CGRectMake(0, 2, rect.size.width, rect.size.height -4);
    
    [layer renderInContext:context];
    
    layer.position = CGPointMake(rect.size.width/2, rect.size.height/2);
    layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    [layer layoutIfNeeded];
    
    CGFloat width = CGRectGetWidth(rect);
    
    self.percentage = self.percentage > 100 ? 100 : self.percentage;
    self.percentage = self.percentage < 0 ? 0 : self.percentage;
    
    CGFloat xPoint = ((width/100) * self.percentage);

    xPoint = MAX(self.lineWidth/2 + 0.5, xPoint - 0.5);
    xPoint = MIN(xPoint - 0.5, rect.size.width - self.lineWidth/2);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextMoveToPoint(context, xPoint  , 0);
    CGContextAddLineToPoint(context, xPoint, rect.size.height);
    CGContextDrawPath(context, kCGPathStroke);
}



@end
