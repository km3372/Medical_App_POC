//
//  CHCHealthScorecardController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/6/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCHealthScorecardController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "SWRevealViewController.h"
#import "CHCHealthScorecardTableViewCell.h"
@interface CHCHealthScorecardController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) IBOutlet UILabel *totalChoicePointsAvailable;
@property (strong, nonatomic) IBOutlet UITableView *pointsGainedTableView;
@property (strong, nonatomic) NSMutableArray *gainedPointsList;
@property (weak, nonatomic) IBOutlet UIView *instructionView;
@property (weak, nonatomic) IBOutlet UIButton *scorecardInstructionButton;
- (IBAction)scorecardInstructionButtonClicked:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *instructionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *instructionsTextView;

@end

@implementation CHCHealthScorecardController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scorecardInstructionButton.tag = 0;
    [self updateView:self.scorecardInstructionButton];
    self.scorecardInstructionButton.layer.cornerRadius = 6;
    self.scorecardInstructionButton.clipsToBounds = YES;
    [self updateView:self.instructionView];
    self.gainedPointsList=[NSMutableArray new];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    [self getUserChoicePoints];
    [self getGainedPointsList];
    // Do any additional setup after loading the view.
}
- (void)updateView:(UIView *)view{
    //updating button view according to design..
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0;
    //    view.layer.cornerRadius = 20;
}

-(void)viewDidAppear:(BOOL)animated{
    self.revealViewController.isFromHome=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

-(void)getGainedPointsList{
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kUserScorecard,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"]boolValue]) {
            
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                
                NSDictionary *gainPointsData=resultDict[@"data"];
                
                self.gainedPointsList = gainPointsData[@"history"];
                self.totalChoicePointsAvailable.text=[NSString stringWithFormat:@"%@",gainPointsData[@"total"]];
                [self.pointsGainedTableView reloadData];
                
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } ];



}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.gainedPointsList.count != 0 ) {
        return self.gainedPointsList.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HealthScorecardCell";
    CHCHealthScorecardTableViewCell * cell = (CHCHealthScorecardTableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSDictionary *gainedPointsInfo = (self.gainedPointsList)[indexPath.row];
    cell.dateOfPoints.text=gainedPointsInfo[@"date"];
    cell.reasonOfPoints.text=gainedPointsInfo[@"text"];
    cell.gainedPoints.text=gainedPointsInfo[@"amount"];
    
    
    
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)scorecardInstructionButtonClicked:(UIButton *)sender {

    if (self.scorecardInstructionButton.tag == 0 ) {
        self.scorecardInstructionButton.tag = 1;
        [self.scorecardInstructionButton setTitle:@"Got it!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = 180.0;
        self.instructionsTextView.hidden = NO;
    }else{
        self.scorecardInstructionButton.tag = 0;
         [self.scorecardInstructionButton setTitle:@"Scorecard Instructions!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = 35.0;
        self.instructionsTextView.hidden = YES;       
    }
}

@end
