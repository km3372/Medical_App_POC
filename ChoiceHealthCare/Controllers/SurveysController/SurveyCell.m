//
//   }        [postingCell.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/29/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "SurveyCell.h"

@implementation SurveyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (selected) {
        self.backgroundColor = [UIColor colorWithRed:34.4/255.0 green:163.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.answerLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.backgroundColor = [UIColor whiteColor];
        self.answerLabel.textColor = [UIColor blackColor];
    }
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 20;
    frame.size.width -= 2 * 20;
    super.frame = frame;
}

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    [super setHighlighted:highlighted animated:animated];
//    
//    if (highlighted) {
//        self.backgroundColor = [UIColor redColor];
//    }
//    else {
//        self.backgroundColor = [UIColor whiteColor];
//    }
//}

@end
