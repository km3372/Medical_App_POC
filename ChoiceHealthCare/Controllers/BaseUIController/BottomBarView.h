//
//  BottomBarView.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  NS_ENUM(NSInteger, BottomBarType) {
    
    BottomBarTypeDefault = 0,
    BottomBarTypeTwo = 1
    
    
};

typedef NS_ENUM(NSInteger, ButtonType) {
    
    ButtonTypeGetHelp = 0,
    ButtonTypeMyApps = 1,
    ButtonTypeMyMeds = 2,
    ButtonTypePoints = 3
    
};

@protocol BottomBarViewDelegate <NSObject>

@optional
- (void)bottomBarButtonClickedForType:(ButtonType)type;

@end

@interface BottomBarView : UIView

+ (BottomBarView *)createBottomBarWithType:(BottomBarType)type;
- (void)updatePointsCount;

@property (nonatomic, weak) id<BottomBarViewDelegate>delegate;

@end
