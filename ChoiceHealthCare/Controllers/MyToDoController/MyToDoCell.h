//
//  MyToDoCell.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 15/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyToDoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


- (void)setUpCellWithDictionary:(NSDictionary*)dictionary tapHandler:(void (^)())block;

@end
