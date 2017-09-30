//
//  MyMedicationsController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 01/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MyMedicationsController.h"
#import "MedicationsCell.h"
#import "InstructionsViewController.h"

#import "CommonFilesImporter.h"

static NSString * CellIdentifier = @"MedicationsCell";

@interface MyMedicationsController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *apiDataArray;

@end

@implementation MyMedicationsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My Medications"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    self.tableView.estimatedRowHeight = 72;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerNib:[UINib nibWithNibName:@"MedicationsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:CellIdentifier];

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

#pragma mark - Event Handling
- (void)leftNavButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)createMedicationButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"ShowCreateMedicationController" sender:self];
}

- (IBAction)instructionButtonClicked:(id)sender {
    InstructionsViewController *controller = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:[NSBundle mainBundle]];
    
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
    MedicationsCell *cell = (MedicationsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MedicationsCell" owner:self options:nil][0];
    }
    NSDictionary* data = self.apiDataArray[indexPath.row];
    [cell setUpCellWithDictionary:data tapHandler:^(BOOL selected) {
        [self setMedication:indexPath.row asActive:selected];
    }];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

#pragma mark - API Calls
-(void)setMedication:(NSInteger)rowID asActive:(BOOL)active {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    NSString* url = (active) ? kMedicationsEnable : kMedicationsDisable;
    NSDictionary* data = @{@"id": self.apiDataArray[rowID][@"id"]};

    [[APIClass sharedManager] apiCallWithRequest:data
                                          forApi:url
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             [self fetchApiData];
         } else{
             NSString *errorMessage = resultDict[@"message"];
             [Utils showAlertForString:errorMessage];
             [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         }
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}

-(void)fetchApiData {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kMedicationsFetchList
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             
             if (![resultDict[@"data"] isEqual:[NSNull null]]) {
                  self.apiDataArray = resultDict[@"data"];
             }
            
             if (self.apiDataArray.count != 0) {
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
