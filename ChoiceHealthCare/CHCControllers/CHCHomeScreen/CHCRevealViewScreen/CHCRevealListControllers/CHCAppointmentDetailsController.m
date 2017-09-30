//
//  CHCAppointmentDetailsController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/3/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCAppointmentDetailsController.h"
#import "CHCWeekDayCell.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "SWRevealViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CHCAppointRequestSentController.h"
#import "CHCDoctorsListController.h"
@interface CHCAppointmentDetailsController ()<UITextFieldDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *choicePoints;
@property (strong, nonatomic) IBOutlet UIButton *revealView;

- (IBAction)bookNowClicked:(id)sender;

#pragma Appointment Provider Section...

@property (strong, nonatomic) IBOutlet UIView *providerDetailsView;
@property (strong, nonatomic) IBOutlet UILabel *providerName;
@property (strong, nonatomic) IBOutlet UILabel *providersHospital;
@property (strong, nonatomic) IBOutlet UILabel *providersAddress;
@property (strong, nonatomic) IBOutlet UIImageView *providersPicture;

#pragma Appointment Preference...


@property (strong, nonatomic) IBOutlet UITableView *daysOfWeekTableView;
@property (strong, nonatomic) IBOutlet UIView *customView;
@property (weak, nonatomic) IBOutlet UIView *selectUrgencyView;
@property (weak, nonatomic) IBOutlet UIView *selectDayOfWeekView;
@property (weak, nonatomic) IBOutlet UIView *selectTimeOfDayView;
@property (weak, nonatomic) IBOutlet UITextView *reasonForVisitTextView;
@property (weak, nonatomic) IBOutlet UIView *selectPaymentOptionView;
@property (weak, nonatomic) IBOutlet UIButton *sendRequestButton;
- (IBAction)sendRequestButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *paymentByButton;
- (IBAction)paymentByButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *timeOfDayButton;
- (IBAction)timeOfDayButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dayOfWeekButton;
- (IBAction)dayOfWeekButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *urgencyButton;
- (IBAction)urgencyButtonClicked:(id)sender;




#pragma Extras...
@property (strong, nonatomic) NSString *dayofweek;
@property (strong, nonatomic) NSString *urgency;
@property (strong, nonatomic) NSString *timeOfDay;
@property (strong, nonatomic) NSString *isSelected;
@property (strong, nonatomic) NSMutableArray *daysOfWeekList;
@property (strong, nonatomic) NSMutableArray *dayWeekSelected;
@property (strong, nonatomic) NSMutableArray *urgencyList;
@property (strong, nonatomic) NSMutableArray *urgencySelected;
@property (strong, nonatomic) NSMutableArray *timeOfDayList;
@property (strong, nonatomic) NSMutableArray *timeOfDaySelected;
@property (strong, nonatomic) NSMutableArray *howSoonSelected;
@property (strong, nonatomic) NSMutableArray *timeDaySelected;
@property (strong, nonatomic) NSMutableString *paymentSelected;
@property (nonatomic) NSInteger tableToShow;
- (IBAction)backToSearchResults:(id)sender;

@end

@implementation CHCAppointmentDetailsController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view bringSubviewToFront:self.customView];
    self.outputDictionary = [NSDictionary new];
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    self.paymentByButton.tag = 0 ;
    self.customView.hidden = YES ;
    self.dayofweek=@"dayofweek";
    self.urgency=@"urgency";
    self.timeOfDay=@"timeofday";
    self.isSelected=@"isSelected";
    self.daysOfWeekList = [NSMutableArray new];
    self.dayWeekSelected = [NSMutableArray new];
    self.urgencyList = [NSMutableArray new];
    self.urgencySelected = [NSMutableArray new];
    self.timeOfDayList = [NSMutableArray new];
    self.timeOfDaySelected = [NSMutableArray new];
    self.howSoonSelected = [NSMutableArray new];
    self.timeDaySelected = [NSMutableArray new];
    NSMutableArray *array = [@[@"No Preference",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday",@"Sunday"] mutableCopy];
    for (int i=0 ; i< array.count ; i++) {
        if (i==0) {
            NSDictionary *object = @{self.dayofweek:array[i],self.isSelected:@YES};
            [self.daysOfWeekList addObject:object];
        }else{
            NSDictionary *object = @{self.dayofweek:array[i],self.isSelected:@NO};
            [self.daysOfWeekList addObject:object];
        }
        
    }
    
    array = [@[@"No Preference",@"ASAP",@"In One Week",@"Two Weeks"] mutableCopy];
    for (int i=0 ; i< array.count ; i++) {
        if (i==0) {
            NSDictionary *object = @{self.urgency:array[i],self.isSelected:@YES};
            [self.urgencyList addObject:object];
        }else{
            NSDictionary *object = @{self.urgency:array[i],self.isSelected:@NO};
            [self.urgencyList addObject:object];
        }
        
    }
    
    array = [@[@"Anytime",@"Morning",@"Afternoon",@"Evening"] mutableCopy];
    for (int i=0 ; i< array.count ; i++) {
        if (i==0) {
            NSDictionary *object = @{self.timeOfDay:array[i],self.isSelected:@YES};
            [self.timeOfDayList addObject:object];
        }else{
            NSDictionary *object = @{self.timeOfDay:array[i],self.isSelected:@NO};
            [self.timeOfDayList addObject:object];
        }
        
    }
    
//    [self updateView:self.providerDetailsView];
    self.providerDetailsView.layer.borderColor = [UIColor grayColor].CGColor;
    self.providerDetailsView.layer.borderWidth  = 2.0;
    self.providerDetailsView.layer.cornerRadius = 20;
    [self updateView:self.selectDayOfWeekView];
    (self.selectDayOfWeekView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]];
    [self updateView:self.selectPaymentOptionView];
     (self.selectPaymentOptionView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]];
    [self updateView:self.selectTimeOfDayView];
     (self.selectTimeOfDayView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]];
    [self updateView:self.selectUrgencyView];
     (self.selectUrgencyView).backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Menu_bg.png"]];
    [self updateView:self.urgencyButton];
    [self updateView:self.dayOfWeekButton];
    [self updateView:self.timeOfDayButton];
    [self updateView:self.reasonForVisitTextView];
    [self updateView:self.paymentByButton];
    [self updateView:self.sendRequestButton];
    self.sendRequestButton.layer.cornerRadius = 10.0;
    self.sendRequestButton.clipsToBounds = YES;
    
    [self getDoctorDetails:self.docID];
    [self getUserChoicePoints];
    
}



- (void)updateButtonView:(UIButton*)button{
    //updating button view according to design..
  
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1.0;
    //    button.layer.cornerRadius = 20;
}

- (void)getDoctorDetails:(NSString *)docid{
    NSDictionary *object=@{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"],kDocid:self.docID};
   
    [[APIClass sharedManager]apiCallWithRequest:object forApi:kAppointmentChooseDoctor requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        if ([resultDict[@"success"] boolValue]) {
            if ([resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil  ) {
                NSDictionary *doctorInfo = resultDict[@"data"];
                self.providerName.text = doctorInfo[@"name"];
                self.providersHospital.text = doctorInfo[@"provider"];
                self.providersAddress.text = [NSString stringWithFormat:@"%@,%@",doctorInfo[@"address"],doctorInfo[@"citystate"]];
                 NSString *imageUrl = [NSString stringWithFormat:@"%@%@",kImageIP,doctorInfo[@"avatar"]];
                [self.providersPicture setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_placeholdar.png"]];
                
            
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

-(void)viewDidAppear:(BOOL)animated{
    self.revealViewController.isFromHome=NO;
    self.customView.backgroundColor=[UIColor colorWithPatternImage:[self startBlur]];

}
-(UIImage *)startBlur{
    
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the image
    CIImage *blurImg = [CIImage imageWithCGImage:viewImg.CGImage];
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CIFilter *clampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [clampFilter setValue:blurImg forKey:@"inputImage"];
    [clampFilter setValue:[NSValue valueWithBytes:&transform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:clampFilter.outputImage forKey: @"inputImage"];
    [gaussianBlurFilter setValue:@2.0f forKey:@"inputRadius"];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgImg = [context createCGImage:gaussianBlurFilter.outputImage fromRect:blurImg.extent];
    UIImage *outputImg = [UIImage imageWithCGImage:cgImg];
    return outputImg;
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.tableToShow) {
        case 0:
            //for urgency list..
            if (self.urgencyList.count != 0) {
                return self.urgencyList.count;
            }
            break;
        case 1:
            if (self.daysOfWeekList.count != 0) {
                return self.daysOfWeekList.count;
            }
            break;
        case 2:
            if (self.timeOfDayList.count != 0) {
                return self.timeOfDayList.count;
            }
            break;
            
        
    }
    
  
    return 0;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

//    return self.daysOfWeekTableView.frame.size.height/8.0;
    return 46.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"WeekDayCell";
    
    CHCWeekDayCell *cell =(CHCWeekDayCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = self.daysOfWeekTableView.backgroundColor;
    cell.selectedBackgroundView = bgColorView;
    NSMutableDictionary *dayOfWeekDetails = @{}.mutableCopy;
    switch (self.tableToShow) {
        case 0:{
            //for urgency list..
               dayOfWeekDetails=(self.urgencyList)[indexPath.row];
           cell.dayOfWeek.text= dayOfWeekDetails[self.urgency];
            break;}
        case 1:{
               dayOfWeekDetails=(self.daysOfWeekList)[indexPath.row];
           cell.dayOfWeek.text= dayOfWeekDetails[self.dayofweek];
            break;}
        case 2:{
              dayOfWeekDetails=(self.timeOfDayList)[indexPath.row];
         cell.dayOfWeek.text= dayOfWeekDetails[self.timeOfDay];
            break;}
            
            
    }

    if ([dayOfWeekDetails[self.isSelected] boolValue]) {
        cell.isSelectedImageView.image = [UIImage imageNamed:@"checked1.png"];
       
    }else if (![dayOfWeekDetails[self.isSelected] boolValue]){
       cell.isSelectedImageView.image = [UIImage imageNamed:@"unchecked1.png"];
    }
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSMutableDictionary *dayInfo=@{}.mutableCopy;
    switch (self.tableToShow) {
        case 0:
            dayInfo=(self.urgencyList)[indexPath.row];
            if ([dayInfo[self.isSelected]boolValue]) {
                NSDictionary *myDict=@{self.urgency:dayInfo[self.urgency],self.isSelected:@NO};
                (self.urgencyList)[indexPath.row] = myDict;
            }else{
                NSDictionary *myDict=@{self.urgency:dayInfo[self.urgency],self.isSelected:@YES};
                (self.urgencyList)[indexPath.row] = myDict;
                
            }
            break;
        case 1:
            dayInfo=(self.daysOfWeekList)[indexPath.row];
            if ([dayInfo[self.isSelected]boolValue]) {
                NSDictionary *myDict=@{self.dayofweek:dayInfo[self.dayofweek],self.isSelected:@NO};
                (self.daysOfWeekList)[indexPath.row] = myDict;
            }else{
                NSDictionary *myDict=@{self.dayofweek:dayInfo[self.dayofweek],self.isSelected:@YES};
                (self.daysOfWeekList)[indexPath.row] = myDict;
                
            }
            break;
        case 2:
            dayInfo=(self.timeOfDayList)[indexPath.row];
            if ([dayInfo[self.isSelected]boolValue]) {
                NSDictionary *myDict=@{self.timeOfDay:dayInfo[self.timeOfDay],self.isSelected:@NO};
                (self.timeOfDayList)[indexPath.row] = myDict;
            }else{
                NSDictionary *myDict=@{self.timeOfDay:dayInfo[self.timeOfDay],self.isSelected:@YES};
                (self.timeOfDayList)[indexPath.row] = myDict;
            }
            break;
            
        
    }

    [self.daysOfWeekTableView reloadData];
}

//-(void)setTapGestureForImageView:(UIImageView *)imageView{
//
//    UITapGestureRecognizer *anytimeTapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
//    anytimeTapped.numberOfTapsRequired = 1;
//    [imageView addGestureRecognizer:anytimeTapped];
//    [imageView setUserInteractionEnabled:YES];
//}




- (void)updateView:(UIView *)view{
    //updating button view according to design..
    view.layer.borderColor = [UIColor grayColor].CGColor;
    view.layer.borderWidth = 1.0;
    //    view.layer.cornerRadius = 20;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (IBAction)noPreferenceClicked:(id)sender {
//    if (self.noPreference.tag == 1) {
//        self.noPreference.tag = 0 ;
//        [self.noPreference setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    }else{
//        self.noPreference.tag = 1 ;
//        [self.noPreference setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//    
//    }
//    
//}

//- (IBAction)asapClicked:(id)sender {
//    if (self.asap.tag == 1) {
//        self.asap.tag = 0 ;
//        [self.asap setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    }else{
//        self.asap.tag = 1 ;
//        [self.asap setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:102.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//        
//    }
//}
//
//- (IBAction)inOneWeekClicked:(id)sender {
//    if (self.inOneWeek.tag == 1) {
//        self.inOneWeek.tag = 0 ;
//        [self.inOneWeek setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    }else{
//        self.inOneWeek.tag = 1 ;
//        [self.inOneWeek setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//        
//    }
//}
//
//- (IBAction)twoWeeksClicked:(id)sender {
//    if (self.twoWeeks.tag == 1) {
//        self.twoWeeks.tag = 0 ;
//        [self.twoWeeks setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    }else{
//        self.twoWeeks.tag = 1 ;
//        [self.twoWeeks setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//        
//    }
//}
//
//- (IBAction)selectDayOfWeekClicked:(id)sender {
//    [self.reasonTextfield resignFirstResponder];
//    [self.infoForProviderTextView resignFirstResponder];
//    self.customView.hidden = NO ;
//}
//
//- (IBAction)payingByCashClicked:(id)sender {
//    if (self.payingByCash.tag == 0) {
//        
//        self.payingByCash.tag       = 1 ;
//        self.payingByInsurance.tag  = 0 ;
//        
//        [self.payingByCash setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//        [self.payingByInsurance setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    }
//
//}
//
//- (IBAction)payingByInsurance:(id)sender {
//    if (self.payingByInsurance.tag == 0) {
//        
//        self.payingByInsurance.tag  = 1 ;
//        self.payingByCash.tag       = 0 ;
//        
//        [self.payingByInsurance setTitleColor:[UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0] forState:UIControlStateNormal];
//        [self.payingByCash setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//    }
//}

- (IBAction)bookNowClicked:(id)sender {
//    if ([self checkForValidation]) {
//        
//        NSArray* foo = [self.selectDayOfWeek.titleLabel.text componentsSeparatedByString: @"|"];
//        if ( self.dayWeekSelected.count > 0 ) {
//            [self.dayWeekSelected removeAllObjects];
//        }
//        [self.dayWeekSelected addObjectsFromArray:foo];
//        [self checkHowSoon];
//        [self checkTimeDay];
//        [self checkPayment];
//        
//        NSDictionary *object = @{kHowSoon:self.howSoonSelected
//                                 ,kDayweek:self.dayWeekSelected,kTimeday:self.timeDaySelected,kFirstName:@"",kLastName:@"",kDob:@"",kGender:@"",kPhone:@"",kEmail:@"",kReason:self.reasonTextfield.text,kInfo:self.infoForProviderTextView.text,kPayment:self.paymentSelected};
//        
//        [[APIClass sharedManager] apiCallWithRequest:object forApi:kAppointmentSubmit requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
//            
//             [self performSegueWithIdentifier:@"appointmentdetailstoappointmentrequestsent" sender:self];        
//        } onCancelation:^{
//            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alert show];
//            
//        }];
//        
//        
//    }else{
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Enter all mandatory fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
//    
//    }
//    
}

//- (void)checkHowSoon {
//    if ( self.howSoonSelected.count > 0 ) {
//        [self.howSoonSelected removeAllObjects];
//    }
//    if (self.noPreference.tag == 1 ) {
//        [self.howSoonSelected addObject:[NSString stringWithFormat:@"%@",self.noPreference.titleLabel.text]];
//    }
//    if (self.asap.tag == 1 ) {
//        [self.howSoonSelected addObject:[NSString stringWithFormat:@"%@",self.asap.titleLabel.text]];
//    }
//    if (self.inOneWeek.tag == 1 ) {
//        [self.howSoonSelected addObject:[NSString stringWithFormat:@"%@",self.inOneWeek.titleLabel.text]];
//    }
//    if (self.twoWeeks.tag == 1 ) {
//        [self.howSoonSelected addObject:[NSString stringWithFormat:@"%@",self.twoWeeks.titleLabel.text]];
//    }
//    
//}

//- (void)checkTimeDay {
//    if ( self.timeDaySelected.count > 0 ) {
//        [self.timeDaySelected removeAllObjects];
//    }
//    if (self.anytimeImageView.tag == 11 ) {
//        [self.timeDaySelected addObject:@"Anytime"];
//    }
//    if (self.morningImageView.tag == 21 ) {
//        [self.timeDaySelected addObject:@"Morning"];
//    }
//    if (self.afternoonImageview.tag == 31 ) {
//        [self.timeDaySelected addObject:@"Afternoon"];
//    }
//    if (self.eveningImageView.tag == 41 ) {
//        [self.timeDaySelected addObject:@"Evening"];
//    }
//
//
//}

//-(void)checkPayment {
//    if (self.payingByCash.tag == 1) {
//        self.paymentSelected =[NSMutableString stringWithString:@"cash"];
//    }else if (self.payingByInsurance.tag == 1) {
//       self.paymentSelected =[NSMutableString stringWithString:@"insurance"];
//    }
//
//
//}





-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text

{ if([self.reasonForVisitTextView.text isEqualToString:@"Reason for the visit"]){
    if (![text isEqualToString:@"\n"]) {
       (self.reasonForVisitTextView).text = @"";
    }
    
}else if (self.reasonForVisitTextView.text.length == 0){
    (self.reasonForVisitTextView).text = @"Reason for the visit";

}
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return YES;
    } else if(textView.text.length > 249){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  
    NSSet* allTouches = event.allTouches;
    UITouch* touch = [allTouches anyObject];
    UIView* touchView = touch.view;

    if (touchView.tag == 999 || touchView.tag == 222) {
            NSMutableString *dayPreference = [NSMutableString stringWithString:@""];
        self.customView.hidden=YES;
        switch (self.tableToShow) {
            case 0:
                for (int i=0 ; i < self.urgencyList.count ; i++) {
                    NSDictionary *dayInfo=(self.urgencyList)[i];
                    if ([dayInfo[self.isSelected] boolValue]) {
                        dayPreference = [NSMutableString stringWithFormat:@"%@,%@",dayPreference,[dayInfo[self.urgency] mutableCopy]];
                    }
                }
                if (dayPreference.length > 2) {
                    [dayPreference replaceOccurrencesOfString:@"," withString:@"" options:0 range:NSMakeRange(0, 1)];
                }
                if (dayPreference.length != 0) {
                      [self.urgencyButton setTitle:dayPreference forState:UIControlStateNormal];
                }else{
                    [self.urgencyButton setTitle:@"Please Select" forState:UIControlStateNormal];
                }
              
                break;
            case 1:
                for (int i=0 ; i < self.daysOfWeekList.count ; i++) {
                    NSDictionary *dayInfo=(self.daysOfWeekList)[i];
                    if ([dayInfo[self.isSelected] boolValue]) {
                        dayPreference = [NSMutableString stringWithFormat:@"%@,%@",dayPreference,[dayInfo[self.dayofweek] mutableCopy]];
                    }
                }
                if (dayPreference.length > 2) {
                    [dayPreference replaceOccurrencesOfString:@"," withString:@"" options:0 range:NSMakeRange(0, 1)];
                }
                if (dayPreference.length != 0) {
                    [self.dayOfWeekButton setTitle:dayPreference forState:UIControlStateNormal];
                }else{
                    [self.dayOfWeekButton setTitle:@"Please Select" forState:UIControlStateNormal];
                }
                
                
                
                break;
            case 2:
                for (int i=0 ; i < self.timeOfDayList.count ; i++) {
                    NSDictionary *dayInfo=(self.timeOfDayList)[i];
                    if ([dayInfo[self.isSelected] boolValue]) {
                        dayPreference = [NSMutableString stringWithFormat:@"%@,%@",dayPreference,[dayInfo[self.timeOfDay] mutableCopy]];
                    }
                }
                if (dayPreference.length > 2) {
                    [dayPreference replaceOccurrencesOfString:@"," withString:@"" options:0 range:NSMakeRange(0, 1)];
                }
                if (dayPreference.length != 0) {
                    [self.timeOfDayButton setTitle:dayPreference forState:UIControlStateNormal];
                }else{
                [self.timeOfDayButton setTitle:@"Please Select" forState:UIControlStateNormal];
                }
                
                break;
                
                
         
        }
    
        
    }
   
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController ;
            [navController setViewControllers: @[dvc] animated: NO ] ;
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            if ([segue.identifier isEqualToString:@"appointmentdetailstoappointmentrequestsent"]) {
                CHCAppointRequestSentController *appointRequestSentController = (CHCAppointRequestSentController *)segue.destinationViewController ;
                appointRequestSentController.outputDictionary = self.outputDictionary ;
                appointRequestSentController.docID = self.docID ;
            
            }else if ([segue.identifier isEqualToString:@"appointmentdetailstodoctorslist"]){
                CHCDoctorsListController *chcDoctorsListController = (CHCDoctorsListController *)segue.destinationViewController ;
                
                chcDoctorsListController.getDoctorsRequestDict = [self.getDoctorsRequestDict mutableCopy];
                chcDoctorsListController.type = self.type;
            
            
            }
          
        } ;
        
    }
}


- (IBAction)sendRequestButtonClicked:(id)sender {
   
        if ([self checkForValidation]) {
    
            NSMutableArray* foo = [[self.dayOfWeekButton.titleLabel.text componentsSeparatedByString: @"|"] mutableCopy];
            if ( self.dayWeekSelected.count > 0 ) {
                [self.dayWeekSelected removeAllObjects];
            }
            [self.dayWeekSelected addObjectsFromArray:foo];
            
            foo = [[self.urgencyButton.titleLabel.text componentsSeparatedByString: @"|"] mutableCopy];
            if ( self.urgencySelected.count > 0 ) {
                [self.urgencySelected removeAllObjects];
            }
            [self.urgencySelected addObjectsFromArray:foo];
            
            foo = [[self.timeOfDayButton.titleLabel.text componentsSeparatedByString: @"|"] mutableCopy];
            if ( self.timeOfDaySelected.count > 0 ) {
                [self.timeOfDaySelected removeAllObjects];
            }
            [self.timeOfDaySelected addObjectsFromArray:foo];
            
    
            self.outputDictionary = @{kHowSoon:self.urgencySelected
                                     ,kDayweek:self.dayWeekSelected,kTimeday:self.timeOfDaySelected,kFirstName:@"",kLastName:@"",kDob:@"",kGender:@"",kPhone:@"",kEmail:@"",kReason:self.reasonForVisitTextView.text,kInfo:@"",kPayment:self.paymentByButton.titleLabel.text};
    
            [[APIClass sharedManager] apiCallWithRequest:self.outputDictionary forApi:kAppointmentSubmit requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
    
                 [self performSegueWithIdentifier:@"appointmentdetailstoappointmentrequestsent" sender:self];
            } onCancelation:^{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
    
            }];
    
    
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Enter all mandatory fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        
        }
    
    
}
- (BOOL)checkForValidation {
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self.reasonForVisitTextView.text stringByTrimmingCharactersInSet:whitespace];

    if ([self.dayOfWeekButton.titleLabel.text isEqualToString:@"Please Select"] || [self.timeOfDayButton.titleLabel.text isEqualToString:@"Please Select"]  ||[self.urgencyButton.titleLabel.text isEqualToString:@"Please Select"]||trimmed.length == 0 || [self.reasonForVisitTextView.text isEqualToString:@"Reason for the visit"]) {

        return NO;
    }
    return YES;
}

- (IBAction)paymentByButtonClicked:(id)sender {
    if (self.paymentByButton.tag == 0) {
        self.paymentByButton.tag = 1 ;
        [self.paymentByButton setTitle:@"By Insurance" forState:UIControlStateNormal];
    }else{
        self.paymentByButton.tag = 0;
        [self.paymentByButton setTitle:@"By Cash" forState:UIControlStateNormal];
    
    }
    
}

- (IBAction)timeOfDayButtonClicked:(id)sender {
    
    self.tableToShow = 2;
    [self.reasonForVisitTextView resignFirstResponder];
    [self.daysOfWeekTableView reloadData];
    (self.daysOfWeekTableView).frame = CGRectMake(self.daysOfWeekTableView.frame.origin.x, self.daysOfWeekTableView.frame.origin.y, self.daysOfWeekTableView.frame.size.width, self.timeOfDayList.count*46.0);
    (self.daysOfWeekTableView).center = CGPointMake(self.customView.center.x, self.customView.center.y);
    
    self.customView.hidden = NO ;
}

- (IBAction)dayOfWeekButtonClicked:(id)sender {
    self.tableToShow = 1;
    [self.reasonForVisitTextView resignFirstResponder];
    [self.daysOfWeekTableView reloadData];
    (self.daysOfWeekTableView).frame = CGRectMake(self.daysOfWeekTableView.frame.origin.x, self.daysOfWeekTableView.frame.origin.y, self.daysOfWeekTableView.frame.size.width, self.daysOfWeekList.count*46.0);
    (self.daysOfWeekTableView).center = CGPointMake(self.customView.center.x, self.customView.center.y);
    self.customView.hidden = NO ;
    
}

- (IBAction)urgencyButtonClicked:(id)sender {
    self.tableToShow = 0;
    [self.reasonForVisitTextView resignFirstResponder];
    [self.daysOfWeekTableView reloadData];
    (self.daysOfWeekTableView).frame = CGRectMake(self.daysOfWeekTableView.frame.origin.x, self.daysOfWeekTableView.frame.origin.y, self.daysOfWeekTableView.frame.size.width, self.urgencyList.count*46.0);
    (self.daysOfWeekTableView).center = CGPointMake(self.customView.center.x, self.customView.center.y);
    self.customView.hidden = NO ;
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
[self performSelector:@selector(setCursorToBeginning:) withObject:textView afterDelay:0.01];
}


- (void)setCursorToBeginning:(UITextView *)inView
{
    //you can change first parameter in NSMakeRange to wherever you want the cursor to move
    inView.selectedRange = NSMakeRange(0, 0);
}

- (IBAction)backToSearchResults:(id)sender {
    [self performSegueWithIdentifier:@"appointmentdetailstodoctorslist" sender:self];
}
@end
