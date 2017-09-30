//
//  MedicationsCell.h
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 01/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedicationsCell : UITableViewCell

typedef void (^SelectBlock)(BOOL selected);

@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong, nonatomic) SelectBlock selectBlock;

- (void)setUpCellWithDictionary:(NSDictionary*)dictionary tapHandler:(void (^)(BOOL selected))block;

@end
