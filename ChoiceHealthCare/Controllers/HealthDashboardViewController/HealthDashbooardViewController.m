//
//  HealthDashbooardViewController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 07/05/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "HealthDashbooardViewController.h"
#import "SWRevealViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UserModel.h"
#import "UIImage+Extension.h"

@interface HealthDashbooardViewController ()

@end

@implementation HealthDashbooardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNavigationBarLeftButtonType:LeftNavButtonTypeBack andTitle:@"My Health"];
    [self addBottomBarViewWithType:BottomBarTypeDefault];


    //setup points history
    self.pointsImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.pointsImageView.layer.borderWidth = 2.0;
    self.pointsImageView.layer.cornerRadius = (self.profileImageView.bounds.size.width/4);
    self.pointsImageView.layer.masksToBounds = YES;
    self.pointsImageView.clipsToBounds = YES;
    self.pointsImageView.contentMode = UIViewContentModeBottom;
    CGSize size = self.pointsImageView.bounds.size;
    size.height = size.height*0.66;
    UIImage *pointsImage = [UIImage getImageFromText:@"+10"
                                       withTextColor:[UIColor whiteColor]
                                            textFont:[UIFont boldSystemFontOfSize:24]
                                        andImageSize:size];
    self.pointsImageView.image = pointsImage;

    //setup My profile image view
    self.profileImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.cornerRadius = (self.profileImageView.bounds.size.width/2);
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.clipsToBounds = YES;

    UserModel* user = [UserModel currentUser];
    if (user.profileImageURL)
        [self.profileImageView setImageWithURL:user.profileImageURL placeholderImage:[UIImage imageNamed:@"profilephoto.png"]];
    else
        self.profileImageView.image = [user profileImage];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editProfileButtonClicked:(id)sender{
//    [self performSegueWithIdentifier:@"ShowProfileDashboard" sender:self];
    SWRevealViewController* revealVC = [self revealViewController];
    UINavigationController* nc = (UINavigationController*)revealVC.frontViewController;
    UIStoryboard* storyboard = revealVC.storyboard;

    UIViewController* nextVC = [storyboard instantiateViewControllerWithIdentifier:@"MyProfileController"];
    [nc pushViewController:nextVC animated:YES];
}

- (IBAction)activityLoggerButtonClicked:(id)sender {    
//    [self performSegueWithIdentifier:@"ShowActivityLogger" sender:self];
    SWRevealViewController* revealVC = [self revealViewController];
    UINavigationController* nc = (UINavigationController*)revealVC.frontViewController;
    UIStoryboard* storyboard = revealVC.storyboard;

    UIViewController* nextVC = [storyboard instantiateViewControllerWithIdentifier:@"PointsHistoryController"];
    [nc pushViewController:nextVC animated:YES];
}

- (IBAction)myMedicationsButtonClicked:(id)sender {
//    [self performSegueWithIdentifier:@"ShowMyMedications" sender:self];
    UINavigationController* nc = (UINavigationController*)[self revealViewController].frontViewController;
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Articles" bundle:[NSBundle mainBundle]];
    UIViewController* nextVC = [storyboard instantiateInitialViewController];
    [nc pushViewController:nextVC animated:YES];
}

- (IBAction)hedisMilestonesButtonClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"ShowHEDISMilestones" sender:self];
}

- (void)leftNavButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:true];
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
