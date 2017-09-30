//
//  CHCEditProfileController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 27/01/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "CHCEditProfileController.h"
#import "SWRevealViewController.h"
#import "Utils.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"

@interface CHCEditProfileController ()<UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIButton *revealView;
@property (nonatomic, weak) IBOutlet UITextField *phoneNumberTF;
@property (nonatomic, weak) IBOutlet UITextField *pinTf;
@property (nonatomic, weak) IBOutlet UITextField *emailTF;
@property (nonatomic, weak) IBOutlet UITextField *passwordTF;
@property (nonatomic, weak) IBOutlet UITextField *confirmPasswordTF;


@end

@implementation CHCEditProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.revealView addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addGestureRecognizer:self.revealViewController.tapGestureRecognizer];

}

-(void)viewDidAppear:(BOOL)animated {
  
    self.revealViewController.isFromHome = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextFiled Delegates

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailTF) {
        
        [self.phoneNumberTF becomeFirstResponder];
        
    } else if (textField == self.phoneNumberTF) {
        
        [self.passwordTF becomeFirstResponder];
        
    } else if (textField == self.passwordTF ) {
        
        [self.confirmPasswordTF becomeFirstResponder];
        
    } else if (textField == self.confirmPasswordTF) {
        
        [self.pinTf becomeFirstResponder];
        
    } else {
        [self.view endEditing:true];
    }
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == self.pinTf && range.location > 3) {
        
        return NO;
    }
    
    return YES;
}


- (IBAction)updateButtonClicked:(id)sender {
    
    if ([Utils validateEmail:self.emailTF.text]) {
        
        if (self.phoneNumberTF.text.length != 10) {
            
            [Utils showAlertForString:@"Please enter valid phone number"];
            
        } else {
            
            if ([self passwordValidation]) {
                
                if (self.pinTf.text.length != 4) {
                    
                    [Utils showAlertForString:@"Pin should be four digit."];
                    
                } else {
                 
                    [self updateProfileApiCall];
                }
            }
        }
    }
}

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
    return true;
}

- (void)updateProfileApiCall {
    
    NSDictionary *requestedBody = @{@"phone":self.phoneNumberTF.text,
                                    kPassword:self.passwordTF.text,
                                    kConfirmPassword:self.confirmPasswordTF.text,
                                    kEmail:self.emailTF.text,
                                    kPin:self.pinTf.text};
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APIClass sharedManager] apiCallWithRequest:requestedBody forApi:kUpdateProfile requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ([resultDict[@"success"] boolValue] == true ) {
            
            [Utils showAlertForString:@"Profile updated successfully!"];
        } else if (resultDict[@"message"]) {
            
            [Utils showAlertForString:resultDict[@"message"]];
        } else {
            [Utils showAlertForString:@"Something went wrong, please try again later"];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } onCancelation:^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [Utils showAlertForString:@"Something went wrong, please try again later"];
    }];
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
