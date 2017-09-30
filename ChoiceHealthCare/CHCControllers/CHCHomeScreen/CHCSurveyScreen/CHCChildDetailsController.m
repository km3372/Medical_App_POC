//
//  CHCChildDetailsController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/21/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCChildDetailsController.h"
#import "CHCChildDetailsCell.h"
#import "CHCConstants.h"
#import "APIClass.h"
#import "APINames.h"
#import "SWRevealViewController.h"
#import "Utils.h"

@interface CHCChildDetailsController ()<UITableViewDataSource , UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) IBOutlet UITableView *childListTableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewToBottom;
@property (nonatomic) BOOL isGenderButtonSelected;
@property (nonatomic) BOOL isDateOfBirthButtonSelected;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIView *datePickerView;
@property (strong, nonatomic) NSMutableArray *updatedDetails;
@property (strong, nonatomic) NSMutableDictionary *childDetails;
@property (strong, nonatomic) NSMutableArray *answersArray;
- (IBAction)genderButtonClick:(id)sender;
- (IBAction)dateOfBirthButtonClick:(id)sender;
- (IBAction)submitButtonClick:(id)sender;

@end

@implementation CHCChildDetailsController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
 
    self.updatedDetails = [[NSMutableArray alloc]init];
    self.answersArray = [NSMutableArray new];
    self.childDetails=[[NSMutableDictionary alloc]initWithDictionary:@{@"gendertype":@"Male",@"dateofbirth":@"mm/dd/yyyy",@"childname":@""} ];
    for (int i=0 ; i < self.numberOfRowForChildDetails; i++) {
        self.childDetails=[[NSMutableDictionary alloc]initWithDictionary:@{@"gendertype":@"Male",@"dateofbirth":@"mm/dd/yyyy",@"childname":@""} ];
        [self.updatedDetails addObject:self.childDetails];
    }
    self.isGenderButtonSelected         = NO;
    self.isDateOfBirthButtonSelected    = NO;
    [self.childListTableView reloadData];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    self.revealViewController.isFromHome=NO;
    self.choicePoints.text=self.choicePointsTotal;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRowForChildDetails;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChildDetails";
    self.childListTableView.allowsSelection=NO;
    CHCChildDetailsCell *cell = (CHCChildDetailsCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[CHCChildDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.childName.tag      = indexPath.row;
    cell.dateOfBirth.tag    = indexPath.row;
    cell.genderType.tag     = indexPath.row;
    self.childDetails       = (self.updatedDetails)[indexPath.row];
    if ([[self.childDetails valueForKey:@"childname"] isEqualToString:@""]) {
        cell.childName.text = @"";
    }else{
        cell.childName.text     = (self.childDetails)[@"childname"];}
    [cell.genderType setTitle:(self.childDetails)[@"gendertype"] forState:UIControlStateNormal];
    [cell.dateOfBirth setTitle:(self.childDetails)[@"dateofbirth"] forState:UIControlStateNormal];
    return cell;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)genderButtonClick:(id)sender {
    UIButton *button=sender;
    if (!self.isGenderButtonSelected && !self.isDateOfBirthButtonSelected) {
        self.isGenderButtonSelected = YES ;
         CHCChildDetailsCell *cell =  (CHCChildDetailsCell*)[self.childListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag     inSection:0]];
        [cell.childName resignFirstResponder];
        
        
        UIButton *genderButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [genderButton addTarget:self
                         action:@selector(genderButtonClickForSubtype:)
               forControlEvents:UIControlEventTouchUpInside];
        if ([button.titleLabel.text isEqualToString:@"Male"]) {
            [genderButton setTitle:@"Female" forState:UIControlStateNormal];
        }else if([button.titleLabel.text isEqualToString:@"Female"]){
            [genderButton setTitle:@"Male" forState:UIControlStateNormal];
        }
        
        [genderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        genderButton.backgroundColor = [UIColor blackColor];
        genderButton.frame = CGRectMake(button.frame.origin.x,button.frame.origin.y+31,button.frame.size.width,button.frame.size.height);
        genderButton.tag=button.tag;
        [cell.contentView addSubview:genderButton];
    }else{
        CHCChildDetailsCell *cell =  (CHCChildDetailsCell*)[self.childListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag     inSection:0]];

        if (cell.contentView.subviews.count>6) {
            [(cell.contentView.subviews)[6] removeFromSuperview];
            self.isGenderButtonSelected=NO;
        }

    
    }
  
    
}

-(void)genderButtonClickForSubtype:(UIButton *)genderButton{
    self.childDetails = (self.updatedDetails)[genderButton.tag];
    (self.childDetails)[@"gendertype"] = genderButton.titleLabel.text;
    (self.updatedDetails)[genderButton.tag] = self.childDetails;
    [self.childListTableView reloadData];
//    CHCChildDetailsCell *cell =  (CHCChildDetailsCell*)[self.childListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:genderButton.tag     inSection:0]];
//    [cell.genderType setTitle:genderButton.titleLabel.text forState:UIControlStateNormal];
    self.isGenderButtonSelected=NO;
    [genderButton removeFromSuperview];
}

- (IBAction)dateOfBirthButtonClick:(id)sender {
     UIButton *button=sender;
    if (!self.isDateOfBirthButtonSelected) {
        self.isDateOfBirthButtonSelected=YES;
        CHCChildDetailsCell *cell =  (CHCChildDetailsCell*)[self.childListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag     inSection:0]];
        [cell.childName resignFirstResponder];
        
        self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,40, self.view.frame.size.width,210)];
        (self.datePicker).datePickerMode = UIDatePickerModeDate;
        (self.datePicker).maximumDate = [NSDate date];
        self.datePicker.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeSystem];
        
        [cancel addTarget:self
                   action:@selector(cancelButtonClick:)
         forControlEvents:UIControlEventTouchUpInside];
        [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        cancel.frame = CGRectMake(0, 0,60.0, 40.0);
        cancel.tag = button.tag;
        UIButton *done = [UIButton buttonWithType:UIButtonTypeSystem];
        [done addTarget:self
                 action:@selector(doneButtonClick:)
       forControlEvents:UIControlEventTouchUpInside];
        [done setTitle:@"Done" forState:UIControlStateNormal];
        [done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        done.frame = CGRectMake(self.view.frame.size.width-50, 0,40.0, 40.0);
        done.tag=button.tag;
        
        self.datePickerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width, self.view.frame.size.height-250)];
        self.datePickerView.backgroundColor=[UIColor grayColor];
        [self.datePickerView addSubview:self.datePicker];
        [self.datePickerView addSubview:done];
        [self.datePickerView addSubview:cancel];
        
        [self.view addSubview:self.datePickerView];
    }
}

-(void)cancelButtonClick:(UIButton *)button {
    
    [self.datePickerView removeFromSuperview];
    self.isDateOfBirthButtonSelected=NO;
    
}

-(void)doneButtonClick:(UIButton *)button {

    NSDate *date=self.datePicker.date;
    
    if (![self validateDateIsSmallerThanCurrentDate:date]) {
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    
    //Optionally for time zone conversions
    NSString *stringFromDate = [formatter stringFromDate:date];

    self.childDetails = (self.updatedDetails)[button.tag];
    (self.childDetails)[@"dateofbirth"] = stringFromDate;
    (self.updatedDetails)[button.tag] = self.childDetails;

  
    [self.datePickerView removeFromSuperview];
     self.isDateOfBirthButtonSelected=NO;
    [self.childListTableView reloadData];
    
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


-(BOOL)saveDetailsIntoAnArray{
    if (self.updatedDetails.count != 0) {
        [self.updatedDetails removeAllObjects];
    }
//    for (int i=0 ; i < self.numberOfRowForChildDetails; i++) {
//          CHCChildDetailsCell *cell =  (CHCChildDetailsCell *)[self.childListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i     inSection:0]];
//
//        
//    }
    return YES;
}

- (IBAction)submitButtonClick:(id)sender {

    if ([self checkForAllValuesInDetails]) {
        NSMutableString *resultAnswerString=[[NSMutableString alloc] initWithString:@"1"];
        for (int i=0; i < self.updatedDetails.count; i++) {
           
            self.childDetails=(self.updatedDetails)[i];
            int gendertype=1;
            if ([(self.childDetails)[@"gendertype"] isEqualToString:@"Female"]) {
                gendertype=2;
            }
            NSString *answerString=[NSString stringWithFormat:@"&children[%d][name]=%@&children[%d][gender]=%d&children[%d][birthday]=%@",i,(self.childDetails)[@"childname"],i,gendertype,i,(self.childDetails)[@"dateofbirth"]];
            resultAnswerString=(NSMutableString *)[resultAnswerString stringByAppendingString:answerString];
        }

        resultAnswerString = (NSMutableString *)[resultAnswerString stringByReplacingOccurrencesOfString:@"/"
                                             withString:@"-"];        
        NSString *result=[resultAnswerString copy];
     
        [self.answersArray addObject:result];
     NSDictionary *tempDictionary = @{kQid:[NSString stringWithFormat:@"%ld",(long)self.qid ],kAnswers:self.answersArray,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    
         NSString *tempString=[NSString stringWithFormat:@"%@%@",kAnswerQuestion,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
        [[APIClass sharedManager] apiCallWithRequest:tempDictionary forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
            if ([resultDict[@"success"] boolValue]) {

                [self performSegueWithIdentifier:@"childdetailstosurvey" sender:self];

            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        } onCancelation:^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }];
       
    };
    
}

-(BOOL)checkForAllValuesInDetails {
    for (int i=0 ; i < self.updatedDetails.count; i++) {
        self.childDetails =(self.updatedDetails)[i];
        if ([(self.childDetails)[@"dateofbirth"] isEqualToString:@"mm/dd/yyyy"] || [(self.childDetails)[@"childname"] isEqualToString:@""]
            ) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Enter all child details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return NO;
        }
    }

    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    for (int i=0 ; i < self.numberOfRowForChildDetails; i++) {

        if (i == textField.tag && textField.tag < self.numberOfRowForChildDetails ) {
            [textField resignFirstResponder];
            CHCChildDetailsCell *cell =  (CHCChildDetailsCell*)[self.childListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag+1     inSection:0]];
            [self.childListTableView scrollRectToVisible:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+50, cell.frame.size.width, cell.frame.size.height) animated:NO];
            [cell.childName becomeFirstResponder];
         
        }else if(textField.tag == self.numberOfRowForChildDetails-1){
        [textField resignFirstResponder];
        }
    }
    
    return YES;

}
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!(self.isGenderButtonSelected || self.isDateOfBirthButtonSelected)) {
        self.tableViewToBottom.constant = 155;
        [self.view updateConstraints];
        
        CHCChildDetailsCell *cell =  (CHCChildDetailsCell*)[self.childListTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag     inSection:0]];
        [self.childListTableView scrollRectToVisible:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+200, cell.frame.size.width, cell.frame.size.height) animated:NO];
    }
    else{
        [textField resignFirstResponder];
        self.tableViewToBottom.constant = 0;
        [self.view updateConstraints];
    }


}



-(void)textFieldDidEndEditing:(UITextField *)textField {

    NSInteger temp=textField.tag;
    if (self.isDateOfBirthButtonSelected || self.isGenderButtonSelected) {
        self.tableViewToBottom.constant = 0;
        [self.view updateConstraints];
    }
    
    if (textField.tag == self.numberOfRowForChildDetails-1) {
        self.tableViewToBottom.constant = 0;
        [self.view updateConstraints];
     
    }

    self.childDetails=(self.updatedDetails)[textField.tag];

    (self.childDetails)[@"childname"] = textField.text;

    (self.updatedDetails)[temp] = self.childDetails;

    [self.childListTableView reloadData];
   
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
           
                UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
                
                [navController setViewControllers: @[dvc] animated: NO ];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
}

@end
