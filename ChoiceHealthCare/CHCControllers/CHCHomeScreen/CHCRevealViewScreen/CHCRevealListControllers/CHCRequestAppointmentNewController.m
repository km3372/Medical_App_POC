//
//  CHCRequestAppointmentNewController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 10/23/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCRequestAppointmentNewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SWRevealViewController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "CHCDoctorsListController.h"
#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface CHCRequestAppointmentNewController ()<CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *revealView;
@property (weak, nonatomic) IBOutlet UILabel *choicePoints;

#pragma InstructionView...
@property (weak, nonatomic) IBOutlet UIView *instructionView;
@property (weak, nonatomic) IBOutlet UIButton *appointmentInstructionButton;
- (IBAction)appointmentInstructionButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *instructionTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instructionViewHeightConstraint;


#pragma Request AppointView...

@property (weak, nonatomic) IBOutlet UIScrollView *myScrollView;

@property (weak, nonatomic) IBOutlet UIView *appointmentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *specialityTableviewHeightConstraint;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) NSInteger counter;
@property (strong, nonatomic) NSMutableString *getDoctorsByName;
@property (strong, nonatomic) NSMutableString *getDoctorsBySpeciality;
@property (strong, nonatomic) NSMutableDictionary *getDoctorsRequestDict;
@property (strong, nonatomic) NSMutableArray *specialityList;
@property (weak, nonatomic) IBOutlet UIView *searchBySpecialityView;
@property (weak, nonatomic) IBOutlet UIButton *specialitySelectionButton;
- (IBAction)specialitySelectionButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *searchByDoctorView;
@property (weak, nonatomic) IBOutlet UITextField *doctorNameTextfield;
@property (weak, nonatomic) IBOutlet UIButton *findDoctorButton;
- (IBAction)findDoctorButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *specialityTableView;
@property (nonatomic) NSInteger type;



@end

@implementation CHCRequestAppointmentNewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.instructionView];
    self.appointmentInstructionButton.tag = 0 ;
    [self updateView:self.appointmentInstructionButton];
    self.appointmentInstructionButton.layer.cornerRadius = 6.0;
    self.appointmentInstructionButton.clipsToBounds =YES;
    [self updateView:self.instructionView];
    [self updateView:self.searchByDoctorView];

    [self updateView:self.searchBySpecialityView];
   
    [self updateView:self.specialitySelectionButton];
    [self updateView:self.findDoctorButton];
    self.findDoctorButton.layer.cornerRadius = 6.0;
    self.findDoctorButton.clipsToBounds = YES;
    // Do any additional setup after loading the view.
    
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    self.counter=0;
    // Do any additional setup after loading the view.
    self.getDoctorsRequestDict=[NSMutableDictionary new];
    self.specialityList = [NSMutableArray new];
    self.specialityTableView.hidden=YES;
    [self.view bringSubviewToFront:self.specialityTableView];
    self.specialityTableView.clipsToBounds = NO;
    self.specialityTableView.layer.masksToBounds = NO;
    (self.specialityTableView.layer).shadowColor = [UIColor blackColor].CGColor;
    (self.specialityTableView.layer).shadowOffset = CGSizeMake(0, 0);
    (self.specialityTableView.layer).shadowRadius = 5.0;
    (self.specialityTableView.layer).shadowOpacity = 1;
    self.specialitySelectionButton.tag=0;
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
    (self.searchByDoctorView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]] ;
    (self.searchBySpecialityView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]];
    if ([CHCRequestAppointmentNewController isLocationDisableForMyAppOnly]){
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
            [self.specialitySelectionButton setTitle:specialityInfo[@"name"] forState:UIControlStateNormal];
            self.getDoctorsBySpeciality = specialityInfo[kSpecid];
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

-(void)setHeightForTheTableView {
    

    if ((self.specialityTableView.contentSize.height +220.0) > 430.0) {
        NSLog(@"%f",(self.specialityTableView.contentSize.height +220.0-430.0));
        self.specialityTableviewHeightConstraint.constant=self.specialityTableView.contentSize.height-(self.specialityTableView.contentSize.height +220.0-430.0);
        NSLog(@"%f",self.specialityTableviewHeightConstraint.constant);
        [self.specialityTableView updateConstraints];
        NSLog(@"Content size goes out of screen");
    }else{
        
        self.specialityTableviewHeightConstraint.constant=self.specialityTableView.contentSize.height;
        NSLog(@"Content size is within screen");
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

- (void)updateView:(UIView *)view{
    //updating button view according to design..
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0;
    //    view.layer.cornerRadius = 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

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


- (IBAction)appointmentInstructionButtonClicked:(id)sender {

 
    if (self.appointmentInstructionButton.tag == 0 ) {
        self.appointmentInstructionButton.tag = 1;
        [self.appointmentInstructionButton setTitle:@"Got it!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = (self.view.frame.size.height-65.0);

        self.instructionTextView.hidden = NO;
        
    }else{
        self.appointmentInstructionButton.tag = 0;
        [self.appointmentInstructionButton setTitle:@"Appointment Instructions!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = 35.0;

        self.instructionTextView.hidden = YES;
    }
}
- (IBAction)specialitySelectionButtonClicked:(id)sender {
    if (self.specialitySelectionButton.tag==0) {
        self.specialitySelectionButton.tag=1;
        self.specialityTableView.hidden=NO;
        [self.specialityTableView flashScrollIndicators];
        
    }else{
        self.specialitySelectionButton.tag=0;
        self.specialityTableView.hidden=YES;
        
    }
}
- (IBAction)findDoctorButtonClicked:(id)sender {
 
    if (self.doctorNameTextfield.text.length == 0) {
        self.specialitySelectionButton.tag = 0;
        self.specialityTableView.hidden = YES;
//        self.getDoctorsRequestDict=[NSMutableDictionary dictionaryWithObject:@([self.getDoctorsBySpeciality integerValue]) forKey:kSpecid];
        self.getDoctorsRequestDict = @{kSpecid : self.getDoctorsBySpeciality,@"specialty":self.specialitySelectionButton.titleLabel.text}.mutableCopy;
        self.type = 0;
        [self performSegueWithIdentifier:@"requestappointmenttodoctorslist" sender:self];
        
        
    }else{
        [self.doctorNameTextfield resignFirstResponder];
        if ( self.doctorNameTextfield.text.length != 0 ) {
            self.getDoctorsRequestDict=[NSMutableDictionary dictionaryWithObject:self.getDoctorsByName forKey:kDoctorName];
            self.type = 1;
            [self performSegueWithIdentifier:@"requestappointmenttodoctorslist" sender:self];
        }
    }
}

#pragma TableView Methods...
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
    [self.specialitySelectionButton setTitle:specialityInfo[@"name"] forState:UIControlStateNormal];
    
    self.getDoctorsBySpeciality = (self.specialityList)[indexPath.row][kSpecid];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.specialitySelectionButton.tag = 0;
    self.specialityTableView.hidden = YES;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

#pragma TextField Methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
   
        [self keyboardHideViewToAnimateBack:self.view withPrevFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    
        if (self.doctorNameTextfield.text.length != 0 ) {
            self.getDoctorsByName = [NSMutableString stringWithFormat:@"%@",self.doctorNameTextfield.text];
        }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    [self keyboardShownViewToAnimate:self.view heightToMove:-125];
    
}

-(void)keyboardShownViewToAnimate:(UIView *)view heightToMove:(float)height
{
    [UIView animateWithDuration:0.25f animations:^ {
        CGRect frame = view.frame;
        frame.origin.y = height;
        view.frame = frame;
        dispatch_async(dispatch_get_main_queue(), ^{
        [self scrollToBottom];
        });
    }];
}

-(void)scrollToBottom{
dispatch_async(dispatch_get_main_queue(), ^{
    CGRect page = CGRectMake(0, 370, 320, 150);
    [self.myScrollView scrollRectToVisible:page animated:YES];
});
    
}

- (void)keyboardHideViewToAnimateBack:(UIView *)view withPrevFrame:(CGRect)frame
{
    [UIView animateWithDuration:0.25f animations:^
     {
         view.frame = frame;
     }];
}



@end
