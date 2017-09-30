//
//  CHCRegisterControllerNew.m
//  ChoiceHealthCare
//
//  Created by Rahiem Klugh on 8/29/16.
//  Copyright © 2016 Sumeet. All rights reserved.
//

#import "CHCLoginControllerNew.h"
#import "CHCConstants.h"
#import "APIClass.h"
#import "APINames.h"
#import "AppDelegate.h"
#import "CommonFilesImporter.h"

const static CGFloat kJVFieldFontSize = 15.0f;
const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

@interface CHCLoginControllerNew ()

@end

@implementation CHCLoginControllerNew

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:
                                     [UIImage imageNamed:@"splash_1"]];
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    // add effect to an effect view
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:blur];
    effectView.frame = self.view.frame;
    
    [self.tableView.backgroundView addSubview:effectView];
    
    self.title = @"Login";
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
}

-(void)setupTextField{
    _emailTextField =  [self getTextField:_emailTextField stringValue:@"Email"];
    _passwordTextField =  [self getTextField:_passwordTextField stringValue:@"Password"];
    
    _emailTextField.delegate = self;
    _passwordTextField.delegate = self;
}

-(void)insertLoginButton
{
    UIButton* button=[[UIButton alloc] initWithFrame:CGRectMake(20, 250, self.view.frame.size.width-40, 50)];
    [button setTitle:@"LOGIN" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = CHOICE_LIGHT_BLUE.CGColor;
    [button addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    
    [_emailTextField becomeFirstResponder];
    
    [self insertLoginButton];
    [self setupTextField];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 2;
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect frame = _loginButton.frame;
    frame.origin.y = scrollView.contentOffset.y + self.tableView.frame.size.height - _loginButton.frame.size.height;
    _loginButton.frame = frame;
    
    [self.view bringSubviewToFront:_loginButton];
}

-(JVFloatLabeledTextField*)getTextField: (JVFloatLabeledTextField*) textfield stringValue: (NSString*) string {
    UIColor *floatingLabelColor = [UIColor whiteColor];
    
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

-(void)loginButtonPressed{
    if ([self validateEmail:self.emailTextField.text]) {
        
        if ([self validatePassword:self.passwordTextField.text]) {
            
            NSDictionary *postDictionary = @{KUsername:self.emailTextField.text,kPassword:self.passwordTextField.text};
            
            SHOW_HUD(self.view);
            
            [[APIClass sharedManager] apiCallWithRequest:postDictionary
                                                  forApi:kLogin
                                             requestMode:kModePost
                                            onCompletion:^(NSDictionary *resultDict, NSError *error) {

                if ([resultDict[@"success"] boolValue]) {
                    UserModel* user = [UserModel currentUser];
                    user.password = self.passwordTextField.text; //really shouldn't be saving this but the login session is too short otherwise
                    [user updateWithDictionary:resultDict[@"data"]];
                    [user synchronizeUser];
                    
                    AppDelegate *delgate = (AppDelegate*)[UIApplication sharedApplication].delegate;;
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                    
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
    NSString *trimmed = [self.passwordTextField.text stringByTrimmingCharactersInSet:whitespace];
    
    if (trimmed.length == 0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:kAppName message:@"Password field should not contain only spaces" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    if (theTextField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else if (theTextField == self.passwordTextField) {
        [self.emailTextField becomeFirstResponder];
    }
    return YES;
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
