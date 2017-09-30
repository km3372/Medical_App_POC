//
//  ScheduleAppointmentView.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ScheduleAppointmentView.h"
#import "RequestCompleteView.h"


@implementation ScheduleAppointmentView

+ (ScheduleAppointmentView *)createScheduleAppointmentViewFromXIB {
    
    ScheduleAppointmentView *aView = [[NSBundle mainBundle] loadNibNamed:@"ScheduleAppointmentView" owner:self options:nil][0];
    
    return aView;
}

- (IBAction)buttonClicked:(id)sender {
    
    if ([sender isKindOfClass:[UIButton class]]) {
        ((UIButton*)sender).selected = !((UIButton *)sender).isSelected;
    }
}

- (IBAction)submitRequestButtonClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduleAppointmentClicked" object:nil];// addObserver:self 
}


@end
