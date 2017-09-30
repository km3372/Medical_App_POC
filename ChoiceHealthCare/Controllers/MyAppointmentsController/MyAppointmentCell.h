//
//  MyAppointmentCell.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 09/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAppointmentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UILabel *cityState;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UIButton *editAppointmentButton;

@end
