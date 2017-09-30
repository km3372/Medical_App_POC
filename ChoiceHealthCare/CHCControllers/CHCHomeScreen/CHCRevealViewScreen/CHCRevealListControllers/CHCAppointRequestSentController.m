//
//  CHCAppointRequestSentController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/14/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCAppointRequestSentController.h"
#import "SWRevealViewController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CHCAppointRequestSentController ()

@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UIButton *home;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
- (IBAction)homeButtonClick:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *requestDetailsView;
@property (weak, nonatomic) IBOutlet UILabel *urgencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *providerName;
@property (weak, nonatomic) IBOutlet UILabel *providerHospital;
@property (weak, nonatomic) IBOutlet UILabel *providerAddress;
@property (weak, nonatomic) IBOutlet UIImageView *providerAvatar;


@end

@implementation CHCAppointRequestSentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    [self getUserChoicePoints];
    self.home.layer.borderColor = [UIColor blackColor].CGColor;
    self.home.layer.borderWidth = 1.0;
    self.home.layer.cornerRadius = 10.0;
    self.home.clipsToBounds =YES;
    self.requestDetailsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.requestDetailsView.layer.borderWidth  = 2.0;
    self.requestDetailsView.layer.cornerRadius = 20;
    [self getDoctorDetails:self.docID];
    // Do any additional setup after loading the view.
}
- (void)getDoctorDetails:(NSString *)docid{
        NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"],kDocid:self.docID};

    [[APIClass sharedManager]apiCallWithRequest:object forApi:kAppointmentChooseDoctor requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                NSDictionary *doctorInfo = resultDict[@"data"];
                self.providerName.text = doctorInfo[@"name"];
                self.providerHospital.text = doctorInfo[@"provider"];
                self.providerAddress.text = [NSString stringWithFormat:@"%@,%@",doctorInfo[@"address"],doctorInfo[@"citystate"]];
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@",kImageIP,doctorInfo[@"avatar"]];
                [self.providerAvatar setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_placeholdar.png"]];
                
                
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }];
    
}


- (void)viewDidAppear:(BOOL)animated {
    self.revealViewController.isFromHome=NO;
    
    

    NSString * time = [(self.outputDictionary)[kTimeday] componentsJoinedByString:@""];
    NSString * day = [(self.outputDictionary)[kDayweek] componentsJoinedByString:@""];
    NSString * urgency = [(self.outputDictionary)[kHowSoon] componentsJoinedByString:@""];
  
    self.urgencyLabel.text = urgency;
    self.dayLabel.text = day;
    self.timeLabel.text =time;
    self.reasonLabel.text = (self.outputDictionary)[kReason];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)homeButtonClick:(id)sender {

     [self performSegueWithIdentifier:@"appointmentrequestsenttohome" sender:self];
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
