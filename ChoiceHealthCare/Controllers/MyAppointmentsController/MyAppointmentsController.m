//
//  MyAppointmentsController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 09/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "MyAppointmentsController.h"
#import "MyAppointmentCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CommonFilesImporter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "ScheduleAppointmentNew.h"

typedef NS_ENUM(NSInteger, AppointmentType) {
    
    AppointmentTypeUpcoming = 100,
    AppointmentTypePending = 101,
    AppointmentTypePast = 102
    
};

@interface MyAppointmentsController () <UITableViewDataSource, UITableViewDelegate>

{
    AppointmentType selectedAppointmentType;
}

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *upcomingButton;
@property (nonatomic, weak) IBOutlet UIButton *pendingButton;
@property (nonatomic, weak) IBOutlet UIButton *pastButton;


@end

@implementation MyAppointmentsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My Appointments"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    self.upcomingButton.tag = AppointmentTypeUpcoming;
    self.pendingButton.tag  = AppointmentTypePending;
    self.pastButton.tag     = AppointmentTypePast;

    [self.tableView registerNib:[UINib nibWithNibName:@"MyAppointmentCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"AppointmentCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self fetchAppointments];
}

#pragma mark - Event Handling


- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)scheduleAppointmentButtonClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowScheduleAppointment" sender:self];
    
}

#pragma mark - TableView Delegate and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _apptResultsDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyAppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AppointmentCell"];
    
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"MyAppointmentCell" owner:self options:nil][0];
    }
    
    if ([_apptResultsDataArray[indexPath.row][@"doctor"]  isEqual:[NSNull null]]) {
        cell.doctorName.text = @"";
        cell.address.text = @"";
        cell.cityState.text = @"";
    }
    else{
        cell.doctorName.text = _apptResultsDataArray[indexPath.row][@"doctor"][@"name"];
        cell.address.text = _apptResultsDataArray[indexPath.row][@"doctor"][@"address"];
        cell.cityState.text = _apptResultsDataArray[indexPath.row][@"doctor"][@"citystate"];
    }
    
    if (_apptSegmentControl.selectedSegmentIndex == 2) {
        cell.editAppointmentButton.hidden = YES;
    }
    else{
        cell.editAppointmentButton.hidden = NO;
        cell.editAppointmentButton.tag = indexPath.row;
        [cell.editAppointmentButton addTarget:self action:@selector(editAppointmentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy'-'MM'-'dd' 'HH':'mm':'ss";
    NSDate *requestDate = [formatter dateFromString:_apptResultsDataArray[indexPath.row][@"created"]];

    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"MM/dd/yyyy";
    NSString *result = [df stringFromDate:requestDate];
    
    cell.dateLabel.text = [NSString stringWithFormat:@"Request Date: %@", result];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_apptSegmentControl.selectedSegmentIndex == 2) {
        return 103;
    }
    else{
        return 140;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}


#pragma mark - API Calls

-(void) fetchAppointments{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
     _apptResultsDataArray = [NSMutableArray new];
    
    NSString *status;
    
    switch (_apptSegmentControl.selectedSegmentIndex) {
        case 0:
            status = @"1";
            _messageLabel.text = @"No Upcoming Appointments";
            break;
        case 1:
            status = @"2";
            _messageLabel.text = @"No Pending Appointments";
            break;
        case 2:
            status = @"3";
            _messageLabel.text = @"No Past Appointments";
            break;
            
        default:
            break;
    }
    
    NSDictionary *requestDictionary =  @{kStatus:status, kGeo_Lat:@"34", kGeo_Long:@"-84"};
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:kAppointmentFetch
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         
         if ([resultDict[@"success"] boolValue]) {
             
             if ([resultDict[@"message"] isEqual:[NSNull null]] ||
                 [resultDict[@"message"] isEqualToString:@""] ||
                 resultDict[@"message"] == nil  ) {
                 
                 NSArray *dataArray = resultDict[@"data"];
                 for (int i=0; i<dataArray.count; i++) {
                     NSDictionary *itemInfo = dataArray[i];
                     [_apptResultsDataArray addObject:itemInfo];
                 }
                 [_tableView reloadData];
                 
                 if (_apptResultsDataArray.count > 0) {
                     [self hideOverlay];
                 }
             }
         } else{
             NSString *errorMessage = resultDict[@"message"];
             [Utils showAlertForString:errorMessage];
             [_tableView reloadData];
             
             if (_apptResultsDataArray.count == 0) {
                 [self showOverlay];
             }
         }
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}

-(void)hideOverlay{
    _messageLabel.hidden = YES;
    _calendarImageView.hidden = YES;
}

-(void)showOverlay{
    _messageLabel.hidden = NO;
    _calendarImageView.hidden = NO;
}


-(void)editAppointmentButtonPressed:(UIButton*)sender
{
    NSDictionary *doctorDict =  _apptResultsDataArray[sender.tag];
    [self performSegueWithIdentifier:@"EditAppointment" sender:doctorDict];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ScheduleAppointmentNew class]]) {
        ((ScheduleAppointmentNew*)segue.destinationViewController).apptDictionary = sender;
        ((ScheduleAppointmentNew*)segue.destinationViewController).editEnabled = YES;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)apptSegmentControlPressed:(id)sender {
     [self fetchAppointments];
}
@end
