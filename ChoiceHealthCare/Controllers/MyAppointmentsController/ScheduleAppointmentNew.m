//
//  ScheduleAppointmentNew.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 9/8/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ScheduleAppointmentNew.h"
#import "SWRevealViewController.h"
#import "CommonFilesImporter.h"
#import "MyMedicationsController.h"
#import "MyAppointmentsController.h"
#import "PointsRewardsController.h"
#import "CustomNavigationBar.h"
#import "BottomBarView.h"
#import "CHCConstants.h"

@interface ScheduleAppointmentNew () <SWRevealViewControllerDelegate,BottomBarViewDelegate>
{
    CustomNavigationBar *navigationBar ;
    BottomBarView *bottomBarView;
}

@end

@implementation ScheduleAppointmentNew

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString* title;
    
    if (_editEnabled) {
        title = @"Edit Appointment";
    }
    else{
        title = @"Schedule Appointment";
    }
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:title];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    _reasonForVisitTextField.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.4].CGColor;
    _reasonForVisitTextField.layer.borderWidth = 0.7;
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 40)];
    _reasonForVisitTextField.leftView = paddingView;
    _reasonForVisitTextField.leftViewMode = UITextFieldViewModeAlways;
    _reasonForVisitTextField.rightView = paddingView;
    _reasonForVisitTextField.rightViewMode = UITextFieldViewModeAlways;
    
    [self prepareAppearance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareAppearance{
    _selectionArray = [NSMutableArray new];
    
    if (_editEnabled) {
        _doctorName.text = _apptDictionary[@"doctor"][@"name"];
        _doctorDistance.text =  [NSString stringWithFormat:@"%@ miles away",_apptDictionary[@"doctor"][@"distance"] ];
        _doctorAddress.text = _apptDictionary[@"doctor"][@"address"];
        _doctorCityState.text = _apptDictionary[@"doctor"][@"citystate"];
        
        [self setUpEditView];
    }
    else{
        _doctorName.text = self.model.name;
        _doctorDistance.text =  [NSString stringWithFormat:@"%@ miles away", self.model.distance];
        _doctorAddress.text = self.model.address;
        _doctorCityState.text = self.model.cityState;
    }
}



- (void)viewDidAppear:(BOOL)animated
{
   self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0); //
   // [self.tableView setFrame:CGRectMake(0, 64, self.view.frame.size.width, 492)];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 5;
}

-(void) setUpEditView{
    
    [_scheduleAppointmentButton setTitle:@"Edit Appointment" forState:UIControlStateNormal];
    
    //URGENCY
    if ([_apptDictionary[@"how_soon"] isEqualToString:@"asap"]) {
        _urgencySegment.selectedSegmentIndex = 0;
    }
    else if ([_apptDictionary[@"how_soon"] isEqualToString:@"one-week"]) {
        _urgencySegment.selectedSegmentIndex = 1;
    }
    else  {
        _urgencySegment.selectedSegmentIndex = 2;
    }
    
    
    //TIME
    if ([_apptDictionary[@"timeday"] isEqualToString:@"morning"]) {
        _timeSegment.selectedSegmentIndex = 0;
    }
    else if ([_apptDictionary[@"timeday"] isEqualToString:@"afternoon"]) {
        _timeSegment.selectedSegmentIndex = 1;
    }
    else  {
        _timeSegment.selectedSegmentIndex = 2;
    }
    
    
    //PAYMENT
    if ([_apptDictionary[@"payment"] isEqualToString:@"cash"]) {
        _paymentSegment.selectedSegmentIndex = 0;
    }
    else  {
        _paymentSegment.selectedSegmentIndex = 1;
    }
    
    
    //REASON
    if (_apptDictionary[@"reason"] != nil) {
        _reasonForVisitTextField.text = _apptDictionary[@"reason"];
    }
    
    
    //DAYS
    
    NSArray *daysArray = [_apptDictionary[@"dayweek"] componentsSeparatedByString:@","];
    
    if ( [daysArray containsObject: @"mon"]) {
        [_monButton setBackgroundColor:CHOICE_LIGHT_BLUE];
        [_monButton setSelected:YES];
    }
    
    if ( [daysArray containsObject: @"tues"]) {
        [_tuesButton setBackgroundColor:CHOICE_LIGHT_BLUE];
        [_tuesButton setSelected:YES];
    }
    
    if ( [daysArray containsObject: @"wed"]) {
        [_wedsButton setBackgroundColor:CHOICE_LIGHT_BLUE];
        [_wedsButton setSelected:YES];
    }
    
    if ( [daysArray containsObject: @"thu"]) {
        [_thursButton setBackgroundColor:CHOICE_LIGHT_BLUE];
        [_thursButton setSelected:YES];
    }
    
    if ( [daysArray containsObject: @"fri"]) {
        [_friButton setBackgroundColor:CHOICE_LIGHT_BLUE];
        [_friButton setSelected:YES];
    }
    
    if ( [daysArray containsObject: @"sat"]) {
        [_satButton setBackgroundColor:CHOICE_LIGHT_BLUE];
        [_satButton setSelected:YES];
    }
    
    if ( [daysArray containsObject: @"sun"]) {
        [_sunButton setBackgroundColor:CHOICE_LIGHT_BLUE];
        [_sunButton setSelected:YES];
    }

    
    _selectionArray = [NSMutableArray arrayWithArray:daysArray];
    
}

- (void)addNavigationBarLeftButtonType:(LeftNavButtonType)type andTitle:(NSString *)title{
    
    navigationBar = [[CustomNavigationBar sharedInstance] createNavBarWithLeftButtonType:type andTitle:title];
    
    navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    
    if (type == LeftNavButtonTypeMenu) {
        
        [navigationBar.leftNavButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
        self.revealViewController.delegate = self;
        
    } else {
        
        [navigationBar.leftNavButton addTarget:self action:@selector(leftNavButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self.view insertSubview:navigationBar aboveSubview:self.tableView];
    
}

- (void)addBottomBarViewWithType:(BottomBarType)type {
    
    bottomBarView = [BottomBarView createBottomBarWithType:type];
    
    bottomBarView.delegate = self;
    
    bottomBarView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - CGRectGetHeight(bottomBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(bottomBarView.frame));
    
    
    [self.view insertSubview:bottomBarView aboveSubview:self.tableView];
}

- (void)leftNavButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SWReavelViewController Delegates

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    
    [(self.view).subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL *
                                                       _Nonnull stop) {
        obj.userInteractionEnabled = position == FrontViewPositionLeft ? true : false;
    }];
}

#pragma mark - Bottom Bar Delegate

- (void)bottomBarButtonClickedForType:(ButtonType)type {
    
    switch (type) {
        case ButtonTypeMyMeds: [self goToMyMedicationsScreen];          break;
        case ButtonTypeMyApps: [self goToMyAppointmentsScreen];         break;
        case ButtonTypeGetHelp: [self callForHelp];                     break;
        case ButtonTypePoints: [self goToRedeemScreen];                 break;
        default:                                                        break;
    }
}

#pragma mark - Navigation

- (void)callForHelp {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Call ChoicePoints Help Line?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Call Help" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        NSURL *url = [NSURL URLWithString:kInERPhoneNumber];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [Utils showAlertForString:@"Your device does not support calling."];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *  action) {
        //Do nothing;
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
    
}

- (void)goToMyAppointmentsScreen {
    
    MyAppointmentsController *apptsController = [self checkController:[MyAppointmentsController class]isPresentInNavigationStack:self.navigationController];
    
    if (apptsController) {
        
        [self.navigationController popToViewController:apptsController animated:false];
    }
    else {
        
        if(![self.navigationController.topViewController isKindOfClass:[MyAppointmentsController class]]) {
            apptsController = [[UIStoryboard storyboardWithName:@"CHCHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyAppointmentsController"];
            
            [self.navigationController pushViewController:apptsController animated:false];
        }
    }
    
}

- (void)goToMyMedicationsScreen {
    
    MyMedicationsController *previousController = [self checkController:[MyMedicationsController class]isPresentInNavigationStack:self.navigationController];
    
    if (previousController) {
        
        [self.navigationController popToViewController:previousController animated:false];
    }
    else {
        
        if(![self.navigationController.topViewController isKindOfClass:[MyMedicationsController class]]) {
            previousController = [[UIStoryboard storyboardWithName:@"CHCHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyMedicationsController"];
            
            [self.navigationController pushViewController:previousController animated:false];
        }
    }
}

- (void)goToRedeemScreen {
    
    PointsRewardsController *previousController = [self checkController:[PointsRewardsController class]isPresentInNavigationStack:self.navigationController];
    
    if (previousController) {
        
        [self.navigationController popToViewController:previousController animated:false];
    }
    else {
        
        previousController = [[UIStoryboard storyboardWithName:@"CHCHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PointsRewardsController"];
        
        [self.navigationController pushViewController:previousController animated:false];
    }
}

- (id)checkController:(Class)class isPresentInNavigationStack:(UINavigationController *)navigationController {
    
    id object;
    
    NSArray *controllerStack = navigationController.viewControllers;
    
    for (id obj in controllerStack) {
        
        if ([obj isKindOfClass:class]) {
            
            object = obj;
            break;
        }
    }
    return object;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGRect frame = navigationBar.frame;
    frame.origin.y = scrollView.contentOffset.y;
    navigationBar.frame = frame;
    
    [self.view bringSubviewToFront: navigationBar];
    
    
    CGRect frame2 = bottomBarView.frame;
    frame2.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - bottomBarView.frame.size.height;
    bottomBarView.frame = frame2;
    
    [self.view bringSubviewToFront:bottomBarView];
}

- (IBAction)scheduleApptPressed:(id)sender {
    [self validateForm];
}

-(void) validateForm{
    
    NSString *message = nil;
    BOOL validation = YES;
    
    if (_urgencySegment.selectedSegmentIndex == UISegmentedControlNoSegment) {
        message = @"Please select an urgency";
    }
    else if (_selectionArray.count == 0) {
        message = @"Please select days available";
    }
    else if (_timeSegment.selectedSegmentIndex == UISegmentedControlNoSegment) {
        message = @"Please a time of day preference";
    }
    else if (_paymentSegment.selectedSegmentIndex == UISegmentedControlNoSegment) {
        message = @"Please a payment option";
    }
    else if (_reasonForVisitTextField.text.length == 0){
        message = @"Please enter a reason for your visit";
    }
    
    if (message != nil || validation == NO) {
        if (message != nil) {
            [Utils showAlertForString:message];
        }
    }
    else
    {
        [self scheduleAppointment];
    }
}


- (IBAction)dayPressed:(id)sender {
    
    NSString *value;
    
    switch (((UIButton *)sender).tag) {
        case 0:
            value = @"mon";
            break;
        case 1:
            value = @"tues";
            break;
        case 2:
            value = @"wed";
            break;
        case 3:
            value = @"thu";
            break;
        case 4:
            value = @"fri";
            break;
        case 5:
            value = @"sat";
            break;
        case 6:
            value = @"sun";
            break;
            
        default:
            break;
    }
    
    if ([sender isKindOfClass:[UIButton class]]) {
        ((UIButton*)sender).selected = !((UIButton *)sender).isSelected;
        
        if (((UIButton *)sender).isSelected) {
            [(UIButton*)sender setBackgroundColor:CHOICE_LIGHT_BLUE];
            
            if ([_selectionArray containsObject: value])
            {
                [_selectionArray removeObject:value];
            }
            else
            {
                [_selectionArray addObject:value];
            }
            
        }
        else{
            ((UIButton*)sender).backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:235.0/255.0 alpha:1.0];
            
            if ([_selectionArray containsObject: value])
            {
                [_selectionArray removeObject:value];
            }
        }
    }
    
    NSLog(@"SELECTION ARRAY: %@", _selectionArray);
}


-(void)scheduleAppointment{
    
    NSString *urgency;
    NSString *time;
    NSString *payment;
    NSString *days = [_selectionArray componentsJoinedByString:@","];
    NSString *apiString;
    NSDictionary *requestDictionary;
    
    switch (_urgencySegment.selectedSegmentIndex) {
        case 0:
            urgency = @"asap";
            break;
        case 1:
            urgency = @"one-week";
            break;
        case 2:
            urgency = @"two-weeks";
            break;
            
        default:
            break;
    }
    
    switch (_timeSegment.selectedSegmentIndex) {
        case 0:
            time = @"morning";
            break;
        case 1:
            time = @"afternoon";
            break;
        case 2:
            time = @"evening";
            break;
            
        default:
            break;
    }
    
    switch (_paymentSegment.selectedSegmentIndex) {
        case 0:
            payment = @"yes";
            break;
        case 1:
            payment = @"no";
            break;
            
        default:
            break;
    }
    
    
    if (_editEnabled) {
        requestDictionary= @{kReqId:_apptDictionary[@"reqid"] ,kHowSoon:urgency, kDayweek:days, kTimeday:time, kDocid: _apptDictionary[@"docid"], kReason:_reasonForVisitTextField.text, kInfo:@"none",kPayment:payment};
    }
    else{
        requestDictionary= @{kHowSoon:urgency, kDayweek:days, kTimeday:time, kDocid: _model.docId, kReason:_reasonForVisitTextField.text, kInfo:@"none",kPayment:payment};
    }


    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    if (_editEnabled) {
        hud.labelText = @"Editing Appointment";
        apiString = kAppointmentEdit;
    }
    else{
        hud.labelText = @"Scheduling Appointment";
        apiString = kAppointmentSubmit;
    }
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:apiString
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         
         if ([resultDict[@"success"] boolValue]) {
             
             //Update UserModel with results so the counter increases
             UserModel* user = [UserModel currentUser];
             NSNumber* points = resultDict[@"points"][@"totalPoints"];
             if (points) {
                 user.pointTotal = points;
                 [user synchronizeUser];
             }
             
             [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:NO];
             
             if (_editEnabled) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"editedApponitment" object:nil];
             }
             else{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduledApponitment" object:nil];
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
