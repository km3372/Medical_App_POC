//
//  CHCMedicationReminderController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 9/8/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCMedicationReminderController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CHCMedicationReminderListTableViewCell.h"
#import "CHCReminderController.h"
@interface CHCMedicationReminderController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>

#pragma Custom Reminder View..

@property (strong, nonatomic) IBOutlet UIView *customReminderView;
@property (strong, nonatomic) IBOutlet UITextField *medicationName;
@property (strong, nonatomic) IBOutlet UIButton *medicationType;
@property (strong, nonatomic) IBOutlet UITextField *medicationFrequency;
@property (strong, nonatomic) IBOutlet UITextField *hours;
@property (strong, nonatomic) IBOutlet UITextField *minutes;
@property (strong, nonatomic) IBOutlet UITextField *doses;
@property (strong, nonatomic) IBOutlet UIButton *medicationFor;
@property (strong, nonatomic) IBOutlet UITableView *medicationForTableView;
@property (strong, nonatomic) NSMutableArray *medicationForList;

@property (weak, nonatomic) IBOutlet UITableView *remindersTableView;

- (IBAction)medicationTypeClicked:(id)sender;
- (IBAction)medicationForClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
- (IBAction)createClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *createButton;

#pragma Main View...

@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (strong, nonatomic) IBOutlet UILabel *choicePoints;

@property (strong, nonatomic) IBOutlet UIButton *createReminder;

- (IBAction)createReminderClicked:(id)sender;

#pragma others...
@property (strong, nonatomic) NSMutableArray *medicationList;

#pragma Instruction View...
@property (weak, nonatomic) IBOutlet UIView *instructionView;
@property (weak, nonatomic) IBOutlet UIButton *medicationReminderInstructionButton;
- (IBAction)medicationReminderButtonClicked:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *instructionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *medicationReminderVerticalConstraint;
@property (weak, nonatomic) IBOutlet UITextView *instructionTextView;
@property (strong, nonatomic) NSString *remID;


@end

@implementation CHCMedicationReminderController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.view bringSubviewToFront:self.instructionView];
    self.medicationReminderInstructionButton.tag = 0 ;
    [self updateView:self.medicationReminderInstructionButton];
    self.medicationReminderInstructionButton.layer.cornerRadius = 6.0;
    self.medicationReminderInstructionButton.clipsToBounds =YES;
    [self updateView:self.createButton];
    self.createButton.layer.cornerRadius = 6.0;
    self.createButton.clipsToBounds =YES;
    [self updateView:self.cancelButton];
    self.cancelButton.layer.cornerRadius = 6.0;
    self.cancelButton.clipsToBounds =YES;
    [self updateView:self.instructionView];
    [self updateButtonView:self.createReminder];
    self.createReminder.layer.cornerRadius = 10.0;
    self.createReminder.clipsToBounds =YES;
    
    [self.view bringSubviewToFront:self.customReminderView];
    self.medicationForTableView.hidden = YES ;
    self.medicationFor.tag=0;
    self.medicationForTableView.scrollEnabled=NO;
    self.medicationForTableView.clipsToBounds = NO;
    self.medicationForTableView.layer.masksToBounds = NO;
    (self.medicationForTableView.layer).shadowColor = [UIColor blackColor].CGColor;
    (self.medicationForTableView.layer).shadowOffset = CGSizeMake(0, 0);
    (self.medicationForTableView.layer).shadowRadius = 5.0;
    (self.medicationForTableView.layer).shadowOpacity = 1;

    self.medicationForList = [[NSMutableArray alloc]initWithObjects:@"Myself",@"Spouse",@"Child",@"Other",nil];
   
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];
    
    [self updateButtonView: self.medicationType];
    [self updateButtonView: self.medicationFor];
//    [self updateButtonView: self.selectMedication];
    self.medicationList = [NSMutableArray new];
    [self getUserChoicePoints];
    [self getMedicationList];
    self.remindersTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Do any additional setup after loading the view.
}

- (void)updateView:(UIView *)view{
    //updating button view according to design..
    view.layer.borderColor = [UIColor blackColor].CGColor;
    view.layer.borderWidth = 1.0;
    //    view.layer.cornerRadius = 20;
}

- (void)updateButtonView:(UIButton*)button{
    //updating button view according to design..
    button.tag=0;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = 1.0;
    //    button.layer.cornerRadius = 20;
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

-(void)getMedicationList {
    NSDictionary *object = @{[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
    [[APIClass sharedManager]apiCallWithRequest:object forApi:kRemindersFetchList requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ( [resultDict[@"success"] boolValue] ) {
            if ( [resultDict[@"message"] isEqual:[NSNull null]] || [resultDict[@"message"] isEqualToString:@""] || resultDict[@"message"] == nil ) {
                self.medicationList = resultDict[@"data"];
                [self.remindersTableView reloadData];
                
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

-(void)viewDidAppear:(BOOL)animated {
    self.revealViewController.isFromHome = NO;
    self.customReminderView.backgroundColor=[UIColor colorWithPatternImage:[self startBlur]];
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)medicationTypeClicked:(id)sender {
    if ([self.medicationType.titleLabel.text isEqualToString:@"Hourly"]) {
        [self.medicationType setTitle:@"Daily" forState:UIControlStateNormal];
    }else if ([self.medicationType.titleLabel.text isEqualToString:@"Daily"]){
        [self.medicationType setTitle:@"Hourly" forState:UIControlStateNormal];
    
    }
}

- (IBAction)medicationForClicked:(id)sender {
    [self.medicationName resignFirstResponder];
    [self.medicationFrequency resignFirstResponder];
    [self.hours resignFirstResponder];
    [self.minutes resignFirstResponder];
    [self.doses resignFirstResponder];
    if (self.medicationFor.tag == 0) {
    
        self.medicationFor.tag = 1;
        self.medicationForTableView.hidden = NO;
    }else{
        self.medicationFor.tag = 0;
        self.medicationForTableView.hidden = YES;
    }
}

- (IBAction)cancelClicked:(id)sender {
    
    self.medicationForTableView.hidden = YES;
    self.medicationFor.tag = 0;
    self.customReminderView.hidden=YES;
    self.medicationName.text = @"";
    self.medicationFrequency.text =@"";
    self.hours.text = @"";
    self.minutes.text = @"";
    self.doses.text = @"";
    
}

- (IBAction)createClicked:(id)sender {
  
    if ([self checkForAllFields]){
        NSDictionary *object = @{kMed:self.medicationName.text ,kType:self.medicationType.titleLabel.text,kFrequency:self.medicationFrequency.text,kDose:self.doses.text,[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenValue" ]:[[NSUserDefaults standardUserDefaults] objectForKey:@"tokenString"]};
        
       [[APIClass sharedManager] apiCallWithRequest:object forApi:kRemindersCreate requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {

           if ([resultDict[@"success"] boolValue]) {
               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"message"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
               [alert show];
               [self getMedicationList];
               self.medicationForTableView.hidden = YES;
               self.medicationFor.tag = 0;
               self.customReminderView.hidden=YES;
               self.medicationName.text = @"";
               self.medicationFrequency.text =@"";
               self.hours.text = @"";
               self.minutes.text = @"";
               self.doses.text = @"";
               
           }else{
               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:resultDict[@"error"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
               [alert show];
           }
           
       } onCancelation:^{
           UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kInternetConnectionNotAvailable delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
           [alert show];
           
       }];

    
    }
}

- (BOOL)checkForAllFields {
    if (self.medicationName.text.length == 0 || self.medicationFrequency.text.length == 0 || self.hours.text.length == 0 || self.minutes.text.length ==0 || self.doses.text.length == 0) {
        UIAlertView *alert = [ [ UIAlertView alloc]initWithTitle:kAppName message:@"Please enter all fields" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
        [alert show];
        return NO;
    }
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *medicationNameTrimmed = [self.medicationName.text stringByTrimmingCharactersInSet:whitespace];
    NSString *medicationFrequencyTrimmed = [self.medicationFrequency.text stringByTrimmingCharactersInSet:whitespace];
    NSString *hoursTrimmed = [self.hours.text stringByTrimmingCharactersInSet:whitespace];
    NSString *minutesTrimmed = [self.minutes.text stringByTrimmingCharactersInSet:whitespace];
    NSString *dosesTrimmed = [self.doses.text stringByTrimmingCharactersInSet:whitespace];
    
    if (medicationNameTrimmed.length == 0 || medicationFrequencyTrimmed.length == 0 || hoursTrimmed.length == 0 || minutesTrimmed.length == 0 || dosesTrimmed.length == 0) {
        UIAlertView *alert = [ [ UIAlertView alloc]initWithTitle:kAppName message:@"Field cannot contain only spaces" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil ];
        [alert show];
        return NO;
    }
    
    return YES;
}
- (IBAction)selectMedicationClicked:(id)sender {
    
}

- (IBAction)createReminderClicked:(id)sender {

    self.customReminderView.hidden=NO;
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    NSSet* allTouches = event.allTouches;
    UITouch* touch = [allTouches anyObject];
    UIView* touchView = touch.view;
    if ( touchView.tag == 999 || touchView.tag == 998 ) {
//        self.customReminderView.hidden=YES;
        [self.medicationName resignFirstResponder];
        [self.medicationFrequency resignFirstResponder];
        [self.hours resignFirstResponder];
        [self.minutes resignFirstResponder];
        [self.doses resignFirstResponder];
        [self keyboardHideViewToAnimateBack:self.view withPrevFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    }
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if (textField == self.medicationName) {
        [self.medicationName resignFirstResponder];
        [self.medicationFrequency becomeFirstResponder];
    }else if (textField ==self.medicationFrequency){
        [self.medicationFrequency resignFirstResponder];
        [self.hours becomeFirstResponder];
    }else if (textField ==self.hours){
        [self.hours resignFirstResponder];
        [self.minutes becomeFirstResponder];
    }else if (textField ==self.minutes){
        [self.minutes resignFirstResponder];
        [self.doses becomeFirstResponder];
    }else if (textField == self.doses){
        [self.doses resignFirstResponder];
    
    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.doses) {
        [self keyboardHideViewToAnimateBack:self.view withPrevFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    }
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.medicationForTableView.hidden = YES ;
    self.medicationFor.tag =0 ;
    [self keyboardShownViewToAnimate:self.view heightToMove:-125];
    
}

-(void)keyboardShownViewToAnimate:(UIView *)view heightToMove:(float)height
{
    [UIView animateWithDuration:0.25f animations:^ {
        CGRect frame = view.frame;
        frame.origin.y = height;
        view.frame = frame;
    }];
}

- (void)keyboardHideViewToAnimateBack:(UIView *)view withPrevFrame:(CGRect)frame
{
    [UIView animateWithDuration:0.25f animations:^
     {
         view.frame = frame;
     }];
}

#pragma TableView...

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([tableView isEqual:self.medicationForTableView]) {
        return self.medicationForList.count;
    }else if ([tableView isEqual:self.remindersTableView]){
        if (self.medicationList.count != 0 ) {
            return self.medicationList.count;
        } else{
            return 0;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.medicationForTableView]) {
        static NSString *MyIdentifier = @"MedicationForCell";
        
        UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        (cell.textLabel).textColor = [UIColor whiteColor];
        cell.textLabel.text = (self.medicationForList)[indexPath.row];
        UIFont *myFont = [ UIFont fontWithName: @"Arial" size: 15.0 ];
        cell.textLabel.font  = myFont;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else{
        static NSString *MyIdentifier = @"ReminderCell";
        
        CHCMedicationReminderListTableViewCell *cell =(CHCMedicationReminderListTableViewCell *) [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        cell.borderView.layer.borderColor = [UIColor colorWithRed:17.0/255.0 green:56.0/255.0 blue:103.0/255.0 alpha:1.0].CGColor;
        cell.borderView.layer.borderWidth = 1.0;
        NSDictionary *medicationInfo = (self.medicationList)[indexPath.row];
        cell.medicationName.text =medicationInfo[@"med"];
        tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.medicationForTableView]) {
        self.medicationFor.tag = 0;
        self.medicationForTableView.hidden=YES;
        [self.medicationFor setTitle:(self.medicationForList)[indexPath.row] forState:UIControlStateNormal];
    }else{
        self.remID = (self.medicationList)[indexPath.row][kRemid];
        [self performSegueWithIdentifier:@"medicationcatalogtoreminder" sender:self];
    
    }
   
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];


}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual : self.hours] || [textField isEqual : self.minutes] || [textField isEqual : self.medicationFrequency]) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, newString.length)];
        if (numberOfMatches == 0)
            return NO;
    }
    if ([textField isEqual: self.hours]) {
        NSString* newText;
        
        newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        return newText.intValue < 25;
    }else if ([textField isEqual: self.minutes]) {
        NSString* newText;
        
        newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        return newText.intValue < 60;
    }
    return YES;
}


- (IBAction)medicationReminderButtonClicked:(UIButton *)sender {

    if (self.medicationReminderInstructionButton.tag == 0 ) {
        self.medicationReminderInstructionButton.tag = 1;
        [self.medicationReminderInstructionButton setTitle:@"Got it!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = (self.view.frame.size.height-65.0);
        (self.medicationReminderVerticalConstraint).constant = self.view.frame.size.height;
        self.instructionTextView.hidden = NO;
        
    }else{
        self.medicationReminderInstructionButton.tag = 0;
        [self.medicationReminderInstructionButton setTitle:@"Medication Reminder Instructions!" forState:UIControlStateNormal];
        (self.instructionViewHeightConstraint).constant = 35.0;
        (self.medicationReminderVerticalConstraint).constant = 45.0;
        self.instructionTextView.hidden = YES;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue *) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController* dvc) {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController ;
            [navController setViewControllers: @[dvc] animated: NO ] ;
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
            if ([segue.identifier isEqualToString:@"medicationcatalogtoreminder"]) {
                CHCReminderController *chcReminderController = (CHCReminderController *)segue.destinationViewController ;
                chcReminderController.remID = self.remID ;
            }
        } ;
        
    }
}


@end
