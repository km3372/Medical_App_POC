//
//  CHCRegisterController.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/26/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "CHCRegisterController.h"
#import "CHCConstants.h"
#import "APIClass.h"
#import "APINames.h"
#import "AppDelegate.h"
#import "CommonFilesImporter.h"
#import "AppUserData.h"

const static CGFloat kJVFieldFontSize = 15.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

@interface CHCRegisterController ()

@end

@implementation CHCRegisterController

@synthesize tosButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tosAgreed = NO;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"splash_1"]];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    [self.tableView.backgroundView addSubview:effectView];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.title = @"Registration";
    
    [self insertRegisterButton];
    [self setupTextField];
    
}

-(void)setupTextField{
    
    _firstNameTextField = [self getTextField:_firstNameTextField stringValue:@"First Name"];
    _lastNameTextField =  [self getTextField:_lastNameTextField stringValue:@"Last Name"];
    _emailTextField =  [self getTextField:_emailTextField stringValue:@"Email"];
    _dobTextField =  [self getTextField:_dobTextField stringValue:@"Birthday"];
    _tosTextField =  [self getTextField:_tosTextField stringValue:@"Terms of Service"];
    _passwordTextField =  [self getTextField:_passwordTextField stringValue:@"Password"];
    _confirmPasswordTextField =  [self getTextField:_confirmPasswordTextField stringValue:@"Confirm Password"];
    _phoneNumberTextField =  [self getTextField:_phoneNumberTextField stringValue:@"Phone Number"];
    _phoneNumberTextField.tag = 1;
}

-(void)insertRegisterButton
{
    UIButton* button=[[UIButton alloc] initWithFrame:CGRectMake(20, 330, self.view.frame.size.width-40, 50)];
    [button setTitle:@"REGISTER" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = CHOICE_LIGHT_BLUE.CGColor;
    [button addTarget:self action:@selector(registerButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 5;
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect frame = _registerButton.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - _registerButton.frame.size.height;
    _registerButton.frame = frame;
    
    [self.view bringSubviewToFront:_registerButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
   // [_firstNameTextField becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)registerButtonPressed{
    [self validateForm];
}

-(JVFloatLabeledTextField*)getTextField: (JVFloatLabeledTextField*) textfield stringValue: (NSString*) string {
    UIColor *floatingLabelColor = [UIColor lightGrayColor];
    
    textfield.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    textfield.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(string, @"")
                                    attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}];
    textfield.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    textfield.floatingLabelTextColor = floatingLabelColor;
    textfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    textfield.translatesAutoresizingMaskIntoConstraints = NO;
    textfield.keepBaseline = YES;
    textfield.returnKeyType = UIReturnKeyNext;
    textfield.delegate = self;
    
    return textfield;
}

-(void) validateForm{

    NSString *message = nil;
    BOOL validation = YES;
    
    if (_firstNameTextField.text.length == 0) {
        message = @"Please enter a first name";
        [_firstNameTextField becomeFirstResponder];
    }
    else if (_lastNameTextField.text.length == 0) {
        message = @"Please enter a last name";
    }
    else if (![self validateEmail:self.emailTextField.text]){
        validation = NO;
    }
    else if (_phoneNumberTextField.text.length == 0) {
        message = @"Please enter a phone number";
    }
    else if (_dobTextField.text.length == 0) {
        message = @"Please enter your date of birth";
    }
    else if (_tosTextField.text.length == 0) {
        message = @"Please accept the Terms of Service";
    }
    else if (_sexSegmentControl.selectedSegmentIndex == UISegmentedControlNoSegment){
        message = @"Please select your gender";
    }
    else if (![self validatePassword:self.passwordTextField.text]){
        validation = NO;
    }
    else if (![self.passwordTextField.text isEqualToString:_confirmPasswordTextField.text]){
        message = @"Confirm password does not match password entered";
    }
    
    
    if (message != nil || validation == NO) {
        if (message != nil) {
            [Utils showAlertForString:message];
        }
    }
    else
    {
        [self registerUser];
    }
}


-(void)registerUser{
    
    SHOW_HUD(self.view);
    
    NSString *dob = _dobTextField.text;

    // Create character set with specified characters
    NSMutableCharacterSet *characterSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"()- "];
    
    // Build array of components using specified characters as separtors
    NSArray *arrayOfComponents = [_phoneNumberTextField.text componentsSeparatedByCharactersInSet:characterSet];
    
    // Create string from the array components
    NSString *phoneNumber = [arrayOfComponents componentsJoinedByString:@""];

    NSString* gender;
    if (_sexSegmentControl.selectedSegmentIndex ==0) {
        gender = @"m";
    }
    else
    {
        gender = @"f";
    }
    
    NSDictionary *requestData = @{kFirstName:_firstNameTextField.text,
                                  kLastName:_lastNameTextField.text,
                                  kConfirmPassword:_confirmPasswordTextField.text,
                                  kPassword:_passwordTextField.text,
                                  kEmail:_emailTextField.text,
                                  kDateOfBirth: dob,
                                  kPhone: phoneNumber,
                                  kGender: gender,
                                  kTosStamp: _tosTextField.text,
                                  };
    
    [[APIClass sharedManager] apiCallWithRequest:requestData forApi:kSignUp requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ([resultDict[@"success"] boolValue]) {
            [self loginUser];
            
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"%@",resultDict[@"message"]];
            [Utils showAlertForString:errorMessage];
        }
        
        HIDE_ALL_HUDS(self.view);
    } onCancelation:^{
        
        [Utils showAlertForString:kRequestFailed];
        HIDE_ALL_HUDS(self.view);
    }];
}


-(void) loginUser{
    NSDictionary *postDictionary = @{KUsername:self.emailTextField.text,kPassword:self.passwordTextField.text};
    
    SHOW_HUD(self.view);
    
    [[APIClass sharedManager] apiCallWithRequest:postDictionary forApi:kLogin requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ([resultDict[@"success"] boolValue]) {
            UserModel* user = [UserModel currentUser];
            user.email = self.emailTextField.text;
            user.password = self.passwordTextField.text; //really shouldn't be saving this but the login session is too short otherwise
            [user updateWithDictionary:resultDict[@"data"]];
            [user synchronizeUser];
            
            [[UIApplication sharedApplication] registerForRemoteNotifications];
            
            AppDelegate *delgate = (AppDelegate*)[UIApplication sharedApplication].delegate;

            if ([user.register_survey isEqualToString:@"1"]) {
                [delgate initalizeRootControllerAs:Home];
            }
            else{
                [delgate initalizeRootControllerAs:Survey];
            }
        } else {
            NSString *errorMessage = [NSString stringWithFormat:@"%@",resultDict[@"message"]];
            [Utils showAlertForString:errorMessage];
        }
        
        HIDE_ALL_HUDS(self.view);
    } onCancelation:^{
        
        [Utils showAlertForString:kRequestFailed];
        HIDE_ALL_HUDS(self.view);
    }];

}


-(BOOL)validateEmail:(NSString *)email {
    
    if(email.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Email field should not be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:email options:0 range:NSMakeRange(0, email.length)];
    if (regExMatches == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Enter proper email" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    else {
        return YES;
    }
}

-(BOOL)validatePassword:(NSString *)password {
    if(password.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Password field should not be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }
    
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [self.passwordTextField.text stringByTrimmingCharactersInSet:whitespace];
    
    if (trimmed.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Password field should not contain only spaces" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }else{
        return YES;
    }
}

-(void)addPhotoPressed
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Profile Picture"
                                message:nil
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* button0 = [UIAlertAction
                              actionWithTitle:@"Cancel"
                              style:UIAlertActionStyleCancel
                              handler:^(UIAlertAction * action)
                              {
                                  //  UIAlertController will automatically dismiss the view
                              }];
    
    UIAlertAction* button1 = [UIAlertAction
                              actionWithTitle:@"Take photo"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  //  The user tapped on "Take a photo"
                                   picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                  [self presentViewController: picker animated:YES completion:nil];
                              }];
    
    UIAlertAction* button2 = [UIAlertAction
                              actionWithTitle:@"Choose Existing"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                  [self presentViewController: picker animated:YES completion:nil];
                              }];
    
    
    [alert addAction:button0];
    [alert addAction:button1];
    [alert addAction:button2];
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField.tag == 1)  //Phone number
    {
        int length = (int)[self getLength:textField.text];

        if(length == 10)
        {
            if(range.length == 0)
                return NO;
        }
        
        if(length == 3)
        {
            NSString *num = [self formatNumber:textField.text];
            textField.text = [NSString stringWithFormat:@"(%@) ",num];
            
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
        }
        else if(length == 6)
        {
            NSString *num = [self formatNumber:textField.text];
            //NSLog(@"%@",[num  substringToIndex:3]);
            //NSLog(@"%@",[num substringFromIndex:3]);
            textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
            
            if(range.length > 0)
                textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
        }
    }
    
    return YES;
}

- (NSString *)formatNumber:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = (int)mobileNumber.length;
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    return mobileNumber;
}

- (int)getLength:(NSString *)mobileNumber
{
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = (int)mobileNumber.length;
    
    return length;
}


-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectDate:(NSDate *)date
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    dateFormat.dateStyle = NSDateFormatterShortStyle;
    
    dateFormat.dateFormat = @"yyyy-MM-dd";
    
    self.dobTextField.text = [dateFormat stringFromDate:date];
}



- (IBAction)birthdayButtonPressed:(id)sender {
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"Select Birthday" delegate:self];
    picker.tag = 6;
    picker.actionSheetPickerStyle = IQActionSheetPickerStyleDatePicker;
    [picker show];
}
- (IBAction)tosButton:(id)sender {
}
- (IBAction)tosButtonPressed:(id)sender {
    if (! tosAgreed) {
        [tosButton setImage:[UIImage imageNamed:@"checkbox-checked.png"] forState:UIControlStateNormal];
        tosAgreed = YES;
        NSTimeInterval time = ([NSDate date].timeIntervalSince1970); // returned as a double
        long digits = (long)time;
        self.tosTextField.text = [NSString stringWithFormat:@"%ld",digits];;
    } else if (tosAgreed) {
        [tosButton setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateNormal];
        tosAgreed = NO;
        self.tosTextField.text = @"";
    }
}
- (IBAction)tosLabelTouch:(id)sender {
    NSString *message = @"In order to better serve you Choice Healthcare requires certain medical background information. Please know that your medical history will be kept strictly confidential.\n\nIt is the policy of Choice Healthcare to ensure the confidentiality of all medical information and to protect that information from unauthorized use and disclosure.";
    NSLog(@"%@", message);
    [Utils showAlertForString:message];
}
@end
