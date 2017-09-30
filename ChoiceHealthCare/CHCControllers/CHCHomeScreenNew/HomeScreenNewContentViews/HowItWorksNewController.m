//
//  HowItWorksNewController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/5/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "HowItWorksNewController.h"
#import "SWRevealViewController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"

@interface HowItWorksNewController ()
@property (weak, nonatomic) IBOutlet UIButton *revealView;
@property (weak, nonatomic) IBOutlet UILabel *choicePoints;

@end

@implementation HowItWorksNewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    [self getUserChoicePoints];
    // Do any additional setup after loading the view.
}

-(void)getUserChoicePoints {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetPoints,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            self.choicePoints.text=[NSString stringWithFormat:@"%ld",(long)[resultDict[@"totalpoints"] integerValue]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } ];
    
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    self.revealViewController.isFromHome=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
