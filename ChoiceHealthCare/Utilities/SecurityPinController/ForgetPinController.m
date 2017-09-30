//
//  CHCForgetPinController.m
//  ChoiceHealthCare
//
//  Created by Sumeet Bajaj on 01/02/16.
//  Copyright © 2016 Mindbowser. All rights reserved.
//

#import "ForgetPinController.h"
#import "Utils.h"
#import "APIClass.h"
#import "APINames.h"
#import "MBProgressHud.h"
#import "CHCConstants.h"
#import "UserModel.h"

@interface ForgetPinController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *emailTF;
@property (nonatomic, weak) IBOutlet UITextField *passwordTF;

@end

@implementation ForgetPinController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBarHidden = false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = true;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.emailTF) {
        [self.passwordTF becomeFirstResponder];
    }else {
        [self.view endEditing:YES];
    }
    return YES;
}

- (IBAction)resetButtonClicked:(id)sender {
    
    if (![Utils validateEmail:self.emailTF.text]) {
        return;
    }
    
    if (self.passwordTF.text.length <= 0) {
        
        [Utils showAlertForString:@"Please enter password"];
        return;
    }
    
    NSDictionary *dic = @{@"email":self.emailTF.text,@"pass":self.passwordTF.text};
    
    [self forgetPinApiCall:dic];
}

- (IBAction)cancelButtonClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)forgetPinApiCall:(NSDictionary *)requestBody {
    UserModel* user = [UserModel currentUser];

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[APIClass sharedManager] apiCallWithRequest:requestBody forApi:kForgetPin requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
        
        if ([resultDict[@"success"] boolValue] == true ) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        if (resultDict[@"message"]) {
            
            [Utils showAlertForString:resultDict[@"message"]];
        }
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
    } onCancelation:^{
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        [Utils showAlertForString:@"Something went wrong, please try again later"];
        
    }];
}
@end
