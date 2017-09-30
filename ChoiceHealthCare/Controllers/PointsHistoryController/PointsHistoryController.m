//
//  PointsHistoryController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 15/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "PointsHistoryController.h"
#import "PointsHistoryCell.h"
#import "CommonFilesImporter.h"
#import "APIClass.h"
#import "APINames.h"

static NSString * CellIdentifier = @"PointsHistoryCell";

@interface PointsHistoryController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *apiDataArray;


@end

@implementation PointsHistoryController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My History"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    self.tableView.estimatedRowHeight = 35;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"PointsHistoryCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self fetchPointsHistory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handling

- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - TableView Delegates and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apiDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    PointsHistoryCell *cell = (PointsHistoryCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[NSBundle mainBundle] loadNibNamed:@"PointsHistoryCell" owner:self options:nil][0];
    }

    [cell setUpCellWithDictionary:(self.apiDataArray)[indexPath.row]];
    
    UIColor *bgColor = indexPath.row%2 == 0 ? [UIColor whiteColor]:[UIColor colorWithHue:359.0 saturation:0.0 brightness:0.75 alpha:1.0];
    cell.backgroundColor = bgColor;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - API Calls
-(void)fetchPointsHistory {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kUserScorecard
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
    {
        
        if ([resultDict[@"success"] boolValue]) {
            self.apiDataArray = [NSMutableArray new];
            
            if ([resultDict[@"message"] isEqual:[NSNull null]] ||
                [resultDict[@"message"] isEqualToString:@""] ||
                 resultDict[@"message"] == nil  ) {
                
                NSArray *dataArray = resultDict[@"data"][@"history"];
                for (int i=0; i<dataArray.count; i++) {
                    NSDictionary *itemInfo = dataArray[i];
                    [self.apiDataArray addObject:itemInfo];
                }
                
                [self.tableView reloadData];
            }
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
