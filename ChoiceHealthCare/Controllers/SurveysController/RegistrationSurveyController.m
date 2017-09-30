//
//  RegistrationSurveyController.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 9/9/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "RegistrationSurveyController.h"
#import "APIClass.h"
#import "APINames.h"
#import "AppDelegate.h"
#import "SurveyCell.h"
#import "CommonFilesImporter.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface RegistrationSurveyController ()

@end

@implementation RegistrationSurveyController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.title = @"Registration Survey";
    
    questions =  @[@"22", @"26", @"27", @"29", @"331", @"332"];
    
    [self addBottomButton];
    [self initilizeButtons];
}


-(void) viewWillAppear:(BOOL)animated{
    // [self fetchQuestion];
   // [self answerQuestion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return 5;
}

-(void) initilizeButtons{
    [_nationalityButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
     _nationalityButton.tag = 1;
    
    [_medicalConditionsButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _medicalConditionsButton.tag = 2;
    
    [_raceButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _raceButton.tag = 3;
    
    [_heightButton addTarget:self action:@selector(heightButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    _weightTextField.delegate = self;
}

- (void)addBottomButton {
    
    _completeButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 620, self.view.frame.size.width, 50)];
    
    _completeButton.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - CGRectGetHeight(_completeButton.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(_completeButton.frame));
    [_completeButton setTitle:@"COMPLETE" forState:UIControlStateNormal];
    [_completeButton setBackgroundColor: CHOICE_LIGHT_BLUE];
    [_completeButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view insertSubview:_completeButton aboveSubview:self.tableView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    CGRect frame2 = _completeButton.frame;
    frame2.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - _completeButton.frame.size.height;
    _completeButton.frame = frame2;
    
    [self.view bringSubviewToFront:_completeButton];
}


-(void)buttonPressed:(id)sender{
    
    switch (((UIButton*)sender).tag) {
        case 1:
            [self fetchQuestion:@"331"];
            _questionType = QuestionTypeNationality;
            break;
        case 2:
            [self fetchQuestion:@"332"];
             _questionType = QuestionTypeMedical;
            break;
        case 3:
            [self fetchQuestion:@"22"];
             _questionType = QuestionTypeRace;
            break;
            
        default:
            break;
    }
}


-(void)heightButtonPressed{
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Select height (ft - in)" delegate:self];
    picker.tag = 2;
    picker.titlesForComponents = @[@[@"4", @"5", @"6", @"7"],
                                     @[@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11"]];
    [picker show];
}


-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    NSString *title = [NSString stringWithFormat:@"%@ ft %@ in", titles[0], titles[1]];
    _userHeight = [NSString stringWithFormat:@"%@' %@\"",titles[0], titles[1]];
    [_heightButton setTitle:title forState:UIControlStateNormal];
    [_heightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}



#pragma mark - API Calls

-(void) fetchQuestion: (NSString*) questionId {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
     _questionDataArray = [NSMutableArray new];
    
    NSDictionary *requestDictionary =  @{kQid:questionId};
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:kGetQuestion
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             
             if ([resultDict[@"message"] isEqual:[NSNull null]] ||
                 [resultDict[@"message"] isEqualToString:@""] ||
                 resultDict[@"message"] == nil  ) {
                 
                 NSArray *dataArray = (resultDict[@"data"])[@"answers"];
                 for (int i=0; i<dataArray.count; i++) {
                     NSDictionary *itemInfo = dataArray[i];
                     
                     NSLog(@"Item info: %@", itemInfo);
                     [_questionDataArray addObject:itemInfo];
                 }
                 [self showSpecialityPicker];
             }
             else if ([resultDict[@"message"] isEqualToString:@"You have reached the end of the survey."]){
               //  [self exitSurvey];
             }
         }
         else
         {
             NSString *errorMessage = resultDict[@"message"];
             [Utils showAlertForString:errorMessage];
           //  [_tableView reloadData];
         }
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}

-(void) showSpecialityPicker{
    
    NSString *title;
    
    switch (_questionType) {
        case  QuestionTypeNationality:
            title = @"Select Nationality";
            break;
        case  QuestionTypeMedical:
            title = @"Select Conditions";
            break;
        case  QuestionTypeRace:
            title = @"Select Race";
            break;
            
        default:
            break;
    }
    
    CZPickerView *picker = [[CZPickerView alloc] initWithHeaderTitle:title cancelButtonTitle:@"Cancel" confirmButtonTitle:@"Confirm"];
    picker.delegate = self;
    picker.dataSource = self;
    picker.needFooterView = YES;
    
    if (_questionType == QuestionTypeMedical) {
        picker.allowMultipleSelection = YES;
    }
    [picker show];
}

/* comment out this method to allow
 CZPickerView:titleForRow: to work.
 */
- (NSAttributedString *)czpickerView:(CZPickerView *)pickerView
               attributedTitleForRow:(NSInteger)row{
    
    NSAttributedString *att = [[NSAttributedString alloc]
                               initWithString:(_questionDataArray[row])[@"answer"]
                               attributes:@{
                                            NSFontAttributeName:[UIFont fontWithName:@"Avenir-Light" size:18.0]
                                            }];
    return att;
}

- (NSString *)czpickerView:(CZPickerView *)pickerView
               titleForRow:(NSInteger)row{
    return (_questionDataArray[row])[@"answer"];
}

- (NSInteger)numberOfRowsInPickerView:(CZPickerView *)pickerView {
    return _questionDataArray.count;
}

- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemAtRow:(NSInteger)row {
    NSLog(@"%@ is chosen!", (_questionDataArray[row])[@"answer"]);
    NSString *title = (_questionDataArray[row])[@"answer"];
    
    switch (_questionType) {
        case  QuestionTypeNationality:
            [_nationalityButton setTitle:title forState:UIControlStateNormal];
            [_nationalityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _nationalityQId = (_questionDataArray[row])[@"answerid"];
            break;
        case  QuestionTypeMedical:
            [_medicalConditionsButton setTitle:title forState:UIControlStateNormal];
            [_medicalConditionsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _medicalQId = (_questionDataArray[row])[@"answerid"];
            break;
        case  QuestionTypeRace:
            [_raceButton setTitle:title forState:UIControlStateNormal];
            [_raceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _raceQId= (_questionDataArray[row])[@"answerid"];
            break;
            
        default:
            break;
    }
    
   /// _searchTextField.text =  [_questionDataArray[row] objectForKey:@"name"];
   // _selectedRow = row;
}


- (void)czpickerView:(CZPickerView *)pickerView didConfirmWithItemsAtRows:(NSArray *)rows {
    
    _medicalConditionsArray = [[NSMutableArray alloc] init];
   //  NSString *title = [_questionDataArray[row] objectForKey:@"answer"]
   // NSString *joinedComponents = [[rows valueForKey:@"answer" ] componentsJoinedByString:@","];
    [_medicalConditionsButton setTitle:@"Completed" forState:UIControlStateNormal];
    [_medicalConditionsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    for (NSNumber *n in rows) {
        NSInteger row = n.integerValue;
        NSLog(@"%@ is chosen!", (_questionDataArray[row])[@"answer"]);
        _medicalQId = (_questionDataArray[row])[@"answerid"];
        [_medicalConditionsArray addObject:_medicalQId];
    }
}

- (void)czpickerViewDidClickCancelButton:(CZPickerView *)pickerView {
    NSLog(@"Canceled.");
}

- (void)czpickerViewWillDisplay:(CZPickerView *)pickerView {
    NSLog(@"Picker will display.");
}

- (void)czpickerViewDidDisplay:(CZPickerView *)pickerView {
    NSLog(@"Picker did display.");
}

- (void)czpickerViewWillDismiss:(CZPickerView *)pickerView {
    NSLog(@"Picker will dismiss.");
}

- (void)czpickerViewDidDismiss:(CZPickerView *)pickerView {
    NSLog(@"Picker did dismiss.");
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if(range.location == 4)
                return NO;
    
    return YES;

}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _userWeight = _weightTextField.text;

    _weightTextField.text = [NSString stringWithFormat:@"%@ lbs", _userWeight];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    _weightTextField.text = @"";
}


-(void) answerQuestion{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSDictionary *requestDictionary =  @{kQid:@"26", @"answers": @"12"};
    
    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:kAnswerQuestion
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
             
             if ([resultDict[@"message"] isEqual:[NSNull null]] ||
                 [resultDict[@"message"] isEqualToString:@""] ||
                 [resultDict[@"message"] isEqualToString:@"OK"] ||
                 resultDict[@"message"] == nil  ) {
             }
         }
         else
         {
             NSString *errorMessage = resultDict[@"message"];
             [Utils showAlertForString:errorMessage];
         }
         
     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}

-(void)doneButtonPressed{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    count = questions.count -1;
    [self answerQuestion:questions[count]];
    
    // [self answerQuestion];
}

-(void) answerQuestion: (NSString*) questionId {
    
    NSArray *answerArray;
    
    if ([questionId isEqualToString:@"22"]) {  //Race
      answerArray =  @[_raceQId];
    }
    if ([questionId isEqualToString:@"26"]) {
        answerArray =  @[_userHeight];
    }
    if ([questionId isEqualToString:@"27"]) {
        answerArray =  @[_userWeight];
    }
    if ([questionId isEqualToString:@"29"]) {
        answerArray =  @[@"No"];
    }
    if ([questionId isEqualToString:@"331"]) {
        answerArray =  @[_nationalityQId];
    }
    if ([questionId isEqualToString:@"332"]) {
        answerArray =  _medicalConditionsArray;//[[NSArray alloc]initWithObjects: _medicalQId,nil];
    }

    NSDictionary *requestDictionary =  @{kQid:questionId, @"answers": answerArray };

    [[APIClass sharedManager] apiCallWithRequest:requestDictionary
                                          forApi:kAnswerQuestion
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {

             count = count -1;
             
             if (count >= 0) {
                 [self answerQuestion:questions[count]];
             }
             else{
                 [self loginButtonPressed];
                }
         }
         else
         {
             NSString *errorMessage = resultDict[@"message"];
             [MBProgressHUD hideAllHUDsForView:self.view animated:true];

             [Utils showAlertForString:errorMessage];
            // [_tableView reloadData];
         }

     } onCancelation:^{
         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
         [Utils showAlertForString:kInternetConnectionNotAvailable];
     }];
}


-(void)loginButtonPressed{
    
    UserModel* user = [UserModel currentUser];
    
    NSDictionary *postDictionary = @{KUsername:user.email,kPassword:user.password};
    
    SHOW_HUD(self.view);
    
    [[APIClass sharedManager] apiCallWithRequest:postDictionary
                                          forApi:kLogin
                                     requestMode:kModePost
                                    onCompletion:^(NSDictionary *resultDict, NSError *error) {
                                        
                                        if ([resultDict[@"success"] boolValue]) {

                                            [user updateWithDictionary:resultDict[@"data"]];
                                            [user synchronizeUser];
                                            
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:true];

                                            AppDelegate *delgate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                                            [delgate initalizeRootControllerAs:Home];
                                            [[UIApplication sharedApplication] registerForRemoteNotifications];
                                            
                                        } else {
                                            [MBProgressHUD hideAllHUDsForView:self.view animated:true];

                                            NSString *errorMessage = [NSString stringWithFormat:@"%@",resultDict[@"message"]];
                                            [Utils showAlertForString:errorMessage];
                                        }
                                        
                                        HIDE_ALL_HUDS(self.view);
                                    } onCancelation:^{
                                        
                                        [Utils showAlertForString:kRequestFailed];
                                        HIDE_ALL_HUDS(self.view);
                                    }];
    
}


//
//#pragma mark - API Calls
//
//-(void) fetchSpecialities{
//
//    // Dictionary Format Example
//    //    {
//    //        "specid": "3",
//    //        "name": "Internal Medicine"
//    //    }
//
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    [[APIClass sharedManager] apiCallWithRequest:nil
//                                          forApi:kGetAppointmentListSpecialties
//                                     requestMode:kModeGet
//                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
//     {
//         
//         if ([[resultDict objectForKey:@"success"] boolValue]) {
//             _specialityDataArray = [NSMutableArray new];
//             
//             if ([[resultDict objectForKey:@"message"] isEqual:[NSNull null]] ||
//                 [[resultDict objectForKey:@"message"] isEqualToString:@""] ||
//                 [resultDict objectForKey:@"message"] == nil  ) {
//                 
//                 NSArray *dataArray = resultDict[@"data"];
//                 for (int i=0; i<dataArray.count; i++) {
//                     NSDictionary *itemInfo = [dataArray objectAtIndex:i];
//                     [_specialityDataArray addObject:itemInfo];
//                 }
//                 
//                 [self showSpecialityPicker];
//             }
//         } else{
//             NSString *errorMessage = [resultDict objectForKey:@"error"];
//             [Utils showAlertForString:errorMessage];
//         }
//         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
//     } onCancelation:^{
//         [MBProgressHUD hideAllHUDsForView:self.view animated:true];
//         [Utils showAlertForString:kInternetConnectionNotAvailable];
//     }];
//}





/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
