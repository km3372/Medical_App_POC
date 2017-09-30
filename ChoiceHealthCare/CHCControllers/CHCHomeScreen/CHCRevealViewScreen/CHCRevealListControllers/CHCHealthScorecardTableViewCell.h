//
//  CHCHealthScorecardTableViewCell.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/6/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHCHealthScorecardTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateOfPoints;
@property (weak, nonatomic) IBOutlet UILabel *reasonOfPoints;
@property (weak, nonatomic) IBOutlet UILabel *gainedPoints;

@end
