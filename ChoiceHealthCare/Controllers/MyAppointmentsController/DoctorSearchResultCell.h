//
//  DoctorSearchResultCellTableViewCell.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/24/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoctorSearchResultCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityStateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;


@end
