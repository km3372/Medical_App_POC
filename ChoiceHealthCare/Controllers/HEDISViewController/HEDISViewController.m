//
//  HEDISViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "HEDISViewController.h"
#import "HEDISHeaderCell.h"
#import "HEDISSubCell.h"
#import "InstructionsViewController.h"

#import "CommonFilesImporter.h"

@interface HEDISViewController ()<UITableViewDataSource,UITableViewDelegate>
{
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *apiDataArray;

@end

@implementation HEDISViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Wellness Milestones"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"HEDISSubCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HEDISSubCell"];

    self.automaticallyAdjustsScrollViewInsets = false;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchApiData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions
- (void)leftNavButtonClicked:(id)sender {

    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)instructionButtonClicked:(id)sender {

    InstructionsViewController *controller = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:[NSBundle mainBundle]];

    controller.helpText = @"Wellness milestones are periodic preventative health visits that include cancer screenings, BMI calculations, tobacco cessation, advanced care planning, medication reviews, once a year comprehensive checkup for diabetes patients, and well visits and immunizations for children. Schedule your wellness appointment today to earn bonus points for completing any of these wellness milestones.";

    [self.navigationController pushViewController:controller animated:true];
}

#pragma mark - TableView Delegates and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apiDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HEDISSubCell *cell = (HEDISSubCell*)[tableView dequeueReusableCellWithIdentifier:@"HEDISSubCell"];
  
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"HEDISSubCell" owner:self options:nil][0];
    }

    [cell setUpCellWithDictionary:(self.apiDataArray)[indexPath.row] tapHandler:^(BOOL selected) {
        if (selected) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
    }];

    NSNumber* complete = self.apiDataArray[indexPath.row][@"completed"][@"is_complete"];

    if (![complete isKindOfClass:[NSNull class]] && complete.integerValue) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - API Calls
-(void)fetchApiData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kWellnessFetchList
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             self.apiDataArray = resultDict[@"data"];
             [self.tableView reloadData];
         } else{
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
