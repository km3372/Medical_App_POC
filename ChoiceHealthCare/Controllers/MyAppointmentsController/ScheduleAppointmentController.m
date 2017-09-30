//
//  ScheduleAppointmentController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 12/06/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ScheduleAppointmentController.h"
#import "ScheduleAppointmentView.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CommonFilesImporter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UserModel.h"


@interface ScheduleAppointmentController (){
    ScheduleAppointmentView *aView;
}

@end

@implementation ScheduleAppointmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Schedule an Appointment"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    aView = [ScheduleAppointmentView createScheduleAppointmentViewFromXIB];
    aView.frame = CGRectMake(0, 64, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) - 108);
    
    [self.view addSubview:aView];
    [self.view setNeedsLayout];
    
    //[view setNeedsLayout];
    [aView layoutIfNeeded];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduleAppointment) name: @"scheduleAppointmentClicked" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Event Handling


- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
}

- (void)layoutIfNeeded{
    aView.name.text = self.model.name;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self prepareAppearance];
}

-(void) prepareAppearance{
    aView.name.text = self.model.name;
    aView.distance.text =  [NSString stringWithFormat:@"%@ miles away", self.model.distance];
    aView.address.text = self.model.address;
    aView.cityState.text = self.model.cityState;
}



-(void)scheduleAppointment{

    NSDictionary *requestDictionary = @{kHowSoon:@"one-week", kDayweek:@"tues", kTimeday:@"morning", kDocid: _model.docId, kReason:@"Stomach pains", kInfo:@"none",kPayment:@"cash"};
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Scheduling Appointment";
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:kAppointmentSubmit
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         
         if ([resultDict[@"success"] boolValue]) {

             //Update UserModel with results so the counter increases
             UserModel* user = [UserModel currentUser];
             NSNumber* points = resultDict[@"data"][@"points"][@"totalPoints"];
             if (points && ![points isEqual:[NSNull null]]) {
                 user.pointTotal = points;
                 [user synchronizeUser];
             }

             [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:NO];
             [[NSNotificationCenter defaultCenter] postNotificationName:@"scheduledApponitment" object:nil];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
