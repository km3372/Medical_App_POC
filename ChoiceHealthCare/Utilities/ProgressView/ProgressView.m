//
//  ProgressView.m
//  Dreamverse
//
//  Created by Sumeet on 2/9/15.
//  Copyright (c) 2015 Sumeet. All rights reserved.
//

#import "ProgressView.h"

#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

@interface ProgressView (){
    BOOL isBackward;
    BOOL isStop;
}

@end

@implementation ProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self defaultSetUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultSetUp];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self defaultSetUp];
    }
    return self;
}


- (void)defaultSetUp{
    self.backgroundColor    = [UIColor clearColor];
    self.defaultFillColor   = [UIColor lightGrayColor];
    self.selectedFillColor  = [UIColor blackColor];
    self.strokeColor        = [UIColor clearColor];
    self.itemHorzAlignment  = ItemHorzAlignmentCenter;
    self.itemVertAlignment  = ItemVertAlignmentMiddle;
    self.itemType           = ItemTypeCircle;
    self.currentItemIndex   = 0;
    self.spaceBetweenItems  = 0;
    self.numbersOfItem      = 0;
    self.numberOfFilledItem = 0;
}

#pragma mark - Setter

- (void)setCurrentItemIndex:(NSInteger)currentItemIndex {
    
    _currentItemIndex = currentItemIndex;
    
    [self setNeedsDisplay];
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect {
    
    CGFloat startPoint = [self getXPoint];
    CGFloat yPoint = [self getYPoint];
    [self.strokeColor setStroke];

    for (NSInteger i = 0 ; i <= self.numbersOfItem - 1; i++) {
        float xPoint = startPoint + (i * self.sizeOfItem ) + (i * self.spaceBetweenItems);
        CGRect frame = CGRectMake(xPoint,yPoint,self.sizeOfItem,self.sizeOfItem);
       
        UIBezierPath * path ;

        switch (self.itemType) {
            case ItemTypeCircle:     path = [UIBezierPath bezierPathWithOvalInRect:frame];
            break;
            case ItemTypeRectangle:  path = [UIBezierPath bezierPathWithRect:frame];
            break;
            case ItemTypeSemiCircle: path = [self createSemiCirlce:CGPointMake(xPoint+self.sizeOfItem/2, yPoint)];
            break;
            case ItemTypeRoundedRect:path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:frame.size.width/4];
            break;
            case ItemTypeStar:       path = [self drawStarBezierAt:xPoint yPoint:yPoint radius:self.sizeOfItem/3 sides:5 pointyness:2.7];
            break;
        }
        [path stroke];
        self.currentItemIndex == i ? [self.selectedFillColor setFill] : [self.defaultFillColor setFill];
        self.numberOfFilledItem > i ? [path fill] : nil;
    }
}

#pragma mark - SemiCircle Shape

- (UIBezierPath *)createSemiCirlce:(CGPoint)point{
    
    UIBezierPath *aPath = [UIBezierPath bezierPathWithArcCenter:point
                                                         radius:self.sizeOfItem/2
                                                     startAngle:0
                                                       endAngle:DEGREES_TO_RADIANS(180)
                                                      clockwise:NO];
    return aPath;
}


#pragma mark - Star Shape

- (UIBezierPath *)drawStarBezierAt:(CGFloat)x
                            yPoint:(CGFloat)y
                            radius:(CGFloat)rad
                             sides:(NSInteger)s
                        pointyness:(CGFloat)p
{
    CGPathRef path = [self starPathWithXPoint:x yPoint:y radius:rad sides:s pointyness:p];    
    UIBezierPath *bez = [UIBezierPath bezierPathWithCGPath:path];
    return bez;
}

- (CGPathRef)starPathWithXPoint:(CGFloat)x
                         yPoint:(CGFloat)y
                         radius:(CGFloat)rad
                          sides:(NSInteger)s
                     pointyness:(CGFloat)p
{
    CGFloat adjustment = 360/s/2;
    CGMutablePathRef path = CGPathCreateMutable();
    
    NSArray *points = [self polygonPointArrayWithSides:s xPoint:x yPoint:y radius:rad adjustment:0];
    CGPoint cpg = [points[0] CGPointValue];
    
    NSArray *points2 = [self polygonPointArrayWithSides:s xPoint:x yPoint:y radius:rad*p adjustment:adjustment];
    int i = 0;
    CGPathMoveToPoint(path, nil, cpg.x, cpg.y);
    
    for (i = 0;i<points.count;++i ) {
        CGPoint p1 = [points[i] CGPointValue];
        CGPoint p2 = [points2[i] CGPointValue];
        CGPathAddLineToPoint(path, nil, p2.x, p2.y);
        CGPathAddLineToPoint(path, nil, p1.x, p1.y);
    }
    return path;
}

- (NSMutableArray *)polygonPointArrayWithSides:(NSInteger)sides
                                        xPoint:(CGFloat)x
                                        yPoint:(CGFloat)y
                                        radius:(CGFloat)rad
                                    adjustment:(CGFloat)adj{
       // x origin // y origin // radius of circle
    
    CGFloat angle = DEGREES_TO_RADIANS(360/(CGFloat)sides);
    NSInteger i = sides;
    NSMutableArray *points = [[NSMutableArray alloc] init];
    
    while (points.count <= sides) {
        CGFloat xpo = x + rad * cos(angle * (CGFloat)i + DEGREES_TO_RADIANS(adj)-60);
        CGFloat ypo = y + rad * sin(angle * (CGFloat)i + DEGREES_TO_RADIANS(adj)-60);
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(xpo,ypo)]];
        i--;
    }
    return points;
}

#pragma mark - Horz Alignment

- (CGFloat)getXPoint{
    CGFloat xPoint = 0;
    switch (self.itemHorzAlignment) {
        case ItemHorzAlignmentLeft:  xPoint = [self leftPoint]; break;
        case ItemHorzAlignmentRight: xPoint = [self rightPoint];break;
        case ItemHorzAlignmentCenter:xPoint = [self centerPoint];break;
    }
    return xPoint;
}

- (CGFloat)centerPoint{
    CGFloat width = self.frame.size.width;
    CGFloat reqWidth = self.numbersOfItem*self.sizeOfItem + (self.numbersOfItem-1)*self.spaceBetweenItems;
    if (width<=reqWidth) {
        return 0;
    }else{
        CGFloat xPoint = width/2 - (reqWidth/2);
        return xPoint;
    }
    return 0;
}

- (CGFloat)rightPoint{
    CGFloat width = self.frame.size.width;
      CGFloat reqWidth = self.numbersOfItem*self.sizeOfItem + (self.numbersOfItem-1)*self.spaceBetweenItems;
    if (width<=reqWidth) {
        return 0;
    }else{
        CGFloat xPoint = width - reqWidth - self.spaceBetweenItems;
        return xPoint;
    }
    return 0;
}

- (CGFloat)leftPoint{
    CGFloat width = self.frame.size.width;
    CGFloat reqWidth = self.numbersOfItem*self.sizeOfItem + (self.numbersOfItem-1)*self.spaceBetweenItems;
    if (width <= reqWidth) {
        return 0;
    }else{
        CGFloat xPoint = self.spaceBetweenItems;
        return xPoint;
    }
    return 0;
}

#pragma mark - Vert Alignment

- (CGFloat)getYPoint{
    CGFloat yPoint = 0;
    switch (self.itemVertAlignment) {
        case ItemVertAlignmentTop:    yPoint = [self topPoint]; break;
        case ItemVertAlignmentMiddle: yPoint = [self middlePoint];break;
        case ItemVertAlignmentBottom: yPoint = [self bottomPoint]; break;
    }
    return yPoint;
}

- (CGFloat)middlePoint{
    CGFloat height = self.frame.size.height;
    CGFloat reqHeight = self.sizeOfItem;
    if (height<=reqHeight) {
        return 0;
    }else{
        CGFloat yPoint = height/2-reqHeight/2;
        return yPoint;
    }
    return 0;
}

- (CGFloat)topPoint{
//    CGFloat height = self.frame.size.height;
//    CGFloat reqHeight = self.sizeOfItem;
//    if (height<=reqHeight) {
//        return 0;
//    }else{
//        CGFloat yPoint = height/2-reqHeight/2;
//        return yPoint;
//    }
    return 0;
}

- (CGFloat)bottomPoint{
    CGFloat height = self.frame.size.height;
    CGFloat reqHeight = self.sizeOfItem;
    if (height<=reqHeight) {
        return 0;
    }else{
        CGFloat yPoint = height-reqHeight;
        return yPoint;
    }
    return 0;
}

- (void)nextItem{
    if (self.currentItemIndex < self.numbersOfItem - 1) {
        ++self.currentItemIndex;
    }else{
        self.currentItemIndex = 0;
    }
    [self setNeedsDisplay];
}

- (void)previousItem{
    if (self.currentItemIndex > 0) {
        --self.currentItemIndex;
    }else{
        self.currentItemIndex = self.numbersOfItem-1;
    }
    [self setNeedsDisplay];
}

- (void)marquee{
    if (self.currentItemIndex < self.numbersOfItem - 1 && isBackward == false) {
        isBackward = false;
        ++self.currentItemIndex;
    }else{
        isBackward = true;
        --self.currentItemIndex;
        isBackward =  self.currentItemIndex == 0 ? false : true;
    }
    [self setNeedsDisplay];
}

#pragma mark - Auto Animate Items

- (void)rotateForwardWithInterval:(NSTimeInterval)interval{
    if (!isStop) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self nextItem];
            [self rotateForwardWithInterval:interval];
        });
    }
}

- (void)rotateBackwardWithInterval:(NSTimeInterval)interval{
    if (!isStop) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self previousItem];
            [self rotateBackwardWithInterval:interval];
        });
    }
}

- (void)forwardBackwardWithInterval:(NSTimeInterval)interval{
    if (!isStop) {
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self marquee];
            [self forwardBackwardWithInterval:interval];
        });
    }
}

- (void)stopAnimationAndRemoveView:(BOOL)remove{
    isStop = true;
    if (remove) {
        [self removeFromSuperview];
    }
}

@end
