//
//  PointsRewardsCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 14/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "PointsRewardsCell.h"
#import "CommonFilesImporter.h"


@implementation PointsRewardsCell

- (void)setUpCellWithModel:(RewardsCatalogModel*)model {
    
    NSString* title = [NSString stringWithFormat:@"%@ for %@ points", model.rewardTitle,model.rewardPointValue];
    self.titleLabel.text = title;
    
    [self.iconImageView setImageWithURL:model.rewardImageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];

}

@end

