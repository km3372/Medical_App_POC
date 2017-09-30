//
//  BaseViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "BaseViewController.h"
#import "SWRevealViewController.h"
#import "CommonFilesImporter.h"
#import "MyMedicationsController.h"
#import "MyAppointmentsController.h"
#import "PointsRewardsController.h"

@interface BaseViewController ()<SWRevealViewControllerDelegate,BottomBarViewDelegate>

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addNavigationBarLeftButtonType:(LeftNavButtonType)type andTitle:(NSString *)title{
    
    CustomNavigationBar *navigationBar = [[CustomNavigationBar sharedInstance] createNavBarWithLeftButtonType:type andTitle:title];
    
    navigationBar.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 64);
    
    if (type == LeftNavButtonTypeMenu) {
        
        [navigationBar.leftNavButton addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
        self.revealViewController.delegate = self;
        
    } else {
        
         [navigationBar.leftNavButton addTarget:self action:@selector(leftNavButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }

    [self.view addSubview:navigationBar];
    
}

- (void)addBottomBarViewWithType:(BottomBarType)type {
    
    BottomBarView *bottomBarView = [BottomBarView createBottomBarWithType:type];
    
    bottomBarView.delegate = self;
    
    bottomBarView.frame = CGRectMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(bottomBarView.frame), CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight(bottomBarView.frame));
    

    [self.view addSubview:bottomBarView];
}

- (void)leftNavButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SWReavelViewController Delegates

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    
    [(self.view).subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL *
                                                       _Nonnull stop) {
        obj.userInteractionEnabled = position == FrontViewPositionLeft ? true : false;
    }];
}

#pragma mark - Bottom Bar Delegate

- (void)bottomBarButtonClickedForType:(ButtonType)type {
    
    switch (type) {
        case ButtonTypeMyMeds: [self goToMyMedicationsScreen];          break;
        case ButtonTypeMyApps: [self goToMyAppointmentsScreen];         break;
        case ButtonTypeGetHelp: [self callForHelp];                     break;
        case ButtonTypePoints: [self goToRedeemScreen];                 break;
        default:                                                        break;
    }
}

#pragma mark - Navigation

- (void)callForHelp {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Call ChoicePoints Help Line?"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Call Help" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
        
        NSURL *url = [NSURL URLWithString:kInERPhoneNumber];
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [Utils showAlertForString:@"Your device does not support calling."];
        }
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *  action) {
            //Do nothing;
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
    
}

- (void)goToMyAppointmentsScreen {
    
    MyAppointmentsController *apptsController = [self checkController:[MyAppointmentsController class]isPresentInNavigationStack:self.navigationController];
    
    if (apptsController) {
        
        [self.navigationController popToViewController:apptsController animated:false];
    }
    else {
        
        if(![self.navigationController.topViewController isKindOfClass:[MyAppointmentsController class]]) {
            apptsController = [[UIStoryboard storyboardWithName:@"CHCHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyAppointmentsController"];
            
            [self.navigationController pushViewController:apptsController animated:false];
        }
    }
    
}

- (void)goToMyMedicationsScreen {
    
    MyMedicationsController *previousController = [self checkController:[MyMedicationsController class]isPresentInNavigationStack:self.navigationController];
    
    if (previousController) {
        
        [self.navigationController popToViewController:previousController animated:false];
    }
    else {
        
        if(![self.navigationController.topViewController isKindOfClass:[MyMedicationsController class]]) {
            previousController = [[UIStoryboard storyboardWithName:@"CHCHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"MyMedicationsController"];
            
            [self.navigationController pushViewController:previousController animated:false];
        }
    }
}

- (void)goToRedeemScreen {

    PointsRewardsController *previousController = [self checkController:[PointsRewardsController class]isPresentInNavigationStack:self.navigationController];

    if (previousController) {

        [self.navigationController popToViewController:previousController animated:false];
    }
    else {

        previousController = [[UIStoryboard storyboardWithName:@"CHCHome" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PointsRewardsController"];

        [self.navigationController pushViewController:previousController animated:false];
    }
}

- (id)checkController:(Class)class isPresentInNavigationStack:(UINavigationController *)navigationController {

    id object;
    
    NSArray *controllerStack = navigationController.viewControllers;
    
    for (id obj in controllerStack) {
        
        if ([obj isKindOfClass:class]) {
            
            object = obj;
            break;
        }
    }
    return object;
}

@end
