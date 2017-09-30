//
//  ActivityDashboardController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 14/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ActivityDashboardController.h"

@interface ActivityDashboardController ()


@end

@implementation ActivityDashboardController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Activity Logger"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handling

- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
