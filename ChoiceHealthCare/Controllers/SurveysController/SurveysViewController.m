//
//  SurveysViewController.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/29/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "SurveysViewController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "SurveyCell.h"
#import "CommonFilesImporter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "InstructionsViewController.h"

@interface SurveysViewController ()
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation SurveysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Survey Questions"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    [self fetchQuestion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)instructionButtonClicked:(id)sender {

    InstructionsViewController *controller = [[InstructionsViewController alloc] initWithNibName:@"InstructionsViewController" bundle:[NSBundle mainBundle]];

    controller.helpText = @"Surveys are special bonus points earning events occurring through the year that allow you to boost your points earnings through your participation. Surveys reward you for confidentially sharing your preferences and opinions on a variety of potential topics, which may include lifestyle, politics, healthcare, travel, and much more. Surveys are easy, fun and rewarding.";

    [self.navigationController pushViewController:controller animated:true];
}


#pragma mark - TableView Delegates and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _questionDataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isMultipleChoice) {
        _tableView.allowsMultipleSelection = YES;
    }
    else{
        _tableView.allowsMultipleSelection = NO;
    }
    
    static NSString* CellIdentifier = @"SurveyCell";
    SurveyCell* answerCell = (SurveyCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (answerCell == nil) {
        answerCell = [[SurveyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    answerCell.answerLabel.text = _questionDataArray[indexPath.section][@"answer"];
    
    (answerCell.layer).cornerRadius = 7.0f;
    [answerCell.layer setMasksToBounds:YES];
    (answerCell.layer).borderWidth = 1.0f;
    (answerCell.layer).borderColor = [UIColor colorWithWhite:0.8 alpha:0.8].CGColor;
     answerCell.backgroundColor = [UIColor whiteColor];

    
    return answerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedIndex =  @(indexPath.section);
    
    //allow multiple selection
    if ([_selectionArray containsObject: _questionDataArray[indexPath.section][@"answerid"]])
    {
        [_selectionArray removeObject:_questionDataArray[indexPath.section][@"answerid"]];
    }
    else
    {
        [_selectionArray addObject:_questionDataArray[indexPath.section][@"answerid"]];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_selectionArray containsObject: _questionDataArray[indexPath.section][@"answerid"]])
    {
        [_selectionArray removeObject:_questionDataArray[indexPath.section][@"answerid"]];
    }
}


#pragma mark - API Calls

-(void) fetchQuestion{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _questionDataArray = [NSMutableArray new];
    _selectionArray = [NSMutableArray new];
    
    NSDictionary *requestDictionary =  @{kSid:@"2"};
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:kSurvey
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             
             if ([resultDict[@"message"] isEqual:[NSNull null]] ||
                 [resultDict[@"message"] isEqualToString:@""] ||
                 resultDict[@"message"] == nil  ) {
                 
                 _titleLabel.text = (resultDict[@"data"])[@"title"];
                 _questionId = (resultDict[@"data"])[@"qid"];
                 
                 if ([(resultDict[@"data"])[@"render_type"] isEqualToString:@"multiple"]) {
                     isMultipleChoice = YES;
                 }
                 else{
                     isMultipleChoice = NO;
                 }
                 
                 NSArray *dataArray = (resultDict[@"data"])[@"answers"];
                 for (int i=0; i<dataArray.count; i++) {
                     NSDictionary *itemInfo = dataArray[i];
                     
                     NSLog(@"Item info: %@", itemInfo);
                     [_questionDataArray addObject:itemInfo];
                 }
                 [_tableView reloadData];
             }
             else
             {
                 NSString *errorMessage = resultDict[@"message"];
                 [Utils showAlertForString:errorMessage];
                 [self exitSurvey];
             }
         }
         else
         {
             NSString *errorMessage = resultDict[@"message"];
             [Utils showAlertForString:errorMessage];
             [_tableView reloadData];
         }
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}

-(void) answerQuestion{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *requestDictionary =  @{kQid:_questionId, @"answers": _selectionArray};
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:kAnswerQuestion
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             
                 NSString* updatedTotal = resultDict[@"points"][@"totalPoints"];
                 if (updatedTotal && ![updatedTotal isEqual:[NSNull null]]) {
                     UserModel* user = [UserModel currentUser];
                     user.pointTotal = @(updatedTotal.integerValue);
                     [user synchronizeUser];
                 }

                 [MBProgressHUD hideAllHUDsForView:self.view animated:true];
                 selectedIndex = nil;
                 [self fetchQuestion];
         }
         else
         {
             NSString *errorMessage = resultDict[@"message"];
             [MBProgressHUD hideAllHUDsForView:self.view animated:true];
             [Utils showAlertForString:errorMessage];
             [_tableView reloadData];
         }
       
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}


- (IBAction)nextButtonPressed:(id)sender {
    if (selectedIndex != nil || _selectionArray == nil) {
        [self answerQuestion];
    }
    else{
        [Utils showAlertForString:@"Please select an answer"];
    }
}

-(void)exitSurvey {
    _nextButton.hidden = YES;
    _questionDataArray = nil;
    [_tableView reloadData];
    
    _titleLabel.text = @"Survey Complete";
    isSurveyComplete = YES;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Survey Complete"
                                                    message:@"You have reached the end of the survey."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
