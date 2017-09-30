//
//  MyToDoCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 15/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MyToDoCell.h"

@implementation MyToDoCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUpCellWithDictionary:(NSDictionary*)dictionary tapHandler:(void (^)())block {
    //Expected dictionary format
    //  {
    //      "id": "2",
    //      "uid": "129",
    //      "name": "Medical Appointment",
    //      "type": "appointment",
    //      "description": "You have an upcoming appointment. Earn points by keeping appointments with your care provider.",
    //      "created": "2016-09-01 06:58:59",
    //      "due": "2016-09-20 04:00:27",
    //      "completed": "0"
    //   }

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";
    NSDate* dateCreated = [formatter dateFromString:dictionary[@"due"]];

    //Show the time only if it's today; otherwise show the date only
    if (fabs(dateCreated.timeIntervalSinceNow) > 60*60*12) {
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    } else {
        formatter.dateStyle = NSDateFormatterNoStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    }

    self.titleLabel.text = dictionary[@"name"];
    self.subtitleLabel.text = dictionary[@"description"];
    self.dateLabel.text = [formatter stringFromDate:dateCreated];
}

@end
