//
//  CHCRequestAppointmentController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/1/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCRequestAppointmentController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import <CoreLocation/CoreLocation.h>
#import "SWRevealViewController.h"
#import "CHCDoctorsListController.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface CHCRequestAppointmentController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) IBOutlet UIButton *bySpeciality;
@property (strong, nonatomic) IBOutlet UIButton *byDoctor;
@property (strong, nonatomic) IBOutlet UIButton *selectSpeciality;
@property (strong, nonatomic) IBOutlet UIButton *find;
@property (strong, nonatomic) IBOutlet UITableView *specialityTableView;
@property (strong, nonatomic) IBOutlet UITextField *doctorName;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *specialityTableviewHeightConstraint;

@property (nonatomic) NSInteger counter;

@property (strong, nonatomic) NSMutableString *getDoctorsByName;
@property (strong, nonatomic) NSMutableString *getDoctorsBySpeciality;
@property (strong, nonatomic) NSMutableDictionary *getDoctorsRequestDict;
@property (strong, nonatomic) NSMutableArray *specialityList;
@property (nonatomic) NSInteger type;

- (IBAction)bySpecialityClicked:(id)sender;
- (IBAction)byDoctorClicked:(id)sender;
- (IBAction)selectSpecialityClicked:(id)sender;
- (IBAction)findClicked:(id)sender;


@end

@implementation CHCRequestAppointmentController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];

    self.counter=0;
    // Do any additional setup after loading the view.
    self.getDoctorsRequestDict=[NSMutableDictionary new];
    self.specialityList = [NSMutableArray new];
    [self updateButtonView:self.bySpeciality];
    [self updateButtonView:self.byDoctor];
    [self updateButtonView:self.selectSpeciality];
    
    self.specialityTableView.hidden=YES;
    [self.view bringSubviewToFront:self.specialityTableView];
//    self.specialityTableView.scrollEnabled=NO;
    self.specialityTableView.clipsToBounds = NO;
    self.specialityTableView.layer.masksToBounds = NO;
    (self.specialityTableView.layer).shadowColor = [UIColor blackColor].CGColor;
    (self.specialityTableView.layer).shadowOffset = CGSizeMake(0, 0);
    (self.specialityTableView.layer).shadowRadius = 5.0;
    (self.specialityTableView.layer).shadowOpacity = 1;
    self.selectSpeciality.tag=0;
    self.byDoctor.tag=0;
    self.bySpeciality.tag=1;
    self.doctorName.hidden=YES;
    (self.selectSpeciality).titleEdgeInsets = UIEdgeInsetsMake(0.0f, 15.0f, 0.0f, 0.0f);
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
        
    }
#endif
    [self getSpecialityList];   
    [self getUserChoicePoints];
    (self.specialityTableView).indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)viewDidAppear:(BOOL)animated{
     self.revealViewController.isFromHome=NO;
    if ([CHCRequestAppointmentController isLocationDisableForMyAppOnly]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:kAppName
                                        message:@"Choice health care doesn't have permission to get current location, please change privacy settings"
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
          
            
        });
        
    }
    [self.locationManager startUpdatingLocation];
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

+ (BOOL)isLocationDisableForMyAppOnly {
    // cehcking authorization...
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return YES;
    }
    
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    //getting current user location...
    self.counter++;
    
    
    [self.locationManager stopUpdatingLocation];
    float latitude = newLocation.coordinate.latitude;
    float longitude = newLocation.coordinate.longitude;
  
    if (self.counter == 1) {
 
        NSDictionary *object = @{kGeo_Lat :@(latitude), kGeo_Long: @(longitude),[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
        [[APIClass sharedManager]apiCallWithRequest:object forApi:kAppointmentSetLatAndLong requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
            if ([resultDict[@"success"] boolValue]) {
        
            }
        } onCancelation:^{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
        
        
    }
    
}


-(void)getSpecialityList {
    
     NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:kGetAppointmentListSpecialties requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if (resultDict[@"success"]) {
            self.specialityList = resultDict[@"data"];
            NSDictionary *specialityInfo=(self.specialityList)[0];
            [self.selectSpeciality setTitle:specialityInfo[@"name"] forState:UIControlStateNormal];
            self.getDoctorsBySpeciality = [NSMutableString stringWithString:@"1"];
            [self.specialityTableView reloadData];
            [self setHeightForTheTableView];
            
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    } onCancelation:^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];


}
- (void)updateButtonView:(UIButton*)button{
    //updating button view according to design..
    button.tag=0;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1.0;
//    button.layer.cornerRadius = 20;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.specialityList.count != 0) {
        return self.specialityList.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SpecialityCell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = [UIColor colorWithRed:23.0/255.0 green:23.0/255.0 blue:23.0/255.0 alpha:1.0];
    cell.selectedBackgroundView = bgColorView;
    
    cell.textLabel.textColor = [UIColor grayColor];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    NSDictionary *specialityDict=(self.specialityList)[indexPath.row];
    UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 15.0 ];
    cell.textLabel.font  = myFont;
    (cell.textLabel).textColor = [UIColor whiteColor];
    cell.textLabel.text = specialityDict[@"name"];
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *specialityInfo=(self.specialityList)[indexPath.row];
    [self.selectSpeciality setTitle:specialityInfo[@"name"] forState:UIControlStateNormal];
    self.getDoctorsBySpeciality = [NSMutableString stringWithFormat:@"%d",indexPath.row+1];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.selectSpeciality.tag = 0;
    self.specialityTableView.hidden = YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.doctorName) {
        if (self.doctorName.text.length != 0 ) {
           self.getDoctorsByName = [NSMutableString stringWithFormat:@"%@",self.doctorName.text];
        }
        
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

- (IBAction)bySpecialityClicked:(id)sender {
    if (self.bySpeciality.tag==0) {
        self.bySpeciality.tag=1;
        self.byDoctor.tag=0;
        [self.bySpeciality setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.bySpeciality setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [self.byDoctor setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [self.byDoctor setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.selectSpeciality.hidden=NO;
        self.doctorName.hidden=YES;
        [self.doctorName resignFirstResponder];
    }
}

- (IBAction)byDoctorClicked:(id)sender {
    
    if (self.byDoctor.tag==0) {
        self.byDoctor.tag=1;
        self.bySpeciality.tag=0;
        [self.byDoctor setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.byDoctor setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateSelected];
        [self.bySpeciality setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
        [self.bySpeciality setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.selectSpeciality.hidden=YES;
        self.specialityTableView.hidden=YES;
        self.doctorName.hidden=NO;
    }
    
}

- (IBAction)selectSpecialityClicked:(id)sender {
    if (self.selectSpeciality.tag==0) {
        self.selectSpeciality.tag=1;
         self.specialityTableView.hidden=NO;
        [self.specialityTableView flashScrollIndicators];
        
    }else{
        self.selectSpeciality.tag=0;
        self.specialityTableView.hidden=YES;
    
    }
   
}

- (IBAction)findClicked:(id)sender {
    if (self.bySpeciality.tag == 1) {
        self.selectSpeciality.tag = 0;
        self.specialityTableView.hidden = YES;
        self.getDoctorsRequestDict=[NSMutableDictionary dictionaryWithObject:@((self.getDoctorsBySpeciality).integerValue) forKey:kSpecid];
        self.type = 0;
        [self performSegueWithIdentifier:@"requestappointmenttodoctorslist" sender:self];
        
        
    }else if ( self.byDoctor.tag == 1 ){
        [self.doctorName resignFirstResponder];
        if ( self.doctorName.text.length != 0 ) {
            self.getDoctorsRequestDict=[NSMutableDictionary dictionaryWithObject:self.getDoctorsByName forKey:kDoctorName];
            self.type = 1;
            [self performSegueWithIdentifier:@"requestappointmenttodoctorslist" sender:self];
        }
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.specialityTableView.hidden=YES;
    self.selectSpeciality.tag=0;
    [self.doctorName resignFirstResponder];
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
                [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];}
            if ([segue.identifier isEqualToString:@"requestappointmenttodoctorslist"]) {
                CHCDoctorsListController *chcDoctorsListController = (CHCDoctorsListController *)segue.destinationViewController ;
            
                    chcDoctorsListController.getDoctorsRequestDict = [self.getDoctorsRequestDict mutableCopy];
                    chcDoctorsListController.type = self.type;
                
        }
        };
        
    }
}

-(void)setHeightForTheTableView {

    if ((self.specialityTableView.contentSize.height +220) > self.view.frame.size.height) {
        self.specialityTableviewHeightConstraint.constant=self.specialityTableView.contentSize.height-(self.specialityTableView.contentSize.height +220.0-self.view.frame.size.height);
        [self.specialityTableView updateConstraints];
     
    }else{

        self.specialityTableviewHeightConstraint.constant=self.specialityTableView.contentSize.height;
   
       
    
    }

}

@end
