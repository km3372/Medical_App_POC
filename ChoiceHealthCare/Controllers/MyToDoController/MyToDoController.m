//
//  MyToDoController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 15/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MyToDoController.h"
#import "MyToDoCell.h"
#import "CommonFilesImporter.h"
#import "APIClass.h"
#import "APINames.h"


static NSString * CellIdentifier = @"MyToDoCell";

@interface MyToDoController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *apiDataArray;

@end

@implementation MyToDoController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My To-Do's"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    self.tableView.estimatedRowHeight = 75;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"MyToDoCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];

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

- (void)refresh {
    [self fetchApiData];
}

- (void)handleTapOnIndexPath:(NSIndexPath *)indexPath {
    NSString* type = self.apiDataArray[indexPath.row][@"type"];

    UINavigationController* nc = self.navigationController;
    UIStoryboard* storyboard = self.storyboard;
    UIViewController* nextVC = nil; //used below to programmatically load VCs from the storyboard

    //Pick next VC depending on the TODO type
    if ([type isEqualToString:@"appointment"])
        nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyAppointmentsController"];

    else if ([type isEqualToString:@"survey"])
        nextVC = [storyboard instantiateViewControllerWithIdentifier:@"SurveysViewController"];

    else if ([type isEqualToString:@"hedis"])
        nextVC = [storyboard instantiateViewControllerWithIdentifier:@"HEDISViewController"];

    else if ([type isEqualToString:@"reminder"])
        nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyMedicationsController"];


    //Now go there
    if (nextVC) [nc pushViewController:nextVC animated:YES];
}

#pragma mark - TableView Delegates and DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.apiDataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self handleTapOnIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyToDoCell *cell = (MyToDoCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MyToDoCell" owner:self options:nil][0];
    }

    [cell setUpCellWithDictionary:(self.apiDataArray)[indexPath.row] tapHandler:^{
        [self handleTapOnIndexPath:indexPath];
    }];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - API Calls
-(void)fetchApiData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kTodoFetchList
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             self.apiDataArray = resultDict[@"data"];
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
