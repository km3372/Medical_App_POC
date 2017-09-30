//
//  PointsRewardsController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 14/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "PointsRewardsController.h"
#import "PointsRewardsCell.h"
#import "InstructionsViewController.h"
#import "CommonFilesImporter.h"
#import "APIClass.h"
#import "APINames.h"
#import "RewardsCatalogModel.h"


static NSString * CellIdentifier = @"PointsRewardsCell";

@interface PointsRewardsController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pointsHeaderLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *rewardsListArray;

@end

@implementation PointsRewardsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"ChoicePoints Rewards"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PointsRewardsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self updatePointTotals];
    [self fetchRewardsCatalog];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updatePointTotals {
    UserModel* user = [UserModel currentUser];
    self.pointsHeaderLabel.text = [NSString stringWithFormat:@"You have %@ points", user.pointTotal];
}


#pragma mark - Event Handling
- (IBAction)instructionButtonClicked:(id)sender {
    
    InstructionsViewController *controller = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:[NSBundle mainBundle]];

    controller.helpText = @"Earn points rewards when you complete your profile, respond to health questions, participate in surveys, complete targeted wellness activities, and achieve wellness milestones. Choose either Amazon or Walmart gift cards to redeem your points and claim your reward. You may be eligible to earn up to 1,000 points (a $50 value) each year!";

    [self.navigationController pushViewController:controller animated:true];
}

#pragma mark - TableView Delegates and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rewardsListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PointsRewardsCell *cell = (PointsRewardsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"PointsRewardsCell" owner:self options:nil][0];
    }
    [cell setUpCellWithModel:(self.rewardsListArray)[indexPath.row]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    RewardsCatalogModel* model = (self.rewardsListArray)[indexPath.row];
    NSString* message = [NSString stringWithFormat:@"Do you want to redeem %@ for %@ points?", model.rewardTitle, model.rewardPointValue];

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Redeem reward?"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Yes, redeem" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        [self redeemReward:model];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *  action) {
            //Do nothing;
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
}


#pragma mark - API Calls
-(void)redeemReward:(RewardsCatalogModel*)model {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //expected results:
    //   SUCCESS ({
    //      data: { updatedTotal: INT },
    //      success: true,
    //      message: “Transaction Completed successfully”
    //   })
    //
    //   ERROR ({
    //      data: “”,
    //      success: false,
    //      message: “Not enough points”
    //   })

    NSString* url = [NSString stringWithFormat:@"%@/%@", kRewardsClaim, model.rewardId];
    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:url
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
    {

        if ([resultDict[@"success"] boolValue]) {
            NSString* updatedTotal = resultDict[@"data"][@"updatedTotal"];
            if (updatedTotal) {
                UserModel* user = [UserModel currentUser];
                user.pointTotal = @(updatedTotal.integerValue);
                [user synchronizeUser];

                [self updatePointTotals];
            }
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        [Utils showAlertForString:resultDict[@"message"]];
        
    } onCancelation:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        [Utils showAlertForString:kInternetConnectionNotAvailable];
    }];
    
}


-(void)fetchRewardsCatalog {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kRewardsFetch
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error) {
                                        
        if ([resultDict[@"success"] boolValue]) {
            self.rewardsListArray = [NSMutableArray new];
            
            NSArray *dataArray = resultDict[@"data"];
            for (int i=0; i<dataArray.count; i++) {
                NSDictionary *articleInfo = dataArray[i];
                RewardsCatalogModel *model = [RewardsCatalogModel createModelWithDictionary:articleInfo];
                [self.rewardsListArray addObject:model];
            }
            
            [self.tableView reloadData];
        } else {
            NSString *errorMessage = resultDict[@"message"];
            [Utils showAlertForString:errorMessage];
        }
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        
    } onCancelation:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:true];
        [Utils showAlertForString:kInternetConnectionNotAvailable];
    }];
}

@end
