//
//  RevealViewCell.m
//  ChoiceHealthCare
//
//  Created by Chris Morse on 9/8/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "RevealViewCell.h"
#import "GIBadgeView.h"

@implementation RevealViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

    GIBadgeView *badgeView = [GIBadgeView new];
    badgeView.topOffset = 2;
    badgeView.rightOffset = -10;

    [self.menuLabel addSubview:badgeView];
    self.badgeView = badgeView;

}

@end
