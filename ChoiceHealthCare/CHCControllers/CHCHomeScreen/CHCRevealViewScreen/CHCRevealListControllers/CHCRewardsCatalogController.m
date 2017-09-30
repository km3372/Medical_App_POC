//
//  CHCRewardsCatalogController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/7/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCRewardsCatalogController.h"
#import "CHCRewardsCatalogCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SWRevealViewController.h"
@interface CHCRewardsCatalogController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) IBOutlet UITableView *rewardsTableView;
@property (strong, nonatomic) NSMutableArray *rewardsList;
@property (nonatomic) NSInteger userRedeemedValue;
#pragma Instruction View..
@property (weak, nonatomic) IBOutlet UIView *instructionView;
@property (weak, nonatomic) IBOutlet UIButton *redeemInstructionButton;
- (IBAction)redeemInstructionButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *instructionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *choicePointRewardVerticleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instructionViewHeightConstraint;

@end

@implementation CHCRewardsCatalogController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.instructionView];
    self.redeemInstructionButton.tag = 0 ;
    [self updateView:self.redeemInstructionButton];
    self.redeemInstructionButton.layer.cornerRadius =6.0;
    self.redeemInstructionButton.clipsToBounds = YES;
    [self updateView:self.instructionView];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    [self getUserChoicePoints];
    [self getRewardList];

    // Do any additional setup after loading the view.
}

- (void)updateView:(UIView *)view{
    //updating button view according to design..
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0;
    //    view.layer.cornerRadius = 20;
}

- (void)viewDidAppear:(BOOL)animated {
   self.revealViewController.isFromHome=NO;
}

-(void)getRewardList {
     NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    
    [[APIClass sharedManager]apiCallWithRequest:object forApi:kRewardsFetch requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"]boolValue]) {
         
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                self.rewardsList = resultDict[@"data"];
               [self.rewardsTableView reloadData];
                
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.rewardsList.count != 0) {
        return self.rewardsList.count;
    }
    return 0;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"RewardsCell";
    
    CHCRewardsCatalogCell *cell =(CHCRewardsCatalogCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor whiteColor];
    cell.selectedBackgroundView = bgColorView;
    cell.myView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    cell.myView.layer.borderWidth  = 2.0;
    cell.myView.layer.cornerRadius = 20;
    NSDictionary *rewardInfo = (self.rewardsList)[indexPath.row];
    cell.rewardTitle.text = rewardInfo[@"title"];
//    cell.rewardDescription.text = [rewardInfo objectForKey:@"text"];
    cell.rewardPointsValue.text = [NSString stringWithFormat:@"%@ Points to Redeem",rewardInfo[@"pointval"]];
   NSString *imageUrl = [NSString stringWithFormat:@"%@%@",kImageIP,rewardInfo[@"image"]];
//    [cell.rewardimageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@""]];
   
   (cell.redeemedValue).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"button1.png"]];
    cell.redeemedValue.layer.borderWidth = 1.0;
    cell.redeemedValue.layer.cornerRadius = 8.0;
    cell.redeemedValue.clipsToBounds = YES;

    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *rewardsInfo = (self.rewardsList)[indexPath.row];
    if (self.userRedeemedValue >= [rewardsInfo[@"pointval"] integerValue]) {
  
        [self claimForReward:[rewardsInfo[@"rewardid"] integerValue]];
        
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Oops! You don't have enough Choice Points, yet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    
    
    }

}

-(void)claimForReward:(NSInteger)rewardID {

    NSString *apiName = [NSString stringWithFormat:@"%@%ld",kRewardsClaim,(long)rewardID];
     NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:apiName requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"]boolValue]) {
 
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil || [resultDict[@"message"] isEqualToString:@"Transaction completed successfully"]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Transaction completed successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [self getRewardList];
                [self getUserChoicePoints];
                [self.rewardsTableView reloadData];
                
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];

}

-(void)getUserChoicePoints {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetPoints,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            self.choicePoints.text=[NSString stringWithFormat:@"%ld",(long)[resultDict[@"totalpoints"] integerValue]];
            self.userRedeemedValue = [resultDict[@"totalpoints"] integerValue];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } ];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return 213.0;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)redeemInstructionButtonClicked:(id)sender {

    if (self.redeemInstructionButton.tag == 0 ) {
        self.redeemInstructionButton.tag = 1;
        [self.redeemInstructionButton setTitle:@"Got it!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = (self.view.frame.size.height-65.0);
        (self.choicePointRewardVerticleConstraint).constant = self.view.frame.size.height;
        self.instructionTextView.hidden = NO;
        
    }else{
        self.redeemInstructionButton.tag = 0;
        [self.redeemInstructionButton setTitle:@"Redeem Instructions!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = 35.0;
        (self.choicePointRewardVerticleConstraint).constant = 45.0;
        self.instructionTextView.hidden = YES;
    }
}
@end
