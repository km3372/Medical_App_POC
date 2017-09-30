//
//  DashboardViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "DashboardViewController.h"
#import "CustomNavigationBar.h"
#import "UserModel.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface DashboardViewController ()

@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UserModel* user = [UserModel currentUser];
    NSString* name = [NSString stringWithFormat:@"Welcome %@", (user.firstName) ? user.firstName : @""];
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeMenu andTitle:name];
    [self addBottomBarViewWithType:BottomBarTypeDefault];

    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scheduledApponitment) name: @"scheduledApponitment" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editedApponitment) name: @"editedApponitment" object:nil];

    [self updateBadgeCount:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateBadgeCount:) name:@"didReceiveRemoteNotification" object:NULL];
}

- (void)updateBadgeCount:(NSNotification*)notification {
    UserModel* user = [UserModel currentUser];
    [[CustomNavigationBar sharedInstance] setBadgeValue:(user.badgeTotalCount).integerValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handling
- (IBAction)myHealthButtonClicked:(id)sender{
    [self performSegueWithIdentifier:@"ShowHealthDashboard" sender:self];
}

- (IBAction)myAppointmentsClicke:(id)sender {
    [self performSegueWithIdentifier:@"ShowMyAppointments" sender:self];
}

- (IBAction)myInboxClicked:(id)sender {
//    [self performSegueWithIdentifier:@"ShowMyInbox" sender:self];
    [self performSegueWithIdentifier:@"ShowSurveys" sender:self];
}

- (IBAction)myToDoClicked:(id)sender {
 
    [self performSegueWithIdentifier:@"ShowMyToDo" sender:self];
}


- (IBAction)needHelpButtonClicked:(id)sender {
    
    [self callForHelp];
}


-(void)scheduledApponitment{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.labelText = NSLocalizedString(@"Appointment Requested", @"HUD done title");
    
    [hud hide:YES afterDelay:3.0];
}

-(void)editedApponitment{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.labelText = NSLocalizedString(@"Appointment Updated", @"HUD done title");
    
    [hud hide:YES afterDelay:3.0];
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
