//
//  CHCChildDetailsCell.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/21/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHCChildDetailsCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UITextField *childName;
@property (strong, nonatomic) IBOutlet UIButton *genderType;
@property (strong, nonatomic) IBOutlet UIButton *dateOfBirth;

@end
