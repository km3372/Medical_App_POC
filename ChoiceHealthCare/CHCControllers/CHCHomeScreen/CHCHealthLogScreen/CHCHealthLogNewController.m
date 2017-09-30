//
//  CHCHealthLogNewController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/29/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCHealthLogNewController.h"
#import "SWRevealViewController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CHCWeekDayCell.h"
#import "HorizontalTableViewCell.h"
#import "PTEHorizontalTableView.h"
#import "CHCViewFullHistoryController.h"
#import "Utils.h"
@interface CHCHealthLogNewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,PTETableViewDelegate,UITextFieldDelegate,UIScrollViewDelegate>

#pragma MainView..

@property (weak, nonatomic) IBOutlet UIButton *revealView;
@property (weak, nonatomic) IBOutlet UILabel *choicePoints;
@property (weak, nonatomic) IBOutlet UIView *healthLogInstructionView;
@property (weak, nonatomic) IBOutlet UIScrollView *healthDataLogScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *healthDataLogVerticalHeightConstraint;

#pragma HealthLogInstructionView..

@property (weak, nonatomic) IBOutlet UIButton *healthLogInstructionButton;
- (IBAction)healthLogInstructionButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *instructionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *healthLogInstructionViewHeightConstraint;

#pragma HealthLogDataScrollView...
@property (weak, nonatomic) IBOutlet UIView *scrollViewContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewContentViewHeightConstraint;

@property (weak, nonatomic) IBOutlet UITableView *horizontalTableView;
@property (weak, nonatomic) IBOutlet UIView *logYourHealthDataView;
@property (weak, nonatomic) IBOutlet UIButton *callHotlineButton;
- (IBAction)callHotlineButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *aboutUsButton;
- (IBAction)aboutUsButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *callForAppointmentButton;
- (IBAction)callForAppointmentButtonClick:(id)sender;

#pragma HorizontalTableView...
@property(strong , nonatomic)NSMutableDictionary *viewFullHistory;

- (IBAction)viewFullHistoryButtonClick:(UIButton *)sender;



#pragma LogYourHealthDataView...
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logYourHealthDataVIewHeightConstraint;

@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (weak, nonatomic) IBOutlet UIButton *chooseWhatToLogButton;
- (IBAction)chooseWhatToLogButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIButton *selectDateButton;
- (IBAction)selectDateButtonClick:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *logView;
@property (weak, nonatomic) IBOutlet UILabel *typeOfUnitsLabel;
@property (weak, nonatomic) IBOutlet UITextField *logDataTextField;


@property (weak, nonatomic) IBOutlet UIButton *addDataButton;
- (IBAction)addDataButtonClick:(id)sender;

#pragma Extra...
@property (strong, nonatomic) NSMutableArray *totalLoggerInfo;
@property (strong, nonatomic) NSMutableArray *categoryList;
#pragma CustomView...
@property (weak, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UIView *datePickerView;
@property (weak, nonatomic) IBOutlet UITableView *categoryListTableView;

#pragma DatePickerView...
@property (strong, nonatomic) IBOutlet UIDatePicker *myDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *cancelDatePickerButton;
- (IBAction)cancelDatePickerButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneDatePickerButton;
- (IBAction)doneDatePickerButtonClick:(id)sender;




@end

@implementation CHCHealthLogNewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewFullHistory = [NSMutableDictionary new];
    self.customView.tag= 999;
    self.categoryListTableView.hidden=YES;
    self.customView.hidden = YES;
    self.logView.hidden = YES;
    self.datePickerView.hidden = YES;
    [self.customView bringSubviewToFront:self.categoryListTableView];
    (self.myDatePicker).datePickerMode = UIDatePickerModeDate;
   [self.view bringSubviewToFront:self.customView];
    self.healthLogInstructionButton.tag=0;
    // Do any additional setup after loading the view.
    self.totalLoggerInfo    = [NSMutableArray new];
    self.categoryList       = [NSMutableArray new];
    [self updateView:self.healthLogInstructionButton];
    self.healthLogInstructionButton.layer.cornerRadius = 6;
    self.healthLogInstructionButton.clipsToBounds = YES;
    [self updateView:self.healthLogInstructionView];
    [self updateView:self.categoryView];
    (self.categoryView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]] ;
    
    [self updateView:self.dateView];
    (self.dateView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]] ;
    [self updateView:self.chooseWhatToLogButton];
    [self updateView:self.selectDateButton];
    [self updateView:self.addDataButton];
    self.addDataButton.layer.cornerRadius = 6.0;
    self.addDataButton.clipsToBounds = YES;
    self.logYourHealthDataView.layer.borderColor = [UIColor grayColor].CGColor;
    self.logYourHealthDataView.layer.borderWidth  = 2.0;
    self.logYourHealthDataView.layer.cornerRadius = 15;
    [self updateView:self.callForAppointmentButton];
    [self updateView:self.callHotlineButton];
    [self updateView:self.aboutUsButton];
    [self updateView:self.addDataButton];
    [self updateView:self.logView];
    (self.logView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]] ;
    [self updateView:self.logDataTextField];
    
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    [self getUserChoicePoints];
    [self getLoggerLogInformation];
    [self getLoggerCategories];
}

- (void)updateView:(UIView *)view{
    //updating button view according to design..
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0;
    //    view.layer.cornerRadius = 20;
}
-(void)getUserChoicePoints {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetPoints,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            self.choicePoints.text=[NSString stringWithFormat:@"%ld",(long)[resultDict[@"totalpoints"] integerValue]];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    } ];
}


-(void)getLoggerCategories {
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetLoggerCategories,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"]boolValue]) {
            
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
            
                self.categoryList = resultDict[@"data"];
                [self.categoryListTableView reloadData];
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } ];
}

-(void)getLoggerLogInformation {
   
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:kGetLoggerViewAll requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"]boolValue]) {
            
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
              
                self.totalLoggerInfo = resultDict[@"data"];
                [self.horizontalTableView reloadData];
                
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } ];
}

-(void)viewDidAppear:(BOOL)animated{
    self.revealViewController.isFromHome=NO;
}

-(UIImage *)startBlur{
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the image
    CIImage *blurImg = [CIImage imageWithCGImage:viewImg.CGImage];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:blurImg forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@2.0f forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImg = [context createCGImage:gaussianBlurFilter.outputImage fromRect:blurImg.extent];
    UIImage *outputImg = [UIImage imageWithCGImage:cgImg];
    return outputImg;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)healthLogInstructionButtonClicked:(id)sender {
    
    if (self.healthLogInstructionButton.tag == 0 ) {
        self.healthLogInstructionButton.tag = 1;
        [self.healthLogInstructionButton setTitle:@"Got it!" forState:UIControlStateNormal];
        (self.healthLogInstructionViewHeightConstraint).constant = (self.view.frame.size.height-65.0);
          (self.healthDataLogVerticalHeightConstraint).constant = self.view.frame.size.height;
        [self.view bringSubviewToFront:self.healthLogInstructionView];
        self.instructionTextView.hidden = NO;
        
    }else{
        self.healthLogInstructionButton.tag = 0;
        [self.healthLogInstructionButton setTitle:@"Logger Instructions!" forState:UIControlStateNormal];
        (self.healthLogInstructionViewHeightConstraint).constant = 35.0;
        (self.healthDataLogVerticalHeightConstraint).constant = 43.0;
        self.instructionTextView.hidden = YES;
    }
}
- (IBAction)callHotlineButtonClick:(id)sender {
    [self.logDataTextField resignFirstResponder];
    UIAlertView *callHotline = [[UIAlertView alloc]initWithTitle:@"Call for Appointment" message:@"678-210-9937" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
    callHotline.tag=678;
    [callHotline show];
  
}
- (IBAction)aboutUsButtonClick:(id)sender {
    [self.logDataTextField resignFirstResponder];
//older..
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://choicep.localmarketinginc.com/"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.choicepointsapp.com/"]];
    
}
- (IBAction)callForAppointmentButtonClick:(id)sender {
    [self.logDataTextField resignFirstResponder];
    UIAlertView *callForAppointmentAlert = [[UIAlertView alloc]initWithTitle:@"Call for Appointment" message:@"404-688-1350" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Call", nil];
    callForAppointmentAlert.tag=404;
    [callForAppointmentAlert show];
 
  
}

- (IBAction)addDataButtonClick:(id)sender {

    [self.logDataTextField resignFirstResponder];
    if ([self checkDetailstoBeSent]) {
        NSDictionary *object = @{@"data":[NSString stringWithFormat:@"%@",self.logDataTextField.text],@"date":self.selectDateButton.titleLabel.text,@"type":self.chooseWhatToLogButton.titleLabel.text,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
        [[APIClass sharedManager]apiCallWithRequest:object forApi:kGetLoggerInsertJson requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
            if ([resultDict[@"success"] boolValue]) {
                
                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Added log successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                self.logDataTextField.text = @"";
                [self.chooseWhatToLogButton setTitle:@"--Choose what to log--" forState:UIControlStateNormal];
                [self.selectDateButton setTitle:@"mm/dd/yyyy" forState:UIControlStateNormal];
                [self.selectDateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                self.logView.hidden =YES;
                (self.scrollViewContentViewHeightConstraint).constant = 780.0;
                (self.logYourHealthDataVIewHeightConstraint).constant = 170.0;
                
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        } onCancelation:^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }

    
}
-(BOOL)checkDetailstoBeSent{
    if ([self.chooseWhatToLogButton.titleLabel.text isEqualToString:@"--Choose what to log--"] ||
        self.chooseWhatToLogButton.titleLabel.text.length == 0  || [self.selectDateButton.titleLabel.text isEqualToString:@"mm/dd/yyyy"] || self.logDataTextField.text.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Enter all mandatory fields required to add log" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (IBAction)chooseWhatToLogButtonClick:(id)sender {
    [self.logDataTextField resignFirstResponder];
    self.customView.backgroundColor=[UIColor colorWithPatternImage:[self startBlur]];
    (self.categoryListTableView).frame = CGRectMake(self.categoryListTableView.frame.origin.x, self.categoryListTableView.frame.origin.y, self.categoryListTableView.frame.size.width, self.categoryList.count*46.0);
    (self.categoryListTableView).center = CGPointMake(self.customView.center.x, self.customView.center.y);
    self.categoryListTableView.hidden=NO;
    self.customView.hidden = NO ;
    
    
}
- (IBAction)selectDateButtonClick:(id)sender {
    [self.logDataTextField resignFirstResponder];
    self.customView.backgroundColor=[UIColor colorWithPatternImage:[self startBlur]];
    self.datePickerView.hidden=NO;
    self.customView.hidden=NO;
    
}
- (IBAction)viewFullHistoryButtonClick:(UIButton *)sender {
    [self.logDataTextField resignFirstResponder];
    self.viewFullHistory=(self.totalLoggerInfo)[sender.tag];
    NSLog(@"%@",self.navigationController.viewControllers);
    [self performSegueWithIdentifier:@"viewfullhistory" sender:self];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (alertView.tag) {
        case 404:{
            switch (buttonIndex) {
                case 0:
                    
                    break;
                case 1:{
                    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"4046881350"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
                    break;
                }
                    
                    
            }
            
           
            break;
        }
        case 678:{
            switch (buttonIndex) {
                case 0:
                   
                    break;
                case 1:{
                 
                    NSString *phoneNumber = [@"tel://" stringByAppendingString:@"6782109937"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
                    break;}
                    
            }
            
            NSLog(@"call hotline");
            break;
        }
    }
    
}
- (IBAction)cancelDatePickerButtonClick:(id)sender {

    self.customView.hidden = YES;
    self.datePickerView.hidden = YES;
    
}
- (IBAction)doneDatePickerButtonClick:(id)sender {
 
    NSDate *date=self.myDatePicker.date;
 
    if (![self validateDateIsSmallerThanCurrentDate:date]) {
        return;
    }

    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    
    //Optionally for time zone conversions
    NSString *stringFromDate = [formatter stringFromDate:date];
    [self.selectDateButton setTitleColor:[UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.selectDateButton setTitle:stringFromDate forState:UIControlStateNormal];
    
    
    self.customView.hidden =YES;
    self.datePickerView.hidden=YES;
    
}

/**
 *  This method will compare the date is less than samller date
 *
 *  @param selectedDate
 *
 *  @return Boolean value
 */
- (BOOL)validateDateIsSmallerThanCurrentDate:(NSDate *)selectedDate {
    
    NSDate *currentDate = [NSDate date];
    
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&selectedDate interval:NULL forDate:selectedDate];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit startDate:&currentDate interval:NULL forDate:currentDate];
    
    if ([selectedDate compare:currentDate] == NSOrderedDescending) {
        
        [Utils showAlertForString:@"Please select date less than or equal to todays date"];
        
        return false;
    }
    return true;
}

#pragma TableView Delegates and Datasource methods..

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.categoryListTableView]) {
        if (self.categoryList.count != 0) {
            return self.categoryList.count;
        }
    }else if([tableView isEqual:self.horizontalTableView]){
    
        if (self.totalLoggerInfo.count !=0) {
            return self.totalLoggerInfo.count;
        }
    }
    
    
    return 0;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    if ([tableView isEqual:self.horizontalTableView]) {
//        return 250.0;
//    }else
    return 46.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:self.categoryListTableView]) {
        NSDictionary *categoryInfo = (self.categoryList)[indexPath.row];
        self.logDataTextField.text=@"";
        [self.selectDateButton setTitle:@"mm/dd/yyyy" forState:UIControlStateNormal];
        [self.selectDateButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.chooseWhatToLogButton setTitle:categoryInfo[@"name"] forState:UIControlStateNormal];
        self.typeOfUnitsLabel.text = categoryInfo[@"unit"];
        self.categoryListTableView.hidden = YES;
        self.customView.hidden = YES;
        (self.logYourHealthDataVIewHeightConstraint).constant = 210.0;
        (self.scrollViewContentViewHeightConstraint).constant = 820.0;
        self.logView.hidden=NO;
        
        
        
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.categoryListTableView]) {
        static NSString *MyIdentifier = @"WeekDayCell";
        
        CHCWeekDayCell *cell =(CHCWeekDayCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        
        UIView *bgColorView = [[UIView alloc] init];
        bgColorView.backgroundColor = self.categoryListTableView.backgroundColor;
        cell.selectedBackgroundView = bgColorView;
        NSMutableDictionary *categoryInfo = (self.categoryList)[indexPath.row];
        cell.dayOfWeek.text =categoryInfo[@"name"];
        
        cell.isSelectedImageView.hidden=YES;
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *MyIdentifier = @"pink_cell";
    HorizontalTableViewCell *cell =(HorizontalTableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        return cell;
    
    }

}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet* allTouches = event.allTouches;
    UITouch* touch = [allTouches anyObject];
    UIView* touchView = touch.view;
   
    if (touchView.tag == 999 ) {
      
        self.customView.hidden=YES;
        self.datePickerView.hidden = YES;
        self.categoryListTableView.hidden = YES;
        
        
    }
    
}
-(NSInteger)horizontalTableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section{

    return self.totalLoggerInfo.count;
}

- (CGFloat)horizontalTableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath{
    return 500.0;
}

- (UITableViewCell *)horizontalTableView:(PTEHorizontalTableView *)horizontalTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    HorizontalTableViewCell * cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"pink_cell"];
    NSDictionary *cellInfo=(self.totalLoggerInfo)[indexPath.row];
   
    cell.loggerCategoryTitleLabel.text=cellInfo[@"name"];
    NSArray *logListInfoArray=cellInfo[@"data"];
    cell.loggerInfoView.layer.borderColor = [UIColor grayColor].CGColor;
    cell.loggerInfoView.layer.borderWidth  = 2.0;
    cell.loggerInfoView.layer.cornerRadius = 20;
    cell.loggerCategoryAverageLabel.text=[NSString stringWithFormat:@"Average: %0.2f",[logListInfoArray[0][@"average"] floatValue]];
    cell.viewFullHistoryButton.tag = indexPath.row;
    [cell reloadTableViewContent:logListInfoArray];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.clipsToBounds = YES;
  
    return cell;
}
-(void)horizontalTableView:(PTEHorizontalTableView *)horizontalTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{


}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
        return YES;
    
    if (textField == self.logDataTextField)
    {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, newString.length)];
        if (numberOfMatches == 0)
            return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.healthDataLogScrollView scrollRectToVisible:CGRectMake(0, 0, self.view.frame.size.width, 800.0) animated:YES];

}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//     if([segue.identifier isEqualToString:@"viewfullhistory"]){
//         CHCViewFullHistoryController *viewFullHistoryController = (CHCViewFullHistoryController *)segue.destinationViewController;
//         viewFullHistoryController.viewFullHistory = self.viewFullHistory;
//     }
// }
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {

            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            
            
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            if([segue.identifier isEqualToString:@"viewfullhistory"]){
                CHCViewFullHistoryController *viewFullHistoryController = (CHCViewFullHistoryController *)segue.destinationViewController;
                viewFullHistoryController.viewFullHistory = self.viewFullHistory;
            }
            //        }
        };
        
    }
}




//- (CGFloat)horizontalTableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath{
//    return 0;
//}


@end
