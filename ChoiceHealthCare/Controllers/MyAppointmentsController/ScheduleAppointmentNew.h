//
//  ScheduleAppointmentNew.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 9/8/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DoctorModel.h"

@interface ScheduleAppointmentNew : UITableViewController
@property (weak, nonatomic) IBOutlet UITextField *reasonForVisitTextField;
@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UILabel *doctorCityState;
@property (weak, nonatomic) IBOutlet UILabel *doctorAddress;
@property (weak, nonatomic) IBOutlet UILabel *doctorDistance;
@property (weak, nonatomic) IBOutlet UISegmentedControl *urgencySegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *timeSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *paymentSegment;

@property (nonatomic, strong) NSMutableArray *selectionArray;
@property (nonatomic, strong) NSDictionary *apptDictionary;
@property (nonatomic) BOOL editEnabled;

- (IBAction)scheduleApptPressed:(id)sender;
- (IBAction)dayPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *scheduleAppointmentButton;
@property (weak, nonatomic) IBOutlet UIButton *tuesButton;
@property (weak, nonatomic) IBOutlet UIButton *wedsButton;
@property (weak, nonatomic) IBOutlet UIButton *thursButton;
@property (weak, nonatomic) IBOutlet UIButton *friButton;
@property (weak, nonatomic) IBOutlet UIButton *satButton;
@property (weak, nonatomic) IBOutlet UIButton *sunButton;

@property (weak, nonatomic) IBOutlet UIButton *monButton;
@property (strong, nonatomic) DoctorModel* model;
@end
