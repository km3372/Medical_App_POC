//
//  PointsHistoryCell.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 15/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointsHistoryCell : UITableViewCell {
    
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *pointsLabel;
}

- (void)setUpCellWithDictionary:(NSDictionary*)dictionary;

@end
