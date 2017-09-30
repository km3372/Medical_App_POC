//
//  ListSurveysViewController.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 9/6/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "ListSurveysViewController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "ListSurveyCell.h"
#import "CommonFilesImporter.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "SurveysViewController.h"
#import "ArticlesViewController.h"
#import "SWRevealViewController.h"

@interface ListSurveysViewController ()

@end

@implementation ListSurveysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"Earn Points"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];
    
    titles = @[@"Answer Questions", @"Read Articles", @"Schedule Appointments", @"Wellness Milestones (Bonus+)"];
    images = @[@"question-blue", @"book-blue", @"calendar-blue", @"firstaid-blue"];
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated{
    [self fetchSurveys];
}

#pragma mark - TableView Delegates and DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* CellIdentifier = @"ListSurveyCell";
    ListSurveyCell* surveyCell = (ListSurveyCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (surveyCell == nil) {
        surveyCell = [[ListSurveyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    surveyCell.titleLabel.text = titles[indexPath.row];

    surveyCell.completionImageView.image = [UIImage imageNamed:images[indexPath.row]];

    
    return surveyCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SWRevealViewController* revealVC = [self revealViewController];
    UINavigationController* nc = (UINavigationController*)revealVC.frontViewController;
    UIStoryboard* storyboard = revealVC.storyboard;
    
    switch (indexPath.row) {
        case 0:
        {
            //This should use Survey 2. Find it in the list
            NSDictionary* survey2 = [_surveyArray filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject[@"sid"] isEqualToString:@"2"];
            }]].firstObject;

            //Check if it's completed already.
            if ([survey2[@"completed"] isEqualToString:@"1"]) {
                [Utils showAlertForString:@"Survey has been completed"];
            }
            else{
                [self performSegueWithIdentifier:@"ShowSurveyQuestions" sender:self];
            }
        }
            break;
        case 1:
        {
            UINavigationController* nc = (UINavigationController*)[self revealViewController].frontViewController;
            UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Articles" bundle:[NSBundle mainBundle]];
            UIViewController* nextVC = [storyboard instantiateInitialViewController];
            [nc pushViewController:nextVC animated:YES];
        }
            break;
        case 2:
        {
            UIViewController* nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyAppointmentsController"];
            [nc pushViewController:nextVC animated:YES];
        }
            break;
        case 3:
        {
            UIViewController* nextVC = [storyboard instantiateViewControllerWithIdentifier:@"HEDISViewController"];
            [nc pushViewController:nextVC animated:YES];
        }
            break;
            
        default:
            break;
    }

//    if (indexPath.row == 0) {
//        
//        if ([[[_surveyArray objectAtIndex:indexPath.row] objectForKey:@"completed"] isEqualToString:@"1"]) {
//            [Utils showAlertForString:@"Survey has been completed"];
//        }
//        else{
//            [self performSegueWithIdentifier:@"ShowSurveyQuestions" sender:self];
//        }
//    }
}




#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.destinationViewController isKindOfClass:[SurveysViewController class]]) {
        ((SurveysViewController*)segue.destinationViewController).sid = sender;
    }
}


#pragma mark - API Calls

-(void)fetchSurveys {
    
    _surveyArray = [NSMutableArray new];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APIClass sharedManager] apiCallWithRequest:nil
                                          forApi:kFetchSurvey
                                     requestMode:kModeGet
                                    onCompletion:^(NSDictionary *resultDict, NSError *error)
     {
         if ([resultDict[@"success"] boolValue]) {
              _surveyArray = resultDict[@"data"];
              [_tableView reloadData];
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
