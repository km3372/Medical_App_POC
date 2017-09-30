//
//  InstructionsViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "InstructionsViewController.h"

@interface InstructionsViewController ()
@property (weak, nonatomic) IBOutlet UITextView *helpTextView;

@end

@implementation InstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Instructions"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];

    self.helpTextView.text = self.helpText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handling

- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}


- (IBAction)goBackButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
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
