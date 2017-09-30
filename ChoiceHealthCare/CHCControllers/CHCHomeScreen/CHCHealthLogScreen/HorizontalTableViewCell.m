//
//  HorizontalTableViewCell.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/29/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "HorizontalTableViewCell.h"
#import "LoggerDetailsTableViewCell.h"
@implementation HorizontalTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)viewFullHistoryButtonClick:(id)sender {
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.loggerDetailsArray.count != 0) {
        return self.loggerDetailsArray.count;
    }
    return 0;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    tableView.superview.clipsToBounds=YES;
    [tableView.superview bringSubviewToFront:self.viewFullHistoryButton];
    return 20.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"LoggerCell";
    
    LoggerDetailsTableViewCell *cell =(LoggerDetailsTableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    NSDictionary *cellInfo=(self.loggerDetailsArray)[indexPath.row];
    if (cellInfo[@"data"]) {
        cell.unitsLabel.text = [NSString stringWithFormat:@"%@",cellInfo[@"data"]];
        cell.dateLabel.text=cellInfo[@"timestamp"];
        if (indexPath.row % 2) {
            cell.backgroundColor = [UIColor whiteColor];
        }else {
            cell.backgroundColor = [UIColor lightGrayColor];
        }
    }else{
        cell.backgroundColor = [UIColor whiteColor];
        cell.unitsLabel.text = @"";
        cell.dateLabel.text=@"";
    
    }
    
 

    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.clipsToBounds=YES;
    return cell;

    
}
-(void) reloadTableViewContent:(NSArray *)loggerInfo{
    self.loggerDetailsArray = loggerInfo;
    [self.loggerDetailsTableView reloadData];

}
@end
