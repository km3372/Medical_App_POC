//
//  ListSurveysViewController.h
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 9/6/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ListSurveysViewController : BaseViewController{
    NSArray *titles;
    NSArray *images;
}

@property (nonatomic, strong) NSMutableArray *surveyArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
