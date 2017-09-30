//
//  ProgressView.h
//  Dreamverse
//
//  Created by Sumeet on 2/9/15.
//  Copyright (c) 2015 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

// types of item shape.
typedef NS_ENUM(NSInteger, ItemType){
    ItemTypeCircle,
    ItemTypeSemiCircle,
    ItemTypeRectangle,
    ItemTypeRoundedRect,
    ItemTypeStar
};// default is circle

// horz. alignment for items.
typedef NS_ENUM(NSInteger, ItemHorzAlignment){
    ItemHorzAlignmentCenter,
    ItemHorzAlignmentLeft,
    ItemHorzAlignmentRight
};// default is center

// vert. alignment for items.
typedef NS_ENUM(NSInteger, ItemVertAlignment){
    ItemVertAlignmentMiddle,
    ItemVertAlignmentTop,
    ItemVertAlignmentBottom
};// default is middle 

IB_DESIGNABLE
@interface ProgressView : UIView

@property (nonatomic) IBInspectable NSInteger currentItemIndex;
// starts from zero.

@property (nonatomic) IBInspectable ItemType itemType;
// default item type is circle.

@property (nonatomic) IBInspectable ItemHorzAlignment itemHorzAlignment;
// default horizental alignment is center.

@property (nonatomic) IBInspectable ItemVertAlignment itemVertAlignment;
// default vertical alignment is middle.

@property (nonatomic) IBInspectable NSInteger numbersOfItem;
// number of item on progress view default 0.

@property (nonatomic) IBInspectable CGFloat sizeOfItem;
// size of each item i.e height, width or radius of item.

@property (nonatomic) IBInspectable CGFloat spaceBetweenItems;
// distance between two items.

@property (nonatomic) IBInspectable NSInteger numberOfFilledItem;

@property (nonatomic) IBInspectable UIColor *strokeColor;

@property (nonatomic) IBInspectable UIColor *defaultFillColor;
// default color for all items is grayColor.

@property (nonatomic) IBInspectable UIColor *selectedFillColor;
// highlighted color for selected or current item, default is white color.

- (void)nextItem;
// moves to next item i.e currentItemIndex is incremented by 1.

- (void)previousItem;
// moves to previous item i.e currentItemIndex is decremented by 1.

- (void)rotateForwardWithInterval:(NSTimeInterval)interval;
// items are continuously rotated in forward direction.

- (void)rotateBackwardWithInterval:(NSTimeInterval)interval;
// items are continuously rotated in backward direction.

- (void)forwardBackwardWithInterval:(NSTimeInterval)interval;
// items are continuously marqueed in forward/backward direction.

- (void)stopAnimationAndRemoveView:(BOOL)remove;
// will stop the items rotation and if remove flag is Yes will remove view from superview.

@end
