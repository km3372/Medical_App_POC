//
//  CHCHealthLogController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/19/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCHealthLogController.h"
#import "SWRevealViewController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import <QuartzCore/CALayer.h>
#import "CHCStatisticsForHealthLogCell.h"
@interface CHCHealthLogController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *chooseCategory;
- (IBAction)chooseCategoryButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel      *choicePoints;
@property (strong, nonatomic) IBOutlet UIButton     *revealView;
@property (strong, nonatomic) IBOutlet UITextField  *inputLog;
@property (strong, nonatomic) IBOutlet UIButton     *inputDate;
@property (strong, nonatomic) IBOutlet UIButton     *inputAMPM;
@property (strong, nonatomic) IBOutlet UILabel      *unittype;
@property (strong, nonatomic) IBOutlet UITableView  *categoriesTableview;

@property (strong, nonatomic) NSMutableArray *loggerCtegoriesList;
@property (strong, nonatomic) NSMutableArray *loggerStatisticsList;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIView *datePickerView;
@property (strong, nonatomic) IBOutlet UIButton *viewLogFor;
@property (strong, nonatomic) IBOutlet UILabel *statisticsFor;
@property (strong, nonatomic) NSMutableString *typeOfCategory;
@property (strong, nonatomic) NSMutableString *typeOfViewLog;
@property (strong, nonatomic) IBOutlet UITableView *statisticsTableView;

- (IBAction)viewLogForButtonClick:(id)sender;

- (IBAction)addButtonClick:(id)sender;
- (IBAction)inputAMPMButtonClick:(id)sender;
- (IBAction)inputDateButtonClick:(UIButton *)sender;
@property (strong, nonatomic) IBOutlet UITableView *viewLogForTableVIew;
@property (weak, nonatomic) IBOutlet UILabel *dailyAverage;



@end

@implementation CHCHealthLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.statisticsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.loggerCtegoriesList = [NSMutableArray new];
    self.chooseCategory.tag  = 0;
    self.inputAMPM.tag       = 0;
    self.inputDate.tag       = 0;
    self.viewLogFor.tag      = 0;
    self.inputLog.tag        = 0;
    
    self.categoriesTableview.clipsToBounds = YES;
    self.categoriesTableview.layer.masksToBounds = NO;
    (self.categoriesTableview.layer).shadowColor = [UIColor blackColor].CGColor;
    (self.categoriesTableview.layer).shadowOffset = CGSizeMake(0, 0);
    (self.categoriesTableview.layer).shadowRadius = 5.0;
    (self.categoriesTableview.layer).shadowOpacity = 1;


    
    self.viewLogForTableVIew.clipsToBounds = YES;
    self.viewLogForTableVIew.layer.masksToBounds = NO;
    (self.viewLogForTableVIew.layer).shadowColor = [UIColor blackColor].CGColor;
    (self.viewLogForTableVIew.layer).shadowOffset = CGSizeMake(0, 0);
    (self.viewLogForTableVIew.layer).shadowRadius = 5.0;
    (self.viewLogForTableVIew.layer).shadowOpacity = 1;

    (self.inputDate.titleLabel).textColor = [UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    [self getUserChoicePoints];
    [self getLoggerCategories];
    
    // Do any additional setup after loading the view.
}



-(void)viewDidAppear:(BOOL)animated {
    self.revealViewController.isFromHome=NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
                self.loggerCtegoriesList=[resultDict[@"data"] mutableCopy];
                NSMutableDictionary *tempDict=(self.loggerCtegoriesList)[0];
                [self.viewLogFor setTitle:tempDict[@"name"] forState:UIControlStateNormal];
                self.typeOfViewLog =tempDict[@"type"];
                [self getLoggerStatistics];
                [self.categoriesTableview reloadData];
                [self.viewLogForTableVIew reloadData];
            
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
-(void)getLoggerStatistics{
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetLoggerView,self.typeOfViewLog];
     NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {

            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                
                self.statisticsFor.text=[NSString stringWithFormat:@"Statistics for %@",self.viewLogFor.titleLabel.text];
                self.loggerStatisticsList=[resultDict[@"data"] mutableCopy];
             
                NSDictionary *statisticsInfo =(self.loggerStatisticsList)[0];
                self.dailyAverage.text = [NSString stringWithFormat:@"Daily Average :%@",statisticsInfo[@"average"]];
                [self.statisticsTableView reloadData];
                
//
            }
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:[NSString stringWithFormat:@"No statistics for %@",self.viewLogFor.titleLabel.text] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            self.statisticsFor.text=[NSString stringWithFormat:@"Statistics for %@",self.viewLogFor.titleLabel.text];
            [self.loggerStatisticsList removeAllObjects];
            [self.statisticsTableView reloadData];
            
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } ];
    
    
}

- (IBAction)viewLogForButtonClick:(id)sender {
    [self.view bringSubviewToFront:self.viewLogForTableVIew];
    if (self.viewLogFor.tag == 0 && self.chooseCategory.tag==0 && self.inputDate.tag==0 && self.inputLog.tag == 0) {
        self.viewLogFor.tag = 1;
        self.viewLogForTableVIew.hidden=NO;
        [self.viewLogForTableVIew flashScrollIndicators];
    }else{
        self.viewLogFor.tag = 0;
        self.viewLogForTableVIew.hidden=YES;
    }
    
}

- (IBAction)addButtonClick:(id)sender {
    if ([self checkDetailstoBeSent]) {
        NSDictionary *object = @{@"data":[NSString stringWithFormat:@"%@",self.inputLog.text],@"date":self.inputDate.titleLabel.text,@"type":self.typeOfCategory,@"daytime":self.inputAMPM.titleLabel.text,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
        [[APIClass sharedManager]apiCallWithRequest:object forApi:kGetLoggerInsertJson requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
            if ([resultDict[@"success"] boolValue]) {

                UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Added log successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                self.inputLog.text = @"";
                self.inputDate.tag = 0 ;
                [self.inputDate setTitle:@"mm/dd/yyyy" forState:UIControlStateNormal];
                [self.inputDate setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                
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
    if ([self.chooseCategory.titleLabel.text isEqualToString:@"--Choose what to log--"] ||
        self.inputLog.text.length == 0  || [self.inputDate.titleLabel.text isEqualToString:@"mm/dd/yyyy"]) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Enter all mandatory fields required to add log" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    return YES;
}

- (IBAction)inputAMPMButtonClick:(id)sender {
    if (self.inputAMPM.tag == 0) {
        self.inputAMPM.tag = 1;
        [self.inputAMPM setTitle:@"PM" forState:UIControlStateNormal];
    }else{
        self.inputAMPM.tag = 0;
        [self.inputAMPM setTitle:@"AM" forState:UIControlStateNormal];
    }
}

- (IBAction)inputDateButtonClick:(UIButton *)sender {
    if (sender.tag == 0 && self.viewLogFor.tag == 0 && self.chooseCategory.tag==0 && self.inputLog.tag == 0 ) {
        self.inputDate.tag = 1 ;
        [self addDatePickerView];
    }else{
        self.inputDate.tag = 0;
        [self.datePickerView removeFromSuperview];
    }
}

-(void)cancelButtonClick:(UIButton *)button {
   
    self.inputDate.tag = 0 ;
    [self.datePickerView removeFromSuperview];
    if ([self.inputDate.titleLabel.text isEqualToString:@"mm/dd/yyyy"]) {
        [self.inputDate setTitleColor:[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [self.inputDate setTitleColor:[UIColor colorWithRed:199.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else{ [self.inputDate setTitleColor:[UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.inputDate setTitleColor:[UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0] forState:UIControlStateSelected];
    }
    
}
-(void)doneButtonClick:(UIButton *)button {
    
    
    self.inputDate.tag = 0 ;
    NSDate *date=self.datePicker.date;
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    
    //Optionally for time zone conversions
    NSString *stringFromDate = [formatter stringFromDate:date];

   
    [self.inputDate setTitle:stringFromDate forState:UIControlStateNormal];
    [self.inputDate setTitleColor:[UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.inputDate setTitleColor:[UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0] forState:UIControlStateSelected];


    [self.datePickerView removeFromSuperview];
    

}

-(void)addDatePickerView {
    self.datePicker=[[UIDatePicker alloc]initWithFrame:CGRectMake(0,40, self.view.frame.size.width,210)];
    (self.datePicker).datePickerMode = UIDatePickerModeDate;
    self.datePicker.backgroundColor=[UIColor whiteColor];
    
    UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancel addTarget:self
               action:@selector(cancelButtonClick:)
     forControlEvents:UIControlEventTouchUpInside];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancel.frame = CGRectMake(0, 0,60.0, 40.0);
    
    UIButton *done = [UIButton buttonWithType:UIButtonTypeSystem];
    [done addTarget:self
             action:@selector(doneButtonClick:)
   forControlEvents:UIControlEventTouchUpInside];
    [done setTitle:@"Done" forState:UIControlStateNormal];
    [done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    done.frame = CGRectMake(self.view.frame.size.width-50, 0,40.0, 40.0);
    
    
    self.datePickerView=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width, self.view.frame.size.height-250)];
    self.datePickerView.backgroundColor=[UIColor grayColor];
    [self.datePickerView addSubview:self.datePicker];
    [self.datePickerView addSubview:done];
    [self.datePickerView addSubview:cancel];
    
    [self.view addSubview:self.datePickerView];

}
- (IBAction)chooseCategoryButtonClick:(id)sender {
    [self.view bringSubviewToFront:self.categoriesTableview];
    if (self.chooseCategory.tag == 0 && self.viewLogFor.tag == 0 && self.inputDate.tag==0 && self.inputLog.tag == 0) {
        self.chooseCategory.tag = 1;
        self.categoriesTableview.hidden=NO;
        [self.categoriesTableview flashScrollIndicators];
        
    }else{
        self.chooseCategory.tag = 0;
        self.categoriesTableview.hidden=YES;
    }
}

#pragma mark - TableView

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.categoriesTableview || tableView == self.viewLogForTableVIew) {
        if (self.loggerCtegoriesList.count != 0) {
            return self.loggerCtegoriesList.count;
        }
    }else if (tableView == self.statisticsTableView){
        if (self.loggerStatisticsList.count != 0) {
            return self.loggerStatisticsList.count;
        }
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   
    if(tableView == self.categoriesTableview || tableView == self.viewLogForTableVIew) {
    static NSString *CellIdentifier = @"MY_CELL";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.textColor=[UIColor grayColor];
    NSDictionary *categoriesInfo = (self.loggerCtegoriesList)[indexPath.row];
    cell.textLabel.text = categoriesInfo[@"name"];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
        return cell;
    }else if (tableView == self.statisticsTableView){
        static NSString *CellIdentifier = @"StatisticCell";
        
        CHCStatisticsForHealthLogCell *cell = (CHCStatisticsForHealthLogCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CHCStatisticsForHealthLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        NSDictionary *logInfo = (self.loggerStatisticsList)[indexPath.row];
        if (logInfo.count > 1) {
            cell.dateOfLog.text = logInfo[@"timestamp"];
        }else{
        cell.dateOfLog.text = @"";
        }
        if (logInfo.count > 1 ) {
            cell.unitsOfLog.text = [NSString stringWithFormat:@"%@ %@",logInfo[@"data"],logInfo[@"unit"]];
        }else{
            cell.unitsOfLog.text = @"";
        }
        
        
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        return cell;
    }
    static NSString *CellIdentifier = @"StatisticCell";
    
    CHCStatisticsForHealthLogCell *cell = (CHCStatisticsForHealthLogCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CHCStatisticsForHealthLogCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *categoryInfo = (self.loggerCtegoriesList)[indexPath.row];
    if (tableView == self.categoriesTableview) {
        self.typeOfCategory = categoryInfo[@"type"];
        self.unittype.text  = categoryInfo[@"unit"];
        self.categoriesTableview.hidden = YES;
        self.chooseCategory.tag = 0;
        self.inputLog.text = @"";
        self.inputDate.tag = 0 ;
        [self.inputDate setTitle:@"mm/dd/yyyy" forState:UIControlStateNormal];
        [self.inputDate setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
        [self.chooseCategory setTitle:categoryInfo[@"name"] forState:UIControlStateNormal];
    }else if (tableView == self.viewLogForTableVIew){
    self.viewLogForTableVIew.hidden = YES;
        self.viewLogFor.tag = 0;
        self.typeOfViewLog = categoryInfo[@"type"];
        [self getLoggerStatistics];
        [self.viewLogFor setTitle:categoryInfo[@"name"] forState:UIControlStateNormal];    
    
    }
  
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark - Textfield
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    self.inputLog.tag = 0;
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (textField==self.inputLog) {
        if (self.chooseCategory.tag == 0 && self.viewLogFor.tag == 0 && self.inputDate.tag==0 && self.inputLog.tag == 0) {
            self.inputLog.tag = 1;
            
        }else{
            self.inputLog.tag = 0;
            [textField resignFirstResponder];
        }
    }


}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length)
        return YES;
    
    if ( textField == self.inputLog ) {
        
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
#pragma ViewEvent..
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.inputDate.tag=0;
    self.datePickerView.hidden=YES;
    self.chooseCategory.tag=0;
    self.categoriesTableview.hidden=YES;
    self.viewLogFor.tag=0;
    self.viewLogForTableVIew.hidden=YES;
    self.inputLog.tag=0;
    [self.inputLog resignFirstResponder];
    
}

@end
