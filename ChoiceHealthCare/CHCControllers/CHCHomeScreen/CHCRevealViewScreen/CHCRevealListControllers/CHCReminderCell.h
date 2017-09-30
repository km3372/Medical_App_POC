//
//  CHCReminderCell.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/10/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHCReminderCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *dose;
@property (strong, nonatomic) IBOutlet UIView *myBorderView;

@end
