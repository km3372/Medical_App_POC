//
//  MyAppointmentCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 09/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MyAppointmentCell.h"

@implementation MyAppointmentCell

- (IBAction)addressTapped:(id)sender {
    NSString* address = [[[self.address.text stringByAppendingString:@", "] stringByAppendingString:self.cityState.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    if (address.length > 3) {
        NSString* urlString = [@"http://maps.apple.com/?address=" stringByAppendingString:address];
        NSURL* url = [NSURL URLWithString:urlString];

        if (url)
            [[UIApplication sharedApplication] openURL:url];

    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
