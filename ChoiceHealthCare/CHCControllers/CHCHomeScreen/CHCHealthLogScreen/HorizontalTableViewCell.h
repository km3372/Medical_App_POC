//
//  HorizontalTableViewCell.h
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/29/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorizontalTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *loggerInfoView;
@property (weak, nonatomic) IBOutlet UILabel *loggerCategoryTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggerCategoryAverageLabel;
@property (weak, nonatomic) IBOutlet UITableView *loggerDetailsTableView;
@property(strong , nonatomic)NSArray *loggerDetailsArray;

@property (weak, nonatomic) IBOutlet UIButton *viewFullHistoryButton;

-(void) reloadTableViewContent:(NSArray *)loggerInfo;



@end
