//
//  CHCSurveyController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/19/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCSurveyController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "AnswerCell.h"
#import "CHCChildDetailsController.h"
#import "SWRevealViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Utils.h"

NS_ENUM (NSInteger, CategoryType){
    CategoryTypeSingle = 0,
    CategoryTypeMultiple,
    CategoryTypeNumeric,
    CategoryTypeChildList,
    CategoryTypeCHC,
    CategoryTypeCustom
};
NS_ENUM (NSInteger, RenderSubType){
    RenderTypeAge= 0,
    RenderTypeHeight,
    RenderTypeWeight,
    RenderTypeCancerStage,
    RenderTypeNull
};
@interface CHCSurveyController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    enum CategoryType currentType;
    enum RenderSubType currentSubType;
}
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) IBOutlet UILabel *questionLabel;
@property (strong, nonatomic) IBOutlet UITableView *answersTableView;
@property (strong, nonatomic) IBOutlet UIButton *submit;
@property (strong, nonatomic) NSMutableArray *displayAnswersArray;
@property (strong, nonatomic) NSMutableArray *answersArray;
@property (strong, nonatomic) UIDatePicker *datePicker;
@property (strong, nonatomic) UIView *datePickerView;
@property (strong, nonatomic) UITextField *feet;
@property (strong, nonatomic) UITextField *inch;
@property (strong, nonatomic) UILabel *feetLbl;
@property (strong, nonatomic) UILabel *inchLbl;
@property (strong, nonatomic) NSMutableArray *multipleSelection;
@property (strong, nonatomic) CHCChildDetailsController *childDetails;
@property (strong, nonatomic) UIImageView *chcImageView;
@property (nonatomic) NSInteger qid;
@property (nonatomic) NSInteger answerid;
@property (nonatomic) NSInteger orderid;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sizeForQuestionLabel;
- (IBAction)submitButtonClick:(id)sender;

@end

@implementation CHCSurveyController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];  
    self.submit.layer.borderColor = [UIColor blackColor].CGColor;
    self.submit.layer.borderWidth = 1.0;
    self.submit.layer.cornerRadius = 10;
    self.submit.clipsToBounds = YES;
    self.displayAnswersArray    = [NSMutableArray new];
    self.answersArray           = [NSMutableArray new];
    self.multipleSelection      = [NSMutableArray new];
    [self getUserChoicePoints];
//    [self getSurveyNextQuestion];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doTheReload:)
                                                 name:@"childListSent"object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
   // [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    self.revealViewController.isFromHome=NO;
}

-(void)doTheReload:(NSNotification *)notification {  

    [self getUserChoicePoints];
    [self getSurveyNextQuestion];
}

-(void)getSurveyNextQuestion{

    currentSubType = RenderTypeNull;
    NSString *tempString=[NSString stringWithFormat:@"%@%@",kSurvey,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager] apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {

        if ([resultDict[@"success"] boolValue]) {
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                
                self.submit.enabled=NO;
                if ([resultDict[kRenderType] isEqualToString:kSingle ]) {
                    currentType=CategoryTypeSingle;
                    currentSubType = RenderTypeNull;
                    self.answersTableView.allowsMultipleSelection = NO;
                }else if ([resultDict[kRenderType] isEqualToString:kMultiple ]){
                    currentType=CategoryTypeMultiple;
                    currentSubType = RenderTypeNull;
                    self.answersTableView.allowsMultipleSelection = YES;
                    if (self.multipleSelection.count != 0 ) {
                        [self.multipleSelection removeAllObjects];
                    }
                }else if ([resultDict[kRenderType] isEqualToString:kNumeric ]){
                    if ([resultDict[@"render_subtype"] isEqualToString:@"height"]) {
                        currentSubType=RenderTypeHeight;
                    }else if ([resultDict[@"render_subtype"] isEqualToString:@"weight"]) {
                        currentSubType=RenderTypeWeight;
                    }else if([resultDict[@"render_subtype"] isEqualToString:@"age"]) {
                        currentSubType=RenderTypeAge;
                    }else if([resultDict[@"render_subtype"] isEqualToString:@"cancer_stage"]) {
                        currentSubType=RenderTypeCancerStage;
                    }
                    currentType=CategoryTypeNumeric;
                    self.answersTableView.allowsMultipleSelection = NO;
                }else if ([resultDict[kRenderType] isEqualToString:kChildList ]) {
                    currentType=CategoryTypeChildList;
                    self.answersTableView.allowsMultipleSelection = NO;
                }else if ([resultDict[kRenderType] isEqualToString:kCHC ]) {
                    currentType=CategoryTypeCHC;
                    self.answersTableView.allowsMultipleSelection = NO;
                }else if ([resultDict[kRenderType] isEqualToString:kCustom ]) {
                    currentType=CategoryTypeCustom;
                    self.answersTableView.allowsMultipleSelection = NO;
                }
                self.orderid = [resultDict[@"orderid"] integerValue];
                self.qid = [resultDict[kQid] integerValue];
                NSString *string=resultDict[@"title"];
                if (string.length > 71) {
                    self.sizeForQuestionLabel.constant=90.0;
                    [self.view updateConstraints];
                    (self.questionLabel).numberOfLines = 3;
                }else if (string.length > 36) {
                    self.sizeForQuestionLabel.constant=60.0;
                    [self.view updateConstraints];
                    (self.questionLabel).numberOfLines = 2;
                }else{
                    self.sizeForQuestionLabel.constant=30.0;
                    [self.view updateConstraints];
                    (self.questionLabel).numberOfLines = 1;
                    
                }
                self.questionLabel.text=string;
                if (![resultDict[kAnswers] isEqual:(id)[NSNull null]]) {
                    self.displayAnswersArray=[resultDict[kAnswers] mutableCopy];
                   
                    [self.answersTableView reloadData];
                }else {
                    switch (currentType) {
                        case CategoryTypeNumeric: {
                            if(self.displayAnswersArray.count != 0){
                                [self.displayAnswersArray removeAllObjects];}
                            NSDictionary *temp=@{@"answer":@"mm/dd/yyyy"};
                            [self.displayAnswersArray addObject:temp];
                            self.qid=[resultDict[kQid] integerValue];
                            [self.answersTableView reloadData];
                            break;}
                            
                        case CategoryTypeChildList: {
                            self.qid=[resultDict[kQid] integerValue];
                            if (self.displayAnswersArray.count != 0) {
                                [self.displayAnswersArray removeAllObjects];
                            }
                            for (int i = 0 ; i < 10; i++) {
                                NSDictionary *tempDict=@{@"answer":[NSString stringWithFormat:@"%d",i],kAnswerid:[NSString stringWithFormat:@"%d",i]};
                                
                                [self.displayAnswersArray addObject:tempDict];
                                
                            }
                            [self.answersTableView reloadData];
                            
                            break;
                        case CategoryTypeCHC:
                            self.qid=[resultDict[kQid] integerValue];
                            if (self.displayAnswersArray.count != 0) {
                                [self.displayAnswersArray removeAllObjects];
                            }
                            [self getCHCListOfHospitals];
                            
                            break;
                        case CategoryTypeCustom:
                            if(self.displayAnswersArray.count != 0){
                                [self.displayAnswersArray removeAllObjects];
                            }
                            NSDictionary *temp=@{@"answer":@""};
                            [self.displayAnswersArray addObject:temp];
                            self.qid=[resultDict[kQid] integerValue];
                            [self.answersTableView reloadData];
                            break;
                        }
                    }
                }
            } else if ([resultDict[@"message"]isEqualToString:@"You have reached the end of the survey."]) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:@"You have reached the end of the survey." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                alert.tag=100;
                [alert show];
            }
        }
    } onCancelation:^{
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

-(void)getCHCListOfHospitals {
     NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetCHC,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
     NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager] apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            self.displayAnswersArray = [resultDict[@"data"] mutableCopy];
    
            [self.answersTableView reloadData];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.displayAnswersArray.count !=0 ) {
        return self.displayAnswersArray.count;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"MY_CELL";
    
    AnswerCell *cell = (AnswerCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:137.0/255.0 green:204.0/255.0 blue:231.0/255.0 alpha:1.0];
    cell.selectedBackgroundView = bgColorView;

    NSDictionary *answerDictionary = (self.displayAnswersArray)[indexPath.row];
    UIImageView *chcImageView = (UIImageView *)[cell.contentView viewWithTag:7654];
    [chcImageView removeFromSuperview];
    for (int i=0; i < self.view.subviews.count; i++) {
        UIView *subview=(self.view.subviews)[i];
        if (subview.tag == 7654) {
            [subview removeFromSuperview];
            
        }
    }
    if (currentSubType == RenderTypeHeight) {
 
        bgColorView.backgroundColor=[UIColor whiteColor];
        cell.selectedBackgroundView = bgColorView;
        cell.answerLabel.text=@"";

        self.feet = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x-110.0, 100, 50, 30)];
        (self.feet).spellCheckingType = UITextSpellCheckingTypeNo;
        (self.feet).autocorrectionType = UITextAutocorrectionTypeNo;
        (self.feet).keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.feet.delegate=self;
        self.feet.textColor = [UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0];
        (self.feet).font = [UIFont fontWithName:@"System" size:16];
        self.feet.backgroundColor=[UIColor lightGrayColor];
        self.feetLbl = [[UILabel alloc]initWithFrame:CGRectMake(self.view.center.x-55.0, 100, 50 , 30)];
        self.feetLbl.text = @"Feet";
        (self.feetLbl).font = [UIFont fontWithName:@"System" size:16];
        self.feetLbl.textColor = [UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.feetLbl.textAlignment = NSTextAlignmentCenter;
        
        self.inch = [[UITextField alloc] initWithFrame:CGRectMake(self.view.center.x+5.0, 100, 50, 30)];
        (self.inch).spellCheckingType = UITextSpellCheckingTypeNo;
        (self.inch).autocorrectionType = UITextAutocorrectionTypeNo;
        (self.inch).keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.inch.delegate=self;
        self.inch.textColor = [UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0];
        (self.inch).font = [UIFont fontWithName:@"System" size:16];
        self.inch.backgroundColor = [UIColor lightGrayColor];
        
        self.inchLbl = [[UILabel alloc]initWithFrame:CGRectMake(self.view.center.x+60.0, 100, 50 , 30)];
        self.inchLbl.text = @"Inch";
        (self.inchLbl).font = [UIFont fontWithName:@"System" size:16];
        self.inchLbl.textColor = [UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.inchLbl.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.feet];
        [self.view addSubview:self.feetLbl];
        [self.view addSubview:self.inch];
        [self.view addSubview:self.inchLbl];
        [self.view bringSubviewToFront:self.feet];
        [self.view bringSubviewToFront:self.feetLbl];
        [self.view bringSubviewToFront:self.inch];
        [self.view bringSubviewToFront:self.inchLbl];
        
    }else if (currentSubType == RenderTypeWeight) {
        UIImageView *chcImageView = (UIImageView *)[cell.contentView viewWithTag:7654];
        [chcImageView removeFromSuperview];
        for (int i=0; i < self.view.subviews.count; i++) {
            UIView *subview=(self.view.subviews)[i];
            if (subview.tag == 7654) {
                [subview removeFromSuperview];
                break;
            }
        }
        cell.answerLabel.text=@"";
        [self.feet removeFromSuperview];
        [self.feetLbl removeFromSuperview];
        [self.inch removeFromSuperview];
        [self.inchLbl removeFromSuperview];
        bgColorView.backgroundColor=[UIColor whiteColor];
        cell.selectedBackgroundView = bgColorView;

        
        self.inch = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.origin.x+20, 100, self.view.frame.size.width-95, 30)];
        (self.inch).spellCheckingType = UITextSpellCheckingTypeNo;
        (self.inch).autocorrectionType = UITextAutocorrectionTypeNo;
        (self.inch).keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.inch.delegate=self;
        self.inch.textColor = [UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0];
        (self.inch).font = [UIFont fontWithName:@"System" size:16];
        self.inch.backgroundColor = [UIColor lightGrayColor];
        self.inch.tag=223;
        self.inchLbl = [[UILabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width-75.0, 100, 50 , 30)];
        self.inchLbl.text = @"lbs";
        (self.inchLbl).font = [UIFont fontWithName:@"System" size:16];
        self.inchLbl.textColor = [UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0];
        self.inchLbl.textAlignment = NSTextAlignmentCenter;
  
        [self.view addSubview:self.inch];
        [self.view addSubview:self.inchLbl];
        [self.view bringSubviewToFront:self.inch];
        [self.view bringSubviewToFront:self.inchLbl];

    
    
    }else if(currentType == CategoryTypeCHC){
     
        UIImageView *chcImageView =[[UIImageView alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-50,4, 100, 47)];
        chcImageView.tag = 7654;
        cell.answerLabel.text=@"";
        NSMutableString *imageString = (NSMutableString *)(self.displayAnswersArray)[indexPath.row];
        imageString = [[@"http://reapon.com/" stringByAppendingString:imageString] mutableCopy];
      
        [chcImageView setImageWithURL:[NSURL URLWithString:imageString] placeholderImage:[UIImage imageNamed:@"logo.png"]];
        [cell.contentView addSubview:chcImageView];
        [cell.contentView bringSubviewToFront:chcImageView];
    }else if (currentType == CategoryTypeCustom) {
        bgColorView.backgroundColor=[UIColor whiteColor];
        cell.selectedBackgroundView = bgColorView;
        cell.answerLabel.text=@"";
        UIImageView *chcImageView = (UIImageView *)[cell.contentView viewWithTag:7654];
        [chcImageView removeFromSuperview];
        for (int i=0; i < self.view.subviews.count; i++) {
            UIView *subview=(self.view.subviews)[i];
            if (subview.tag == 7654) {
                [subview removeFromSuperview];
                break;
            }
        }
        
        self.inch = [[UITextField alloc] initWithFrame:CGRectMake(30, self.questionLabel.frame.size.height+80, self.view.frame.size.width-60, 30)];
        (self.inch).spellCheckingType = UITextSpellCheckingTypeNo;
        (self.inch).autocorrectionType = UITextAutocorrectionTypeNo;
        (self.inch).keyboardType = UIKeyboardTypeAlphabet;
        self.inch.delegate=self;
        self.inch.textColor = [UIColor colorWithRed:28.0/255.0 green:63.0/255.0 blue:98.0/255.0 alpha:1.0];
        (self.inch).font = [UIFont fontWithName:@"System" size:16];
        self.inch.backgroundColor = [UIColor lightGrayColor];
        self.inch.tag=223;
        
        [self.view addSubview:self.inch];
        [self.view bringSubviewToFront:self.inch];
    
    }else {
      
        UIImageView *chcImageView = (UIImageView *)[cell.contentView viewWithTag:7654];
        [chcImageView removeFromSuperview];
        for (int i=0; i < self.view.subviews.count; i++) {
            UIView *subview=(self.view.subviews)[i];
            if (subview.tag == 7654) {
                [subview removeFromSuperview];
                break;
            }
        }
        self.inch=(UITextField *)[cell.contentView viewWithTag:222];
        [self.inch removeFromSuperview];
        for (int i=0; i < self.view.subviews.count; i++) {
            UIView *subview=(self.view.subviews)[i];
            if (subview.tag == 223) {
                [subview removeFromSuperview];
                break;
            }
        }
         
        [self.inch removeFromSuperview];
        [self.chcImageView removeFromSuperview];
        [self.feetLbl removeFromSuperview];
        [self.feet removeFromSuperview];
        [self.inch removeFromSuperview];
        [self.inchLbl removeFromSuperview];
        
        cell.answerLabel.text = answerDictionary[@"answer"];
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (currentType) {
        case CategoryTypeSingle:{
            self.submit.enabled=YES;
            self.answerid=[(self.displayAnswersArray)[indexPath.row][kAnswerid] integerValue];
            if (self.answersArray.count != 0) {
               [self.answersArray removeAllObjects];
            }
            [self.answersArray addObject:[NSString stringWithFormat:@"%ld",(long)self.answerid]];
            break;}
        case CategoryTypeNumeric:
            if (currentSubType==RenderTypeAge || currentSubType==RenderTypeCancerStage) {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                
                self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,40, self.view.frame.size.width,210)];
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
                
                
                self.datePickerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-250, self.view.frame.size.width, self.view.frame.size.height-250)];
                self.datePickerView.backgroundColor = [UIColor grayColor];
                [self.datePickerView addSubview:self.datePicker];
                [self.datePickerView addSubview:done];
                [self.datePickerView addSubview:cancel];
                
                [self.view addSubview:self.datePickerView];
            }
            break;
        case CategoryTypeMultiple:
            self.submit.enabled=YES;
            self.answerid=[(self.displayAnswersArray)[indexPath.row][kAnswerid] integerValue];
            [self.multipleSelection addObject:[NSString stringWithFormat:@"%ld",(long)self.answerid]];

            if (self.answersArray.count != 0) {
                [self.answersArray removeAllObjects];
            }
            [self.answersArray addObjectsFromArray:self.multipleSelection];
            break;
        case CategoryTypeChildList:{
            self.submit.enabled=YES;
            self.answerid=[(self.displayAnswersArray)[indexPath.row][kAnswerid] integerValue];
            if (self.answersArray.count != 0) {
                [self.answersArray removeAllObjects];
            }
            [self.answersArray addObject:[NSString stringWithFormat:@"%ld",(long)self.answerid]];
            break;
            break;}
        case CategoryTypeCHC:
            self.submit.enabled=YES;
            self.answerid=indexPath.row;
            if (self.answersArray.count != 0) {
                [self.answersArray removeAllObjects];
            }
            [self.answersArray addObject:[NSString stringWithFormat:@"%ld",(long)self.answerid]];
            break;
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (currentType) {
        case CategoryTypeMultiple:
            self.answerid=[(self.displayAnswersArray)[indexPath.row][kAnswerid] integerValue];
            for (int i=0 ; i < self.multipleSelection.count ; i++) {
                        if ([(self.multipleSelection)[i] isEqualToString:[NSString stringWithFormat:@"%ld",(long)self.answerid]]) {
                            [self.multipleSelection removeObjectAtIndex:i];
                        }
                    }
            if (self.multipleSelection.count == 0) {
                self.submit.enabled = NO;
            }else{
                self.submit.enabled = YES;
            }
            break;
            default:
            break;
    }
}

-(void)cancelButtonClick:(UIButton *)button {
    
    [self.datePickerView removeFromSuperview];
}


- (void)doneButtonClick:(UIButton *)button {
    self.submit.enabled=YES;
    
    NSDate *date = self.datePicker.date;
   
    if (![self validateDateIsSmallerThanCurrentDate:date]) {
        return;
    }
   
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    
    //Optionally for time zone conversions
    NSString *stringFromDate = [formatter stringFromDate:date];
    NSDictionary *temp=@{@"answer":stringFromDate};
    if (self.displayAnswersArray.count != 0) {
        [self.displayAnswersArray removeAllObjects];
    }
    
    [self.displayAnswersArray addObject:temp];
    [self.datePickerView removeFromSuperview];
    [self.answersTableView reloadData];
    if (self.answersArray.count != 0) {
        [self.answersArray removeAllObjects];
    }
    [self.answersArray addObject:stringFromDate];
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

- (IBAction)submitButtonClick:(id)sender {
    [self answerTheQuestion];
}

-(void)answerTheQuestion {
    if (currentType != CategoryTypeChildList) {
        NSDictionary *tempDictionary = @{kQid:[NSString stringWithFormat:@"%ld",(long)self.qid ],kAnswers:self.answersArray,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
         NSString *tempString=[NSString stringWithFormat:@"%@%@",kAnswerQuestion,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
        [[APIClass sharedManager]apiCallWithRequest:tempDictionary forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
            if ([resultDict[@"success"]boolValue]) {
                if (self.orderid==5) {
                    [self.feet removeFromSuperview];
                    [self.inch removeFromSuperview];
                }
                [self getUserChoicePoints];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        } onCancelation:^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }else{
        NSInteger temp=[(self.answersArray)[0] integerValue];
        if (temp==0) {
            NSDictionary *tempDictionary = @{kQid:[NSString stringWithFormat:@"%ld",(long)self.qid ],kAnswers:self.answersArray,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
             NSString *tempString=[NSString stringWithFormat:@"%@%@",kAnswerQuestion,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
            [[APIClass sharedManager]apiCallWithRequest:tempDictionary forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
                if ([resultDict[@"success"]boolValue]) {
                    if (self.orderid==5) {
                        [self.feet removeFromSuperview];
                        [self.inch removeFromSuperview];
                    }
                    [self getUserChoicePoints];
                    
                }else{
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                }
                
            } onCancelation:^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }];
            
        }else{
            [self performSegueWithIdentifier:@"survytochilddetails" sender:self];
//            self.childDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"ChildListController"];
//            self.childDetails.numberOfRowForChildDetails = temp;
//            self.childDetails.choicePointsTotal=self.choicePoints.text;
//            self.childDetails.qid=self.qid;
//            self.childDetails.view.frame = self.view.bounds;
//            
//            [self.view addSubview:self.childDetails.view];
//            [self addChildViewController:self.childDetails];
//            [self.childDetails didMoveToParentViewController:self];
        }
    }
}

-(void)getUserChoicePoints {
     NSString *tempString=[NSString stringWithFormat:@"%@%@",kGetPoints,[[NSUserDefaults standardUserDefaults] objectForKey:kUid]];
     NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:tempString requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            self.choicePoints.text=[NSString stringWithFormat:@"%ld",(long)[resultDict[@"totalpoints"] integerValue]];
            [self getSurveyNextQuestion];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } ];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==self.feet) {
        [self.feet resignFirstResponder];
        [self.inch becomeFirstResponder];
    }else if(textField==self.inch){
        [self.inch resignFirstResponder];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    if (!string.length)
//        return YES;
//    if (textField   ==  self.feet || textField == self.inch) {
//        if (string.length == 0) {
//            self.submit.enabled = NO;
//        }else{
//            self.submit.enabled = YES;
//        }
//    }
    if (textField==self.inch) {
        [self.inch addTarget:self
                      action:@selector(textFieldDidChangeForInch:)
            forControlEvents:UIControlEventEditingChanged];
    }else if (textField == self.feet){
        [self.feet addTarget:self
                      action:@selector(textFieldDidChangeForFeet:)
            forControlEvents:UIControlEventEditingChanged];
    }
 
    
    if ((textField == self.feet || textField == self.inch) && currentType!=CategoryTypeCustom  )
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

-(void)textFieldDidChangeForInch:(id)sender {
    
    if (currentType == CategoryTypeCustom || currentSubType == RenderTypeWeight) {
        if (self.inch.text.length == 0){
            self.submit.enabled=NO;
        }else {
            self.submit.enabled=YES;
        }
    }
}

-(void)textFieldDidChangeForFeet:(id)sender{
    
    if (self.feet.text.length == 0){
        self.submit.enabled=NO;
    }else {
        self.submit.enabled=YES;
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if ((textField == self.feet && self.orderid == 5)|| (textField == self.inch && self.orderid == 5)) {

        NSString *heightString = [NSString stringWithFormat:@"%@'%@",self.feet.text,self.inch.text];
        if (self.answersArray.count != 0) {
            [self.answersArray removeAllObjects];
        }
    
        [self.answersArray addObject:heightString];
    }else if (textField == self.inch && self.orderid == 6) {
        NSString *weightString = [NSString stringWithFormat:@"%@",self.inch.text];
        if (self.answersArray.count != 0) {
            [self.answersArray removeAllObjects];
        }
        [self.answersArray addObject:weightString];
    }else if(textField == self.inch && currentType==CategoryTypeCustom){
      
        NSString *weightString = [NSString stringWithFormat:@"%@",self.inch.text];
        if (self.answersArray.count != 0) {
            [self.answersArray removeAllObjects];
        }
        [self.answersArray addObject:weightString];
    }


}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (CategoryTypeCHC==currentType) {
//        return 55;
//    }
    return 55;
}

#pragma AlertView...
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==100) {
        switch (buttonIndex) {
           default:
                [self performSegueWithIdentifier:@"revealtohomeback" sender:self];
                break;
        }
    }

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            if ([segue.identifier isEqualToString:@"revealtohome"] && self.revealViewController.isFromHome) {
                [self.revealViewController.navigationController popToRootViewControllerAnimated:YES];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            }else{
                UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
                
                [navController setViewControllers: @[dvc] animated: NO ];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
                if ([segue.identifier isEqualToString:@"survytochilddetails"]) {
                    CHCChildDetailsController *chcChildDetailsController = (CHCChildDetailsController *)segue.destinationViewController ;
                    chcChildDetailsController.numberOfRowForChildDetails = [(self.answersArray)[0] integerValue];
                    chcChildDetailsController.choicePointsTotal=self.choicePoints.text;
                    chcChildDetailsController.qid=self.qid;
                    
                }
                
            }
        };
        
    }
}
@end
