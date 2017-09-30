//
//  MedicationsCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 01/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MedicationsCell.h"

@implementation MedicationsCell

- (IBAction)selectTapped:(id)sender {
    if (self.selectBlock) {
        //Tell delegate block to toggle the select state
        self.selectBlock(!self.selectedButton.selected);
    }
}

- (void)setUpCellWithDictionary:(NSDictionary*)dictionary tapHandler:(void (^)(BOOL selected))block {
    //Expected dictionary format
    //  {
    //      "id": "41",
    //      "uid": "129",
    //      "AdministrationUnits": "",
    //      "Frequency": "Once a day",
    //      "MedicationAdministrationInterval": "",
    //      "Duration": "90 days",
    //      "DurationStartTime": "2016-10-12 15:08:52",
    //      "DosageStrength": "5 MG",
    //      "MedicationBrandName": "Amlodipine Besylate"
    //      "active": "1"
    //  }

//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";
//    NSDate* dateCreated = [formatter dateFromString:dictionary[@"DurationStartTime"]];
//
//    //Show the time only if it's today; otherwise show the date only
//    if (fabs([dateCreated timeIntervalSinceNow]) > 60*60*12) {
//        formatter.dateStyle = NSDateFormatterShortStyle;
//        formatter.timeStyle = NSDateFormatterNoStyle;
//    } else {
//        formatter.dateStyle = NSDateFormatterNoStyle;
//        formatter.timeStyle = NSDateFormatterShortStyle;
//    }

    self.selectBlock = block;
    self.selectedButton.selected = [dictionary[@"active"] boolValue];
    self.titleLabel.text = dictionary[@"MedicationBrandName"];
    self.dateLabel.text = dictionary[@"Duration"];

    NSString* detail = [NSString stringWithFormat:@"%@: %@", dictionary[@"DosageStrength"], dictionary[@"Frequency"]];
    self.detailLabel.text = detail;
}


@end
