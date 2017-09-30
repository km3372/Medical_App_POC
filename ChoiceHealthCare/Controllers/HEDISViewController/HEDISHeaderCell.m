//
//  HEDISHeaderCell.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "HEDISHeaderCell.h"

@interface HEDISHeaderCell ()

@property (nonatomic, weak) IBOutlet UILabel *headerLabel;
@property (nonatomic, weak) IBOutlet UIImageView *accessoryImageView;

@end

@implementation HEDISHeaderCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setHeaderTitle:(NSString *)title {
    
    self.headerLabel.text = title;
}

- (void)setCellExpanded:(BOOL)status {
    
    NSString *imageName = status == true ? @"Add-Icon" : @"Subtract-logo";
    
    self.accessoryImageView.image = [UIImage imageNamed:imageName];
}

@end
