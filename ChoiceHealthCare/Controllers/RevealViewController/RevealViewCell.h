//
//  RevealViewCell.h
//  ChoiceHealthCare
//
//  Created by Chris Morse on 9/8/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GIBadgeView.h"

@interface RevealViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *menuLabel;
@property (weak, nonatomic) GIBadgeView *badgeView;

@end
