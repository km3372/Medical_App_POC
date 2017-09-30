//
//  MyInboxViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 09/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MyInboxViewController.h"

@interface MyInboxViewController ()

@end

@implementation MyInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My Inbox"];
    
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

- (IBAction)articlesButtonClicked:(id)sender {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Articles" bundle:[NSBundle mainBundle]];
    UIViewController* vc = [storyboard instantiateInitialViewController];
    [self.navigationController pushViewController:vc animated:true];
}
- (IBAction)surveysButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"ShowSurveys" sender:self];
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
