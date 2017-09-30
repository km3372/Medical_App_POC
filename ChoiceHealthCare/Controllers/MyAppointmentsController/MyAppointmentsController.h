//
//  MyAppointmentsController.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 09/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "BaseViewController.h"

@interface MyAppointmentsController : BaseViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *apptSegmentControl;
- (IBAction)apptSegmentControlPressed:(id)sender;
@property (nonatomic, strong) NSMutableArray *apptResultsDataArray;
@property (weak, nonatomic) IBOutlet UIImageView *calendarImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


@end
