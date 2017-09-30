//
//  CHCDoctorsListTableViewCell.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/2/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHCDoctorsListTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *provider;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *distance;
@property (strong, nonatomic) IBOutlet UIImageView *avatarImageVIew;
@property (strong, nonatomic) IBOutlet UIView *borderViw;
@property (strong, nonatomic) IBOutlet UIButton *sendAppointmentRequest;


@end
