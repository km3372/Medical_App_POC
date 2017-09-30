//
//  ScheduleAppointmentView.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleAppointmentView : UIScrollView

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *cityState;
@property (weak, nonatomic) IBOutlet UILabel *distance;

+ (ScheduleAppointmentView *)createScheduleAppointmentViewFromXIB;

@end
