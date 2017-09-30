//
//  CHCSignUpController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 16/01/16.
//  Copyright © 2016 Sumeet Bajaj. All rights reserved.
//

#import "CHCSignUpController.h"
#import "Utils.h"
#import "SecurityPinController.h"
#import "AppUserData.h"
#import "APIClass.h"
#import "APINames.h"
#import "AppDelegate.h"
#import "CommonFilesImporter.h"

@interface CHCSignUpController ()<UITextFieldDelegate>

{
    BOOL isTermsAccepted;
}

@property (nonatomic, weak) IBOutlet UITextField *firstNameTF;
@property (nonatomic, weak) IBOutlet UITextField *latNameTF;
@property (nonatomic, weak) IBOutlet UITextField *emailTF;
@property (nonatomic, weak) IBOutlet UITextField *passwordTF;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTF;


@end

@implementation CHCSignUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isTermsAccepted = false;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextFiled Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.firstNameTF) {
      
        [self.latNameTF becomeFirstResponder];
    
    } else if (textField == self.latNameTF) {
    
        [self.emailTF becomeFirstResponder];
   
    } else if (textField == self.emailTF ) {
        
        [self.passwordTF becomeFirstResponder];
    
    } else if (textField == self.passwordTF) {
        
        [self.confirmPasswordTF becomeFirstResponder];
    
    } else {
        [self.view endEditing:true];
        [self nextButtonClicked:nil];
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextButtonClicked:(id)sender {
    
    // validate first and last name
    if ([self firstAndLastNameValidation]) {
        
        // validate email Id
        if ([Utils validateEmail:self.emailTF.text]) {
            
            // validate password
            if ([self passwordValidation]) {
                
                if (isTermsAccepted == true) {
                    
                    // saturate all data to user shared data
                    [self saturateData];
                    
                    // navigate to security pin screen
                    [self navigateToSecurityPinController];
                }
                else {
                   [Utils showAlertForString:@"Please accept Terms of Services."];
                }
            }
        }
    }
}

- (IBAction)termsButtonClicked:(id)sender {
    
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
    
    isTermsAccepted = ((UIButton *)sender).selected;
    
}

#pragma mark - Save Data

- (void)saturateData {
    
    AppUserData *userData = [AppUserData sharedInstance];
    
    userData.firstName  = self.firstNameTF.text;
    userData.lastName   = self.latNameTF.text;
    userData.emailId    = self.emailTF.text;
    userData.password   = self.passwordTF.text;
}

#pragma mark - Navigation

- (void)navigateToSecurityPinController {
    
    SecurityPinController *pinController = [[SecurityPinController alloc] initWithNibName:@"SecurityPinController" bundle:nil userType:UserTypeNew completionBlock:^(NSString *resultPin, id controller) {

            [self postDataToServer:controller];
    }];
    
    [self.navigationController presentViewController:pinController animated:false completion:nil];
}

- (void)postDataToServer:(UIViewController *)controller {
    
    SHOW_HUD(controller.view);
    
    AppUserData *userData = [AppUserData sharedInstance];
    
    NSString *fullName = [NSString stringWithFormat:@"%@ %@", userData.firstName, userData.lastName];
    
    NSDictionary *requestData = @{kFullName:fullName,
                                  kPassword:userData.password,
                                  kConfirmPassword:userData.password,
                                  kEmail:userData.emailId,
                                  kPin: userData.pinString };
    
    [[APIClass sharedManager] apiCallWithRequest:requestData forApi:kSignUp requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ([resultDict[@"success"] boolValue] == true ) {
            
            if (resultDict[@"data"]) {
                
                NSDictionary *dataInfo = resultDict[@"data"];
                
                NSDictionary *token = dataInfo[@"token"];
                
                NSString *value = [NSString stringWithFormat:@"%@",token[@"value"]];
                
                if (value.length > 0) {
                    
                    NSArray* foo = [token[@"value"] componentsSeparatedByString: @"="];
                    NSString* tokenValue = foo[0];
                    NSString* tokenString = foo[1];
                    
                    [[NSUserDefaults standardUserDefaults] setValue:[AppUserData sharedInstance].pinString forKey:kPin];
                    [[NSUserDefaults standardUserDefaults] setValue:tokenValue  forKey:@"tokenValue"];
                    [[NSUserDefaults standardUserDefaults] setValue:tokenString forKey:@"tokenString"];
                    [[NSUserDefaults standardUserDefaults] setValue:dataInfo[kUid] forKey:kUid];
                    [[NSUserDefaults standardUserDefaults] setValue:0 forKey:kPointTotal];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    AppDelegate *delgate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    [delgate initalizeRootControllerAs:Home];
                    
                    [controller dismissViewControllerAnimated:YES completion:nil];
                    
                } else {
                    
                    [Utils showAlertForString:@"Token value is missing"];
                }
               
            }
        }
        
        HIDE_ALL_HUDS(controller.view);
        
    } onCancelation:^{
        
        HIDE_ALL_HUDS(controller.view);
    }];
}

#pragma mark - Validation

/**
 *  This method will valiate the First and Last Name
 *
 *  @return Boolean
 */
- (BOOL)firstAndLastNameValidation {
    
    if (self.firstNameTF.text.length <= 0) {
       
        [Utils showAlertForString:@"Please enter first name."];
        
        return NO;
    }
    
    if (self.latNameTF.text.length <= 0) {
       
        [Utils showAlertForString:@"Please enter last name."];
        
        return NO;
    }
    
    return YES;
}

/**
 *  This method will validate the password and confirm password.
 *
 *  @return Boolean
 */
- (BOOL)passwordValidation {
    
    if (self.passwordTF.text.length <= 0) {
        
        [Utils showAlertForString:@"Please enter password"];
        
        return false;
    } else if (self.passwordTF.text.length < 6) {
        
        [Utils showAlertForString:@"Password should contain minimum 6 characters"];
        
        return false;
    }
    
    if (self.confirmPasswordTF.text.length <= 0) {
        
        [Utils showAlertForString:@"Please enter confirm password"];
        
        return false;
    }
    
    if (![self.passwordTF.text isEqualToString:self.confirmPasswordTF.text]) {
        
        [Utils showAlertForString:@"Password didn't match"];
        
        return false;
    }
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
