//
//  CHCReminderController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/10/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCReminderController.h"
#import "CHCReminderCell.h"
#import "AppDelegate.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "SWRevealViewController.h"
@interface CHCReminderController ()<UITableViewDataSource,UITableViewDelegate>

#pragma Reminder Contents...
@property (strong, nonatomic) UIApplication *application;
@property (strong, nonatomic) IBOutlet UIButton *onButton;
@property (strong, nonatomic) IBOutlet UIButton *offButton;
@property (strong, nonatomic) NSMutableArray *remindersList;
@property (strong, nonatomic) NSMutableDictionary *medicineDetails;
- (IBAction)onButtonClick:(id)sender;
- (IBAction)offButtonClick:(id)sender;

#pragma Main View...

@property (strong, nonatomic) IBOutlet UITableView *reminderTableView;

@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;


@end

@implementation CHCReminderController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    self.application = [UIApplication sharedApplication];
    self.remindersList = [NSMutableArray new];
    self.medicineDetails = [NSMutableDictionary new];
    [self updateButtonView:self.onButton];
    [self updateButtonView:self.offButton];
   
    self.offButton.tag  = 1;
    self.onButton.tag   = 0;
    [self getMedicineInfo];
  
    
}

-(void)getMedicineInfo {
    
    NSDictionary *object = @{kRemid:@5,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};

[[APIClass sharedManager]apiCallWithRequest:object forApi:kRemindersFetchOne requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
    if ([resultDict[@"success"]boolValue]) {
        self.medicineDetails = resultDict[@"0"];
        if ( [resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil ) {
            
            NSDictionary *dict = resultDict[@"data"][0];
            self.remindersList = dict[@"reminders"];
            [self.reminderTableView reloadData];

        
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

-(void)viewDidAppear:(BOOL)animated{
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = app.scheduledLocalNotifications;
    self.revealViewController.isFromHome = NO;
    for (int i=0; i<eventArray.count; i++) {
        UILocalNotification* oneEvent = eventArray[i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *medicine = [NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"medicine"]];
        if ([medicine isEqualToString:@"Kryptonite"])
        {
            //Cancelling local notification
            self.onButton.tag = 1;
            self.offButton.tag = 0;
            [self.onButton setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [self.offButton setTitleColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            break;
        }
    }


}

- (void)updateButtonView:(UIButton*)button{
    //updating button view according to design..
    button.tag=0;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1.0;
    //    button.layer.cornerRadius = 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.remindersList.count != 0 ) {
        return  self.remindersList.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellIdentifier = @"ReminderCell";
    CHCReminderCell *cell =(CHCReminderCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.myBorderView.layer.borderColor = [UIColor grayColor].CGColor;
    cell.myBorderView.layer.borderWidth  = 2.0;
    NSDictionary *reminderInfo = (self.remindersList)[indexPath.row];
    cell.time.text = reminderInfo[@"time"];
    cell.dose.text = [NSString stringWithFormat:@"%@%@",reminderInfo[@"dose"],reminderInfo[@"unit"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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

- (IBAction)onButtonClick:(id)sender {
    if (self.onButton.tag == 0) {
        
        self.onButton.tag   =1;
        self.offButton.tag  =0;
        [self.onButton setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.offButton setTitleColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        for (int i = 0 ; i < self.remindersList.count ; i++) {
            
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            
            NSCalendar *calendar = [NSCalendar currentCalendar];
            
            NSDateComponents *components = [calendar components:( NSMonthCalendarUnit | NSYearCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit |NSDayCalendarUnit ) fromDate:[NSDate date]];
            components.timeZone = calendar.timeZone;
            NSDictionary *reminderInfo=(self.remindersList)[i];
            NSArray* foo = [reminderInfo[@"time"] componentsSeparatedByString: @":"];
            NSString *hour=foo[0];
            NSString *minute=foo[1];
        
            components.hour = hour.integerValue;
            components.minute = minute.integerValue;
            components.second = 0;
            calendar.timeZone = [NSTimeZone localTimeZone];
            
            NSDate *dateToFire = [calendar dateFromComponents:components];
            

            
            notification.fireDate = dateToFire;
            notification.timeZone = [NSTimeZone localTimeZone];
            notification.userInfo = @{@"medicine":(self.medicineDetails)[@"med"]};
            
            notification.alertBody  = @"This is local notification!";
            notification.soundName  = UILocalNotificationDefaultSoundName;
            notification.repeatInterval = NSDayCalendarUnit;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

- (IBAction)offButtonClick:(id)sender {
    if (self.offButton.tag == 0) {
        self.offButton.tag   =1;
        self.onButton.tag  =0;
        [self.offButton setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.onButton setTitleColor:[UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *eventArray = app.scheduledLocalNotifications;
       
        for (int i=0; i<eventArray.count; i++) {
            UILocalNotification* oneEvent = eventArray[i];
            NSDictionary *userInfoCurrent = oneEvent.userInfo;
            NSString *medicine = [NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"medicine"]];
            if ([medicine isEqualToString:@"Kryptonite"])
            {
                //Cancelling local notification
                [app cancelLocalNotification:oneEvent];
                
            }
        }
        
    }

    
    
}
@end
