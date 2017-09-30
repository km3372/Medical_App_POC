//
//  CHCDoctorsListController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/2/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCDoctorsListController.h"
#import "CHCDoctorsListTableViewCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SWRevealViewController.h"
#import "CHCAppointmentDetailsController.h"
@interface CHCDoctorsListController ()<UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *doctorsListTableView;
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) NSMutableArray *doctorsList;
@property (strong, nonatomic) NSString *docID;
@property (weak, nonatomic) IBOutlet UIButton *startOver;

- (IBAction)startOverClicked:(id)sender;
- (IBAction)sendAppointmentRequestClicked:(id)sender;

@end

@implementation CHCDoctorsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    self.doctorsList = [NSMutableArray new];
    
    [self getUserChoicePoints];
    [self getDoctorsDetails];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated {
   self.revealViewController.isFromHome=NO;
    if (self.type == 0) {
    
        [self.startOver setTitle:[NSString stringWithFormat:@"Search by Speciality: %@",(self.getDoctorsRequestDict)[@"specialty"]] forState:UIControlStateNormal];
    }else if(self.type == 1 ){
    [self.startOver setTitle:@"Search by Doctor" forState:UIControlStateNormal];
    }
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

-(void)getDoctorsDetails {
    NSMutableString *forApi = [NSMutableString stringWithString:@""];
    NSMutableDictionary *object = [@{} mutableCopy];
    if (self.type == 0) {
        forApi = [NSMutableString stringWithString:kDoctorFindBySpecialty];
        object=[@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"],@"specid":(self.getDoctorsRequestDict)[@"specid"] } mutableCopy] ;
    }else{
        forApi = [NSMutableString stringWithString:kDoctorFindByName];
        object=[ @{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"],kDoctorName:(self.getDoctorsRequestDict)[kDoctorName] } mutableCopy];
    }

    [[APIClass sharedManager] apiCallWithRequest:object forApi:forApi requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {

            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                self.doctorsList = resultDict[@"data"];                
                [self.doctorsListTableView reloadData];
            
            }else if ([resultDict[@"message"] isEqualToString:@"No doctors found"]){
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.doctorsList.count != 0) {
        return self.doctorsList.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"DoctorsListCell";
    
    CHCDoctorsListTableViewCell *cell =(CHCDoctorsListTableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    cell.borderViw.layer.borderColor = [UIColor grayColor].CGColor;
    cell.borderViw.layer.borderWidth  = 2.0;
    cell.borderViw.layer.cornerRadius = 20;
    
    cell.sendAppointmentRequest.layer.borderColor = [UIColor blackColor].CGColor;
    cell.sendAppointmentRequest.layer.borderWidth = 0.5;
    cell.sendAppointmentRequest.layer.cornerRadius = 10;
    cell.sendAppointmentRequest.clipsToBounds = YES;
    NSDictionary *doctorsInfo = (self.doctorsList)[indexPath.row];
    cell.name.text = doctorsInfo[@"name"];
    cell.provider.text = doctorsInfo[@"provider"];
    cell.distance.text = [NSString stringWithFormat:@"%@ miles",doctorsInfo[@"distance"]];
    cell.address.text = [NSString stringWithFormat:@"%@, %@",doctorsInfo[@"address"],doctorsInfo[@"citystate"]];
    cell.sendAppointmentRequest.tag = indexPath.row;
      tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    NSString *imageUrl = [NSString stringWithFormat:@"%@%@",kImageIP,doctorsInfo[@"avatar"]];
    [cell.avatarImageVIew setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_placeholdar.png"]];
   cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200.0;

}

- (IBAction)startOverClicked:(id)sender {
   [self performSegueWithIdentifier:@"startover" sender:self];
}

- (IBAction)sendAppointmentRequestClicked:(id)sender {
   
    UIButton *button = sender;

    NSDictionary *docInfo = (self.doctorsList)[button.tag];
    self.docID = [NSString stringWithFormat:@"%@",docInfo[@"docid"]];
    [self performSegueWithIdentifier:@"doctorlisttoappointmentdetails" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
                UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController ;
                [navController setViewControllers: @[dvc] animated: NO ] ;
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            if ([segue.identifier isEqualToString:@"doctorlisttoappointmentdetails"]) {
                CHCAppointmentDetailsController *chcAppointmentDetailsController = (CHCAppointmentDetailsController *)segue.destinationViewController ;
                chcAppointmentDetailsController.docID = self.docID ;
                chcAppointmentDetailsController.getDoctorsRequestDict=self.getDoctorsRequestDict;
                chcAppointmentDetailsController.type=self.type;
            }
        } ;
        
    }
}



@end
