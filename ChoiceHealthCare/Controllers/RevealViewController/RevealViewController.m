//
//  RevealViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "RevealViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "GIBadgeView.h"
#import "UserModel.h"
#import "RevealViewCell.h"

@interface RevealViewController ()<UITableViewDelegate,UITableViewDataSource> {
    UserModel* user;
}

@property (nonatomic, strong) NSArray *menuList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation RevealViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    user = [UserModel currentUser];


    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refresh)
                                                 name:@"didReceiveRemoteNotification"
                                               object:NULL];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refresh {
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            if ([segue.identifier isEqualToString:@"Dashboard"] && self.revealViewController.isFromHome) {
                [self.revealViewController.navigationController popToRootViewControllerAnimated:YES];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            }else{
                UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
                
                [navController setViewControllers: @[dvc] animated: NO ];
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];}
        };
    }
}

- (NSArray *)menuList {
    
    if (!_menuList) {
        _menuList = @[@"Home", @"My Profile", @"Appointments", @"Surveys", @"Wellness Milestones", @"Locate a Doctor", @"Articles", @"Logout"];
    }
    
    return _menuList;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RevealViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RevealViewCell"]; 
    NSString* label = (self.menuList)[indexPath.row];

    if ([label isEqualToString:@"Appointments"])
        (cell.badgeView).badgeValue = (user.badgeAppointmentCount).integerValue;
    else if ([label isEqualToString:@"Surveys"])
        (cell.badgeView).badgeValue = (user.badgeSurveyCount).integerValue;
    else if ([label isEqualToString:@"Wellness Milestones"])
        (cell.badgeView).badgeValue = (user.badgeWellnessCount).integerValue;
    else
        (cell.badgeView).badgeValue = 0;

    cell.menuLabel.text = label;

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    SWRevealViewController* revealVC = [self revealViewController];
    UINavigationController* nc = (UINavigationController*)[self revealViewController].frontViewController;
    UIStoryboard* storyboard = revealVC.storyboard;

    UIViewController* nextVC = nil; //used below to programmatically load VCs from the storyboard
    
    //This Reveal menu is all kinds of björked because they want to "deep-link" to pages that
    //aren't at the top level. Thanks to the previous coders' inventive use of custom classes
    //instead of actual UINavigationControllers this is going to very klugey to do.
    switch (indexPath.row) {
        //0: @"Home",
        case 0:
            [self performSegueWithIdentifier:@"ShowDashboard" sender:self];
            break;
            
        //1: @"My Profile",
        case 1:
            [nc popToViewController:nc.viewControllers[0] animated:NO];
            nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyProfileController"];
            [nc pushViewController:nextVC animated:YES];
            [revealVC revealToggleAnimated:YES];
            break;
            
        //2: @"Appointments",
        case 2:
            [nc popToViewController:nc.viewControllers[0] animated:NO];
            nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyAppointmentsController"];
            [nc pushViewController:nextVC animated:YES];
            [revealVC revealToggleAnimated:YES];
            break;
            
        //3: @"Surveys",
        case 3:
            [nc popToViewController:nc.viewControllers[0] animated:NO];
            nextVC = [storyboard instantiateViewControllerWithIdentifier:@"SurveysViewController"];
            [nc pushViewController:nextVC animated:YES];
            [revealVC revealToggleAnimated:YES];
            break;
            
        //4: @"Wellness Milestones",
        case 4:
            [nc popToViewController:nc.viewControllers[0] animated:NO];
            nextVC = [storyboard instantiateViewControllerWithIdentifier:@"HEDISViewController"];
            [nc pushViewController:nextVC animated:YES];
            [revealVC revealToggleAnimated:YES];
            break;
            
        //5: @"Locate a Doctor",
        case 5:
            [nc popToViewController:nc.viewControllers[0] animated:NO];
            nextVC = [storyboard instantiateViewControllerWithIdentifier:@"SearchDoctorController"];
            [nc pushViewController:nextVC animated:YES];
            [revealVC revealToggleAnimated:YES];
            break;
            
        //6: @"Articles",
        case 6:
            [nc popToViewController:nc.viewControllers[0] animated:NO];
            storyboard = [UIStoryboard storyboardWithName:@"Articles" bundle:[NSBundle mainBundle]];
            nextVC = [storyboard instantiateInitialViewController];
            [nc pushViewController:nextVC animated:YES];
            [revealVC revealToggleAnimated:YES];
            break;
            
        //7: @"Logout"
        case 7:
            [delegate logout];
            break;
            
        default:
            break;
    }
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
