//
//  PointsRewardsCell.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 14/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RewardsCatalogModel.h"

@interface PointsRewardsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


- (void)setUpCellWithModel:(RewardsCatalogModel*)model;

@end
