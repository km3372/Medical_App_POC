//
//  CHCLoginController.m
//  ChoiceHealthCare
//
//  Created by Mindbowser on 8/17/15.
//  Copyright (c) 2015 Mindbowser. All rights reserved.
//

#import "CHCLoginController.h"
#import "APIClass.h"
#import "APINames.h"
#import "CHCConstants.h"
#import "AppDelegate.h"
#import "CommonFilesImporter.h"

@interface CHCLoginController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UITextField *email;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) IBOutlet UIButton *signUpButton;
@property (strong, nonatomic) IBOutlet UITextField *password;
- (IBAction)logInButtonClick:(id)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *logoImageViewVerticalCenter;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *emailToBottomVerticalSpacing;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *loginToBottomVerticalSpacing;
@property (nonatomic, weak) IBOutlet UIButton *createNewAccButton;

@end

@implementation CHCLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = true;
    
    self.loginButton.layer.borderColor  = [UIColor blackColor].CGColor;
    self.loginButton.layer.borderWidth  = 1.0;
    self.loginButton.layer.cornerRadius = 6.0;
    self.createNewAccButton.layer.cornerRadius = 3.0;
    self.createNewAccButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.createNewAccButton.layer.borderWidth = 1.0;
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    
    (self.logoImageViewVerticalCenter).constant = 170;
    (self.emailToBottomVerticalSpacing).constant = 240;
    (self.loginToBottomVerticalSpacing).constant = 100;

    [UIView animateWithDuration:1.0 animations:^{
        
        [self.logoImageView layoutIfNeeded];
        [self.signUpButton  layoutIfNeeded];
        [self.loginButton   layoutIfNeeded];
        [self.email         layoutIfNeeded];
        [self.password      layoutIfNeeded];
        [self.logoImageView updateConstraints];
        [self.loginButton   updateConstraints];
        [self.email         updateConstraints];
        [self.password      updateConstraints];
        [self.view          updateConstraints];
        
    }];
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

- (IBAction)backButtonClicked:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)logInButtonClick:(id)sender {
  
    if ([self validateEmail:self.email.text]) {
      
        if ([self validatePassword:self.password.text]) {
        
            NSDictionary *postDictionary = @{KUsername:self.email.text,kPassword:self.password.text};
            
            SHOW_HUD(self.view);
            
            [[APIClass sharedManager] apiCallWithRequest:postDictionary forApi:kLogin requestMode:kModePost onCompletion:^(NSDictionary *resultDict, NSError *error) {
               
                if ([resultDict[@"success"] boolValue]) {
                    UserModel* user = [UserModel currentUser];
                    user.password = self.password.text; //really shouldn't be saving this but the login session is too short otherwise
                    [user updateWithDictionary:resultDict[@"data"]];
                    [user synchronizeUser];
                    
                    AppDelegate *delgate = (AppDelegate*)[UIApplication sharedApplication].delegate;
                    // For the MVP release PIN is out of scope. Commenting out the code here.
                    //[delgate initalizeRootControllerAs:Security];
                    [delgate initalizeRootControllerAs:Home];
                } else {
                    NSString *errorMessage = [NSString stringWithFormat:@"%@",resultDict[@"error"]];
                    [Utils showAlertForString:errorMessage];
                }
                
                HIDE_ALL_HUDS(self.view);
            } onCancelation:^{
                
                [Utils showAlertForString:kRequestFailed];
                HIDE_ALL_HUDS(self.view);
            }];
        }
    }
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
    NSString *trimmed = [self.password.text stringByTrimmingCharactersInSet:whitespace];
  
    if (trimmed.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Password field should not contain only spaces" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }else{
        return YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField==self.email) {
        [self.email resignFirstResponder];
        [self.password becomeFirstResponder];
    }else {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self keyboardShownViewToAnimate:self.view heightToMove:-50];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    
    if (textField == self.password) {
        [self keyboardHideViewToAnimateBack:self.view withPrevFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    }
}

-(void)keyboardShownViewToAnimate:(UIView *)view heightToMove:(float)height {
    
    [UIView animateWithDuration:0.25f animations:^{
        CGRect frame = view.frame;
        frame.origin.y = height;
        view.frame = frame;
    }];
}

- (void)keyboardHideViewToAnimateBack:(UIView *)view withPrevFrame:(CGRect)frame {
    [UIView animateWithDuration:0.25f animations:^{
        view.frame = frame;
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if ((self.email).isFirstResponder|| (self.password).isFirstResponder ) {
        [self.email resignFirstResponder];
        [self.password resignFirstResponder];
        [self keyboardHideViewToAnimateBack:self.view withPrevFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height)];
    }
}


- (IBAction)signUpButtonClicked:(id)sender {
  
    [self performSegueWithIdentifier:@"SignUpController" sender:self];
}

@end
