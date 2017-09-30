//
//  CreateMedicationController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 01/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "CreateMedicationController.h"
#import "CreateMedicationView.h"

@interface CreateMedicationController ()

@end

@implementation CreateMedicationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My Medications"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    CreateMedicationView *aView = [CreateMedicationView createMedicationViewFromXIB];
    aView.frame = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 148 );
    
    [self.view addSubview:aView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Event Handling

- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
