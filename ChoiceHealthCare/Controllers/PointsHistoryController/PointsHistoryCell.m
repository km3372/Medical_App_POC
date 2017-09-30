//
//  PointsHistoryCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 15/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "PointsHistoryCell.h"

@implementation PointsHistoryCell

- (void)setUpCellWithDictionary:(NSDictionary*)dictionary {
    //Expected dictionary format
    //    {
    //        "timestamp": "1471740623",
    //        "amount": "+20",
    //        "type": "appointment",
    //        "itemid": "279",
    //        "date": "8/21/16",
    //        "text": "Booked appointment with \"\""
    //    }
    
    dateLabel.text = dictionary[@"date"];
    titleLabel.text = dictionary[@"text"];
    pointsLabel.text = [NSString stringWithFormat:@"%@ pts", dictionary[@"amount"]];
    
    //set positive/negative color shift
    NSInteger points = [dictionary[@"amount"] integerValue];
    if (points < 0) {
        pointsLabel.textColor = [UIColor redColor];
    } else {
        pointsLabel.textColor = [UIColor colorWithRed:(15.0/360.0) green:(150.0/360.0) blue:(70.0/360.0) alpha:1.0];
    }
}

@end
