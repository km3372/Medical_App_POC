//
//  HEDISSubCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "HEDISSubCell.h"

@implementation HEDISSubCell

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)selectTapped:(id)sender {
    if (self.selectBlock) {
        //Tell delegate block to toggle the select state
        self.selectBlock(!self.selectedButton.selected);
    }
}

- (void)setUpCellWithDictionary:(NSDictionary*)dictionary tapHandler:(void (^)(BOOL selected))block {
    //{
    //    "id": "1",
    //    "milestone": "Annual Preventative Health Visit",
    //    "description": "Annual+preventative+health+visit+for+adults+18%2B+years+old.",
    //    "active": "1",
    //    "completed": {
    //        "is_complete": 1,
    //        "date_completed": "2016-09-03 15:00:00",
    //        "activity": "You visited your care provider on Sept. 3, 2016."
    //    },
    //    "criteria": {
    //        "gender": null,
    //        "age": "18 - 9999",
    //        "frequency": "Annual",
    //        "custom": null
    //    }

    self.selectBlock = block;
    self.selectedButton.selected = [dictionary[@"completed"][@"is_complete"] boolValue];
    self.headerLabel.text = dictionary[@"milestone"];
    self.detailLabel.text = [[dictionary[@"description"] stringByRemovingPercentEncoding] stringByReplacingOccurrencesOfString:@"+" withString:@" "];

    NSString* completion = dictionary[@"completed"][@"activity"];
    if ([completion isKindOfClass:[NSNull class]]) completion = nil;
    self.completionLabel.text = completion;
}


@end
